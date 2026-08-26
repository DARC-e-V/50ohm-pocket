import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fuenfzigohm/learning_state/answer_event.dart';
import 'package:fuenfzigohm/learning_state/learning_state_repository.dart';
import 'package:fuenfzigohm/learning_state/legacy_progress_migrator.dart';
import 'package:fuenfzigohm/learning_state/practice_question_selector.dart';
import 'package:fuenfzigohm/learning_state/reset_learning_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDirectory;
  late Box<dynamic> eventsBox;
  late Box<dynamic> settingsBox;
  late Box<dynamic> legacyProgressBox;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('learning-state-');
    Hive.init(hiveDirectory.path);
    eventsBox = await Hive.openBox<dynamic>('events');
    settingsBox = await Hive.openBox<dynamic>('settings');
    legacyProgressBox = await Hive.openBox<dynamic>('legacy-progress');
  });

  setUp(() async {
    await eventsBox.clear();
    await settingsBox.clear();
    await legacyProgressBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('answer log projects scores by stable question id', () async {
    final repository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );

    await repository.recordAnswer(
      questionId: 'NA102',
      correct: true,
      selectedAnswerKey: 'a',
    );
    await repository.recordAnswer(
      questionId: 'NA102',
      correct: false,
      selectedAnswerKey: 'b',
    );
    await repository.recordAnswer(
      questionId: 'NA102',
      correct: true,
      selectedAnswerKey: 'a',
    );

    expect(eventsBox.length, 3);
    expect(repository.scoreForQuestion('NA102'), 2);
    expect(repository.scoreForQuestion('EA111'), 0);

    final rebuiltRepository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );
    expect(rebuiltRepository.scoreForQuestion('NA102'), 2);

    final events =
        eventsBox.values.whereType<Map>().map(AnswerEvent.fromMap).toList();
    expect(events.where((event) => event.correct), hasLength(2));
    expect(events.where((event) => !event.correct), hasLength(1));
    expect(events.map((event) => event.deviceId).toSet(), hasLength(1));
  });

  test('a single answer is persisted before the lesson is completed', () async {
    final repository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );

    await repository.recordAnswer(
      questionId: 'NA102',
      correct: true,
      selectedAnswerKey: 'a',
    );

    await eventsBox.close();
    eventsBox = await Hive.openBox<dynamic>('events');

    final reopenedRepository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );
    expect(eventsBox, hasLength(1));
    expect(reopenedRepository.scoreForQuestion('NA102'), 1);
  });

  test('projection caps progress at learned threshold', () async {
    final repository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );

    for (int attempt = 0; attempt < 5; attempt++) {
      await repository.recordAnswer(
        questionId: 'NA102',
        correct: true,
        selectedAnswerKey: 'a',
      );
    }

    expect(repository.scoreForQuestion('NA102'), 5);
    expect(repository.progressForQuestions(['NA102']), 1);
  });

  test('practice includes wrongly answered questions as seen', () async {
    final repository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );
    await repository.recordAnswer(
      questionId: 'NA102',
      correct: false,
      selectedAnswerKey: 'b',
    );

    final selector = PracticeQuestionSelector();
    expect(
      selector.nextQuestionId(
        courseQuestionIds: ['NA101', 'NA102'],
        repository: repository,
      ),
      'NA102',
    );
  });

  test('practice prefers in-progress questions and repeats learned ones',
      () async {
    final repository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );
    await repository.recordAnswer(
      questionId: 'NA101',
      correct: true,
      selectedAnswerKey: 'a',
    );
    for (var attempt = 0; attempt < 3; attempt++) {
      await repository.recordAnswer(
        questionId: 'NA102',
        correct: true,
        selectedAnswerKey: 'a',
      );
    }

    final selector = PracticeQuestionSelector();
    final selections = List.generate(
      5,
      (_) => selector.nextQuestionId(
        courseQuestionIds: ['NA101', 'NA102', 'NA103'],
        repository: repository,
      ),
    );
    expect(selections.take(4), everyElement('NA101'));
    expect(selections.last, 'NA102');
  });

  test('practice continues with learned questions after work is complete',
      () async {
    final repository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );
    for (var attempt = 0; attempt < 3; attempt++) {
      await repository.recordAnswer(
        questionId: 'NA102',
        correct: true,
        selectedAnswerKey: 'a',
      );
    }

    final selector = PracticeQuestionSelector();
    expect(
      selector.nextQuestionId(
        courseQuestionIds: ['NA101', 'NA102'],
        repository: repository,
      ),
      'NA102',
    );
  });

  test('legacy migration assumes the currently selected course', () async {
    await settingsBox.put('Klasse', [2]);
    await legacyProgressBox.put('[-1][0][0]', [2]);
    await legacyProgressBox.put('[0][0][0]', [1]);
    await legacyProgressBox.put('[-1][99][0]', [1]);

    final assets = <String, String>{
      LegacyProgressMigrator.legacySnapshotAsset: jsonEncode({
        'version': 1,
        'courses': {
          'E': {
            '[-1][0][0]': ['EA111'],
            '[0][0][0]': ['EA222'],
          },
        },
      }),
    };
    final repository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );
    final migrator = LegacyProgressMigrator(
      legacyProgressBox: legacyProgressBox,
      settingsBox: settingsBox,
      learningStateRepository: repository,
      loadAsset: (path) async => assets[path]!,
    );

    final result = await migrator.migrateIfNeeded();

    expect(result.selectedCourseAsset, 'assets/questions/E.json');
    expect(result.migratedEvents, 3);
    expect(result.unresolvedScores, 1);
    expect(repository.scoreForQuestion('EA111'), 2);
    expect(repository.scoreForQuestion('EA222'), 1);
    expect(repository.scoreForQuestion('NA102'), 0);

    final repeatedResult = await migrator.migrateIfNeeded();
    expect(repeatedResult.alreadyMigrated, isTrue);
    expect(eventsBox.length, 3);
  });

  test('real course assets migrate their first legacy position correctly',
      () async {
    final cases = <Set<int>, String>{
      {1}: 'NA102',
      {1, 2}: 'NA102',
      {1, 2, 3}: 'NA102',
      {2}: 'EA111',
      {3}: 'AH203',
      {2, 3}: 'EA111',
    };
    final legacySnapshot =
        await rootBundle.loadString(LegacyProgressMigrator.legacySnapshotAsset);

    for (final migrationCase in cases.entries) {
      await eventsBox.clear();
      await settingsBox.clear();
      await legacyProgressBox.clear();
      await settingsBox.put('Klasse', migrationCase.key.toList());
      await legacyProgressBox.put('[-1][0][0]', [1]);

      final repository = LearningStateRepository(
        eventsBox: eventsBox,
        settingsBox: settingsBox,
      );
      final migrator = LegacyProgressMigrator(
        legacyProgressBox: legacyProgressBox,
        settingsBox: settingsBox,
        learningStateRepository: repository,
        loadAsset: (path) async => legacySnapshot,
      );

      await migrator.migrateIfNeeded();

      expect(
        repository.scoreForQuestion(migrationCase.value),
        1,
        reason: 'Migration failed for classes ${migrationCase.key}',
      );
      expect(eventsBox.length, 1);
    }
  });

  test('legacy snapshot is complete and independent of current course files',
      () async {
    final snapshot = jsonDecode(await rootBundle
        .loadString(LegacyProgressMigrator.legacySnapshotAsset)) as Map;
    expect(snapshot['version'], 1);
    final courses = snapshot['courses'] as Map;

    expect(courses.keys.toSet(), {'N', 'E', 'NE', 'A', 'EA', 'NEA'});
    final expectedReferenceCounts = {
      'N': 1142,
      'E': 926,
      'NE': 2068,
      'A': 1432,
      'EA': 2358,
      'NEA': 3500,
    };
    for (final entry in expectedReferenceCounts.entries) {
      final referenceCount = (courses[entry.key] as Map)
          .values
          .whereType<List>()
          .fold<int>(0, (sum, ids) => sum + ids.length);
      expect(referenceCount, entry.value, reason: entry.key);
    }
    expect((courses['N'] as Map)['[-1][0][0]'][0], 'NA102');
    expect((courses['E'] as Map)['[-1][0][0]'][0], 'EA111');
    expect((courses['A'] as Map)['[-1][0][0]'][0], 'AH203');

    // A moved chapter in the current course must not affect the frozen map.
    final currentE = jsonDecode(
      await rootBundle.loadString('assets/questions/E.json'),
    );
    expect(_questionIds(currentE), contains('EA111'));
    expect((courses['E'] as Map)['[-1][0][0]'][0], 'EA111');
  });

  test('N progress is retained in N+E and N+E+A by stable question id',
      () async {
    final repository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );
    for (int attempt = 0; attempt < 3; attempt++) {
      await repository.recordAnswer(
        questionId: 'NA102',
        correct: true,
        selectedAnswerKey: 'a',
      );
    }
    await repository.recordAnswer(
      questionId: 'EA111',
      correct: true,
      selectedAnswerKey: 'a',
    );

    final nIds = _questionIds(
      jsonDecode(await rootBundle.loadString('assets/questions/N.json')),
    );
    final eIds = _questionIds(
      jsonDecode(await rootBundle.loadString('assets/questions/E.json')),
    );
    final neIds = _questionIds(
      jsonDecode(await rootBundle.loadString('assets/questions/NE.json')),
    );
    final neaIds = _questionIds(
      jsonDecode(await rootBundle.loadString('assets/questions/NEA.json')),
    );
    final catalogIds = _questionIds(
      jsonDecode(
        await rootBundle.loadString('assets/questions/Questions.json'),
      ),
    );

    expect(nIds, contains('NA102'));
    expect(eIds, isNot(contains('NA102')));
    expect(neIds, containsAll(['NA102', 'EA111']));
    expect(neaIds, contains('NA102'));
    expect(catalogIds, contains('NA102'));

    await settingsBox.put('Klasse', [2]);
    expect(
      repository.scoresForQuestions(eIds).where((score) => score > 0),
      hasLength(1),
    );

    await settingsBox.put('Klasse', [1]);
    expect(repository.scoreForQuestion('NA102'), 3);
    expect(repository.progressForQuestions(['NA102']), 1);
    expect(
      repository.scoresForQuestions(nIds).where((score) => score > 0),
      hasLength(1),
    );
    expect(
      repository.scoresForQuestions(neIds).where((score) => score > 0),
      hasLength(2),
    );
    expect(repository.scoresForQuestions(neaIds).where((score) => score > 0),
        hasLength(2));
    expect(
      repository.scoresForQuestions(catalogIds).where((score) => score > 0),
      hasLength(2),
    );
  });

  test('reset clears event and legacy learning state but keeps settings',
      () async {
    await settingsBox.put('Klasse', [1, 2, 3]);
    await settingsBox.put('learningStateMigrationV1', {'completed': true});
    await legacyProgressBox.put('[-1][0][0]', [3]);
    final repository = LearningStateRepository(
      eventsBox: eventsBox,
      settingsBox: settingsBox,
    );
    await repository.recordAnswer(
      questionId: 'NA102',
      correct: true,
      selectedAnswerKey: 'a',
    );
    expect(repository.scoreForQuestion('NA102'), 1);

    await resetLearningState(
      repository: repository,
      legacyProgressBox: legacyProgressBox,
    );

    expect(eventsBox, isEmpty);
    expect(legacyProgressBox, isEmpty);
    expect(repository.scoreForQuestion('NA102'), 0);
    expect(settingsBox.get('Klasse'), [1, 2, 3]);
    expect(settingsBox.get('learningStateMigrationV1'), {'completed': true});
  });
}

List<String> _questionIds(dynamic node) {
  final ids = <String>[];
  if (node is Map) {
    final number = node['number'];
    if (number is String) ids.add(number);
    for (final value in node.values) {
      ids.addAll(_questionIds(value));
    }
  } else if (node is List) {
    for (final value in node) {
      ids.addAll(_questionIds(value));
    }
  }
  return ids;
}
