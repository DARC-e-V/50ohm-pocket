import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fuenfzigohm/custom_libs/database.dart';
import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/learning/continuous_course.dart';
import 'package:fuenfzigohm/learning/continuous_learning_session.dart';
import 'package:fuenfzigohm/learning/learning_mode.dart';
import 'package:fuenfzigohm/learning_state/learning_state_repository.dart';
import 'package:fuenfzigohm/main.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/screens/continuous_learning.dart';
import 'package:fuenfzigohm/screens/question.dart';
import 'package:fuenfzigohm/screens/settings.dart';

class _MockBox extends Mock implements Box<dynamic> {}

Box<dynamic> memoryBox([Map<dynamic, dynamic>? initial]) {
  final data = <dynamic, dynamic>{...?initial};
  final box = _MockBox();
  when(() => box.get(any(), defaultValue: any(named: 'defaultValue')))
      .thenAnswer((invocation) =>
          data[invocation.positionalArguments.first] ??
          invocation.namedArguments[#defaultValue]);
  when(() => box.put(any(), any())).thenAnswer((invocation) async {
    data[invocation.positionalArguments[0]] = invocation.positionalArguments[1];
  });
  when(() => box.values).thenAnswer((_) => data.values);
  return box;
}

Map<String, dynamic> lesson(String title, String id) => {
      'title': title,
      'section': title.toLowerCase(),
      'questions': [
        {
          'number': id,
          'question': 'Welche Antwort ist richtig?',
          'answer_a': 'Richtig',
          'answer_b': 'Falsch B',
          'answer_c': 'Falsch C',
          'answer_d': 'Falsch D',
        },
      ],
    };

Map<String, dynamic> courseData() => {
      'title': 'Testkurs',
      'sections': [
        {
          'title': 'Erstes Kapitel',
          'sections': [
            lesson('Erste Lektion', 'NA101'),
            lesson('Zweite Lektion', 'NA102')
          ],
        },
        lesson('Nächstes Kapitel', 'NA103'),
      ],
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'existing mode preferences survive without opting into continuous learning',
      () async {
    final settings = memoryBox();
    expect(LearningMode.read(settings), LearningMode.course);
    await settings.put('courseOrdering', false);
    expect(LearningMode.read(settings), LearningMode.catalog);
    await LearningMode.continuous.save(settings);
    expect(LearningMode.read(settings), LearningMode.continuous);
    expect(settings.get('courseOrdering'), true);
    await LearningMode.catalog.save(settings);
    expect(LearningMode.read(settings), LearningMode.catalog);
    expect(settings.get('courseOrdering'), false);
  });

  for (final course in ['N', 'E', 'A', 'NE', 'EA', 'NEA']) {
    test('$course traverses exactly the selected course in lesson order',
        () async {
      final data = jsonDecode(
              await rootBundle.loadString('assets/questions/$course.json'))
          as Map<String, dynamic>;
      final lessons = continuousCourseLessons(data, course);
      final json = Json(data);
      final ids = [
        for (final lesson in lessons)
          ...json.getQuestionIds(lesson.chapter, lesson.subchapter),
      ];
      expect(ids, json.getAllQuestionIds(-1));
      expect(lessons, isNotEmpty);
      expect(lessons.every((lesson) => lesson.questionCount > 0), isTrue);
      expect(
          lessons.every((lesson) =>
              lesson.materialUrl.startsWith('https://50ohm.de/${course}_')),
          isTrue);
    });
  }

  test('empty lessons are skipped and direct questions retain their location',
      () {
    final data = courseData();
    (data['sections'] as List).insert(1, {'title': 'Leer', 'questions': []});
    final lessons = continuousCourseLessons(data, 'N');
    expect(lessons.map((lesson) => lesson.title),
        ['Erste Lektion', 'Zweite Lektion', 'Nächstes Kapitel']);
    expect(lessons.last.chapter, 2);
    expect(lessons.last.subchapter, isNull);
  });

  test('continue starts with unseen content or reviews the complete course',
      () {
    final data = courseData();
    final lessons = continuousCourseLessons(data, 'N');
    expect(continuousCourseEntryLesson(data, lessons, {}), 0);
    expect(continuousCourseEntryLesson(data, lessons, {'NA101'}), 1);
    expect(continuousCourseEntryLesson(data, lessons, {'NA101', 'NA102'}), 2);
    expect(
        continuousCourseEntryLesson(data, lessons, {'NA101', 'NA102', 'NA103'}),
        2);
    final firstQuestions =
        data['sections'][0]['sections'][0]['questions'] as List;
    firstQuestions.add({'number': 'NA104'});
    expect(continuousCourseEntryLesson(data, lessons, {'NA101'}), 0);
  });

  Future<LearningStateRepository> openCourse(WidgetTester tester,
      {int initialLesson = 0}) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final settings = memoryBox({
      'Klasse': [1],
      'courseOrdering': true
    });
    final repository =
        LearningStateRepository(eventsBox: memoryBox(), settingsBox: settings);
    final data = courseData();
    await tester.pumpWidget(DatabaseWidget(
      settings_database: settings,
      prog_database: memoryBox(),
      bookmarks_database: memoryBox(),
      learningStateRepository: repository,
      child: MaterialApp(
          home: ContinuousLearningPage(
        data: data,
        lessons: continuousCourseLessons(data, 'N'),
        initialLesson: initialLesson,
      )),
    ));
    return repository;
  }

  Future<void> answerCurrentQuestion(WidgetTester tester,
      {bool correct = true}) async {
    await tester.tap(find.text(correct ? 'Richtig' : 'Falsch B'));
    await tester.pump();
    await tester.tap(find.text('Überprüfen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
  }

  Future<void> answerLesson(WidgetTester tester, {bool correct = true}) async {
    await tester.tap(find.text('Fragen starten'));
    await tester.pumpAndSettle();
    await answerCurrentQuestion(tester, correct: correct);
  }

  testWidgets(
      'new lessons mix earlier questions until the three-answer threshold is met',
      (tester) async {
    final repository = await openCourse(tester);
    expect(find.text('Erste Lektion'), findsOneWidget);
    expect(find.text('Inhalte auf 50ohm.de lesen'), findsOneWidget);
    await answerLesson(tester, correct: false);
    expect(find.text('NA101'), findsOneWidget);
    expect(find.text('Wiederholung · Erste Lektion'), findsOneWidget);
    await answerCurrentQuestion(tester);
    expect(find.text('Zweite Lektion'), findsOneWidget);
    expect(find.byType(Question), findsNothing);
    expect(repository.answeredQuestionIds, {'NA101'});
    await answerLesson(tester);
    expect(find.text('NA101'), findsOneWidget);
    await answerCurrentQuestion(tester);
    expect(find.text('Nächstes Kapitel'), findsWidgets);
    await answerLesson(tester);
    expect(find.byType(Question), findsOneWidget);
    for (var attempt = 0;
        attempt < 30 && find.byType(Question).evaluate().isNotEmpty;
        attempt++) {
      await answerCurrentQuestion(tester);
    }
    expect(find.text('Du hast deine Lernrunde geschafft!'), findsOneWidget);
    expect(find.text('Fragen starten'), findsNothing);
    expect(repository.answeredQuestionIds, {'NA101', 'NA102', 'NA103'});
    expect(
        repository.scoresForQuestions(['NA101', 'NA102', 'NA103']).every(
            (score) => score >= 3),
        isTrue);
  });

  test(
      'mixed sessions introduce lessons before exposing their unseen questions',
      () async {
    final settings = memoryBox();
    final repository =
        LearningStateRepository(eventsBox: memoryBox(), settingsBox: settings);
    final data = courseData();
    final session = ContinuousLearningSession(
      data: data,
      lessons: continuousCourseLessons(data, 'N'),
      repository: repository,
      initialLesson: 0,
      random: Random(1),
    );
    expect(session.nextQuestion(), isNull);
    session.introduceLesson();
    expect(session.nextQuestion()!.questionId, 'NA101');
    expect(session.isReview, isFalse);
    await repository.recordAnswer(
        questionId: 'NA101', correct: false, selectedAnswerKey: 'b');
    expect(session.nextQuestion()!.questionId, 'NA101');
    expect(session.isReview, isTrue);
    await repository.recordAnswer(
        questionId: 'NA101', correct: true, selectedAnswerKey: 'a');
    expect(session.nextQuestion(), isNull);
    expect(session.lessonIndex, 1);
    expect(session.needsIntroduction, isTrue);
    expect(session.nextQuestion(), isNull);
    session.introduceLesson();
    expect(session.nextQuestion()!.questionId, 'NA102');
    expect(session.isReview, isFalse);
    await repository.recordAnswer(
        questionId: 'NA102', correct: false, selectedAnswerKey: 'b');
    expect(session.nextQuestion()!.questionId, 'NA101');
    expect(session.isReview, isTrue);
    expect(repository.scoreForQuestion('NA102'), 0);
  });

  test(
      'mixed sessions reuse existing scores and periodically reinforce learned questions',
      () async {
    final repository = LearningStateRepository(
        eventsBox: memoryBox(), settingsBox: memoryBox());
    for (final id in ['NA101', 'NA102', 'NA103', 'NA101', 'NA101']) {
      await repository.recordAnswer(
          questionId: id, correct: true, selectedAnswerKey: 'a');
    }
    final data = courseData();
    final session = ContinuousLearningSession(
      data: data,
      lessons: continuousCourseLessons(data, 'N'),
      repository: repository,
      initialLesson: 2,
      random: Random(1),
    );
    session.introduceLesson();
    final selected = <String>[];
    for (var index = 0; index < 20; index++) {
      selected.add(session.nextQuestion()!.questionId);
    }
    expect(selected.where((id) => id == 'NA101'), hasLength(4));
    expect(selected.toSet(), {'NA101', 'NA102', 'NA103'});
    for (var index = 1; index < selected.length; index++) {
      expect(selected[index], isNot(selected[index - 1]));
    }
    for (final id in ['NA102', 'NA103', 'NA102', 'NA103']) {
      await repository.recordAnswer(
          questionId: id, correct: true, selectedAnswerKey: 'a');
    }
    expect(session.nextQuestion(), isNull);
    expect(session.complete, isTrue);
  });

  testWidgets(
      'leaving an unfinished lesson does not advance or record an answer',
      (tester) async {
    final repository = await openCourse(tester, initialLesson: 1);
    expect(find.text('Zweite Lektion'), findsOneWidget);
    await tester.tap(find.text('Fragen starten'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton).last);
    await tester.pumpAndSettle();
    expect(find.text('Zweite Lektion'), findsOneWidget);
    expect(repository.answeredQuestionIds, isEmpty);
  });

  testWidgets('normal learning still shows the lesson summary', (tester) async {
    final data = courseData();
    final settings = memoryBox({
      'Klasse': [1]
    });
    await tester.pumpWidget(DatabaseWidget(
      settings_database: settings,
      prog_database: memoryBox(),
      bookmarks_database: memoryBox(),
      learningStateRepository: LearningStateRepository(
          eventsBox: memoryBox(), settingsBox: settings),
      child: MaterialApp(
        home: JsonWidget(
          Builder(builder: (context) => Question(context, [0], 0)),
          data,
          -1,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await answerCurrentQuestion(tester);
    expect(find.text('Du hast die Lektion geschafft!'), findsOneWidget);
    expect(find.text('Abschließen'), findsOneWidget);
  });

  testWidgets(
      'continuous mode opens the selected lesson from the course overview',
      (tester) async {
    final settings = memoryBox({
      'Klasse': [1],
      'learningMode': 'continuous'
    });
    await tester.pumpWidget(DatabaseWidget(
      settings_database: settings,
      prog_database: memoryBox(),
      bookmarks_database: memoryBox(),
      learningStateRepository: LearningStateRepository(
          eventsBox: memoryBox(), settingsBox: settings),
      child: MaterialApp(home: Learningmodule()),
    ));
    await tester.runAsync(() async {
      await rootBundle.loadString('assets/questions/N.json');
    });
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Der erste Schritt'));
    await tester.tap(find.text('Der erste Schritt'));
    await tester.pumpAndSettle();
    expect(find.byType(ContinuousLearningPage), findsOneWidget);
    expect(find.text('Der erste Schritt'), findsOneWidget);
    expect(find.text('Inhalte auf 50ohm.de lesen'), findsOneWidget);
  });

  Future<void> openOverview(WidgetTester tester, LearningMode mode,
      {bool firstLessonAnswered = false}) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final settings = memoryBox({
      'Klasse': [1],
      'learningMode': mode.name
    });
    final repository =
        LearningStateRepository(eventsBox: memoryBox(), settingsBox: settings);
    await tester.runAsync(() async {
      final data =
          jsonDecode(await rootBundle.loadString('assets/questions/N.json'))
              as Map<String, dynamic>;
      await rootBundle.loadString('assets/questions/Questions.json');
      if (firstLessonAnswered) {
        for (final id in Json(data).getQuestionIds(0, 0)) {
          await repository.recordAnswer(
              questionId: id, correct: false, selectedAnswerKey: 'b');
        }
      }
    });
    await tester.pumpWidget(DatabaseWidget(
      settings_database: settings,
      prog_database: memoryBox(),
      bookmarks_database: memoryBox(),
      learningStateRepository: repository,
      child: MaterialApp(home: Learningmodule()),
    ));
    await tester.runAsync(() async {
      await rootBundle.loadString('assets/questions/N.json');
      await rootBundle.loadString('assets/questions/Questions.json');
    });
    await tester.pumpAndSettle();
  }

  for (final mode in LearningMode.values) {
    testWidgets(
        'overview learning button is only available in continuous mode: ${mode.name}',
        (tester) async {
      await openOverview(tester, mode);
      if (mode != LearningMode.continuous) {
        expect(find.text('Lernen starten'), findsNothing);
        expect(find.text('Weiterlernen'), findsNothing);
        return;
      }
      expect(find.text('Lernen starten'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Lernen starten')).dy,
          lessThan(tester.getTopLeft(find.text('Erste Schritte')).dy));
      await tester.tap(find.text('Lernen starten'));
      await tester.pumpAndSettle();
      expect(find.byType(ContinuousLearningPage), findsOneWidget);
      expect(find.text('Der erste Schritt'), findsOneWidget);
    });
  }

  testWidgets(
      'continue button resumes after seen content including wrong answers',
      (tester) async {
    await openOverview(tester, LearningMode.continuous,
        firstLessonAnswered: true);
    expect(find.text('Weiterlernen'), findsOneWidget);
    await tester.tap(find.text('Weiterlernen'));
    await tester.pumpAndSettle();
    expect(find.text('Rufzeichen'), findsOneWidget);
    expect(find.textContaining('Lektion 2 von '), findsOneWidget);
  });

  testWidgets('settings offer and persist all three learning modes',
      (tester) async {
    final settings = memoryBox({'courseOrdering': false});
    final fontScale = ValueNotifier(1.0);
    final themeMode = ValueNotifier(ThemeMode.system);
    addTearDown(fontScale.dispose);
    addTearDown(themeMode.dispose);
    await tester.pumpWidget(DatabaseWidget(
      settings_database: settings,
      prog_database: memoryBox(),
      bookmarks_database: memoryBox(),
      learningStateRepository: LearningStateRepository(
          eventsBox: memoryBox(), settingsBox: settings),
      child: AppSettingsScope(
        fontScaleNotifier: fontScale,
        themeModeNotifier: themeMode,
        onFontScaleChanged: (_) {},
        onThemeModeChanged: (_) {},
        child: MaterialApp(home: Settingspage()),
      ),
    ));
    for (final mode in [
      LearningMode.continuous,
      LearningMode.course,
      LearningMode.catalog
    ]) {
      await tester.ensureVisible(find.text('Lernmodus'));
      await tester.tap(find.text('Lernmodus'));
      await tester.pumpAndSettle();
      expect(find.byType(RadioListTile<LearningMode>), findsNWidgets(3));
      await tester
          .tap(find.widgetWithText(RadioListTile<LearningMode>, mode.label));
      await tester.pumpAndSettle();
      expect(LearningMode.read(settings), mode);
    }
  });
}
