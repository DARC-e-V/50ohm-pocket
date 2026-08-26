import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fuenfzigohm/learning_state/answer_event.dart';
import 'package:fuenfzigohm/learning_state/learning_state_repository.dart';
import 'package:fuenfzigohm/learning_state/legacy_progress_migrator.dart';

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

  test('legacy migration assumes the currently selected course', () async {
    await settingsBox.put('Klasse', [2]);
    await legacyProgressBox.put('[-1][0][0]', [2]);
    await legacyProgressBox.put('[0][0][0]', [1]);
    await legacyProgressBox.put('[-1][99][0]', [1]);

    final assets = <String, String>{
      'assets/questions/E.json': jsonEncode({
        'sections': [
          {
            'title': 'E chapter',
            'sections': [
              {
                'title': 'E subchapter',
                'questions': [
                  {'number': 'EA111', 'class': '2'},
                ],
              },
            ],
          },
        ],
      }),
      'assets/questions/Questions.json': jsonEncode({
        'sections': [
          {
            'title': 'Technique',
            'sections': [
              {
                'title': 'Chapter',
                'sections': [
                  {
                    'title': 'Subchapter',
                    'questions': [
                      {'number': 'EA222', 'class': '2'},
                    ],
                  },
                ],
              },
            ],
          },
          {'title': 'Operation', 'sections': []},
          {'title': 'Regulations', 'sections': []},
        ],
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
    final assetCache = <String, String>{};

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
        loadAsset: (path) async => assetCache[path]!,
      );

      // Populate the cache before migration so the injected loader stays
      // synchronous and each large catalog asset is read only once.
      final selectedAsset = _assetForClasses(migrationCase.key);
      assetCache[selectedAsset] ??= await rootBundle.loadString(selectedAsset);
      assetCache['assets/questions/Questions.json'] ??=
          await rootBundle.loadString('assets/questions/Questions.json');

      await migrator.migrateIfNeeded();

      expect(
        repository.scoreForQuestion(migrationCase.value),
        1,
        reason: 'Migration failed for classes ${migrationCase.key}',
      );
      expect(eventsBox.length, 1);
    }
  });

  test('switching courses projects only matching stable question ids',
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

    final nIds = _questionIds(
      jsonDecode(await rootBundle.loadString('assets/questions/N.json')),
    );
    final eIds = _questionIds(
      jsonDecode(await rootBundle.loadString('assets/questions/E.json')),
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
    expect(neaIds, contains('NA102'));
    expect(catalogIds, contains('NA102'));

    await settingsBox.put('Klasse', [2]);
    expect(repository.scoresForQuestions(eIds).where((score) => score > 0),
        isEmpty);

    await settingsBox.put('Klasse', [1]);
    expect(repository.scoreForQuestion('NA102'), 3);
    expect(repository.progressForQuestions(['NA102']), 1);
    expect(repository.scoresForQuestions(neaIds).where((score) => score > 0),
        hasLength(1));
    expect(
      repository.scoresForQuestions(catalogIds).where((score) => score > 0),
      hasLength(1),
    );
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

String _assetForClasses(Set<int> classes) {
  final sorted = classes.toList()..sort();
  return switch (sorted.join(',')) {
    '1' => 'assets/questions/N.json',
    '1,2' => 'assets/questions/NE.json',
    '1,2,3' => 'assets/questions/NEA.json',
    '2' => 'assets/questions/E.json',
    '3' => 'assets/questions/A.json',
    '2,3' => 'assets/questions/EA.json',
    _ => throw ArgumentError.value(classes),
  };
}
