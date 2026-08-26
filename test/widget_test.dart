import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fuenfzigohm/constants.dart';
import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/custom_libs/solution_index.dart';
import 'package:fuenfzigohm/custom_libs/video_index.dart';
import 'package:fuenfzigohm/exam/exam_simulation.dart';
import 'package:fuenfzigohm/repository/models/course_class.dart';
import 'package:fuenfzigohm/repository/setting_repository.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/screens/exam_simulation.dart';
import 'package:fuenfzigohm/screens/practice.dart';
import 'package:fuenfzigohm/screens/question.dart';
import 'package:fuenfzigohm/screens/question_search.dart';
import 'package:fuenfzigohm/ui/welcome/bloc/welcome_bloc.dart';
import 'package:fuenfzigohm/ui/welcome/pages/welcome_layout.dart';
import 'package:fuenfzigohm/widgets/progress_overview_bar.dart';

class _MockSettingRepository extends Mock implements SettingRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('course selection shows all six courses on one page',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    expect(
      completeCourseOptions.map((option) => option.course),
      [
        CourseClass.COURSE_CLASS_N,
        CourseClass.COURSE_CLASS_NE,
        CourseClass.COURSE_CLASS_NEA,
      ],
    );
    expect(
      upgradeCourseOptions.map((option) => option.course),
      [
        CourseClass.COURSE_CLASS_E,
        CourseClass.COURSE_CLASS_EA,
        CourseClass.COURSE_CLASS_A,
      ],
    );

    final repository = _MockSettingRepository();
    when(() => repository.courseClass).thenReturn({});
    when(() => repository.setCourseClass(any())).thenAnswer((_) async {});
    when(() => repository.setShowWelcomeScreen(any())).thenAnswer((_) async {});
    final bloc = WelcomeBloc(settingRepository: repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: const WelcomeCourseSelection(),
        ),
      ),
    );

    expect(
        find.text('Lernen auf 50ohm.de. Üben, wo du willst.'), findsOneWidget);
    expect(find.textContaining('in der Bahn'), findsOneWidget);
    expect(find.text('Kurs auswählen'), findsNothing);
    expect(find.text('Gesamtkurse'), findsOneWidget);
    expect(find.text('Aufbaukurse'), findsOneWidget);
    expect(find.textContaining('noch kein Amateurfunkzeugnis'), findsOneWidget);
    expect(find.textContaining('Klasse N oder E'), findsOneWidget);
    for (final label in [
      'N',
      'N + E',
      'N + E + A',
      'N → E',
      'N → A',
      'E → A'
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.scrollUntilVisible(find.text('N → A'), 400);
    await tester.tap(find.text('N → A'));
    await tester.pump();
    verify(() => repository.setCourseClass(CourseClass.COURSE_CLASS_EA))
        .called(1);
  });

  testWidgets('course selection returns to settings without losing setup',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _MockSettingRepository();
    when(() => repository.courseClass).thenReturn({1});
    when(() => repository.setShowWelcomeScreen(any())).thenAnswer((_) async {});
    final bloc = WelcomeBloc(settingRepository: repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/course-selection',
        routes: {
          '/': (_) => const Scaffold(body: Text('Einstellungen')),
          '/course-selection': (_) => BlocProvider.value(
                value: bloc,
                child: const Scaffold(body: WelcomeCourseSelection()),
              ),
        },
      ),
    );

    await tester.scrollUntilVisible(find.text('Zurück'), 500);
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();

    verify(() => repository.setShowWelcomeScreen(true)).called(1);
    expect(find.text('Einstellungen'), findsOneWidget);
  });

  testWidgets('practice intro explains the open-ended exercise',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PracticePage()),
    );

    expect(find.text('Übungsrunde'), findsOneWidget);
    expect(find.textContaining('bereits beantwortet'), findsOneWidget);
    expect(find.textContaining('sofort gespeichert'), findsOneWidget);
    expect(find.text('Übung starten'), findsOneWidget);
  });

  test('question search finds questions by number only', () async {
    final raw =
        await rootBundle.loadString('assets/questions/Questions.json');
    final catalog = jsonDecode(raw) as Map<String, dynamic>;
    final questions = buildQuestionSearchIndex(catalog);

    expect(questions, hasLength(1750));
    expect(
      searchQuestionNumbers(questions, 'na 103')
          .map((question) => question.questionId),
      ['NA103'],
    );
    expect(
      searchQuestionNumbers(questions, '103')
          .map((question) => question.questionId),
      contains('NA103'),
    );
  });

  testWidgets('exam simulation offers all official exam variants',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: ExamSimulationPage(initialCatalog: []),
      ),
    );

    expect(find.text('Erstprüfung'), findsOneWidget);
    expect(find.text('Aufstockungsprüfung'), findsOneWidget);
    expect(find.text('Einzelne Prüfungsteile'), findsOneWidget);
    expect(find.text('Klasse N'), findsOneWidget);
    expect(find.text('N → E'), findsOneWidget);
    expect(find.text('Technik Klasse A'), findsOneWidget);
  });

  testWidgets('exam review uses training feedback and shows solution hint',
      (tester) async {
    await SolutionIndex.load(
      loadAsset: (_) async => '{"question_ids":["AB101"]}',
    );
    await VideoIndex.load(
      loadAsset: (_) async =>
          '{"question_urls":{"AB101":"https://www.youtube.com/watch?v=test&t=12s"}}',
    );
    final result = ExamQuestionResult(
      question: const ExamCatalogQuestion(
        id: 'AB101',
        part: 'A',
        category: [],
        data: {
          'question': 'Testfrage',
          'answer_a': 'Richtige Antwort',
          'answer_b': 'Falsche Antwort',
          'answer_c': 'Antwort C',
          'answer_d': 'Antwort D',
        },
      ),
      answerOrder: const [0, 1, 2, 3],
      selectedAnswer: 1,
    );

    await tester.pumpWidget(
      MaterialApp(home: ExamReviewPage(result: result)),
    );

    expect(find.byTooltip('Lösungshinweis auf 50ohm.de'), findsOneWidget);
    expect(find.byTooltip('Lernvideo von DL2YMR'), findsOneWidget);
    expect(find.text('AB101'), findsOneWidget);
    expect(find.text('Frage AB101'), findsNothing);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.check_circle)).color,
      Colors.green.shade800,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.cancel)).color,
      Colors.red.shade800,
    );
    expect(
      tester
          .widgetList<Container>(find.byType(Container))
          .where((container) => container.color == correctFeedbackColor),
      hasLength(1),
    );
    expect(
      tester
          .widgetList<Container>(find.byType(Container))
          .where((container) => container.color == incorrectFeedbackColor),
      hasLength(1),
    );
  });

  testWidgets('wrongly answered questions count as in progress',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProgressOverviewCard(
            questionScores: [0, 0, 1, 2, 3],
            answeredQuestions: [false, true, true, true, true],
          ),
        ),
      ),
    );

    expect(find.text('Gelernt: 1'), findsOneWidget);
    expect(find.text('In Arbeit: 3'), findsOneWidget);
    expect(find.text('Offen: 1'), findsOneWidget);
    expect(find.byTooltip(learningProgressExplanation), findsOneWidget);

    await tester.tap(find.text('Lernstand'));
    await tester.pump();
    expect(find.text(learningProgressExplanation), findsOneWidget);
  });

  testWidgets('long formulas wrap inside the available answer width',
      (tester) async {
    const availableWidth = 280.0;
    final formulaKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            key: formulaKey,
            width: availableWidth,
            child: Text.rich(
              TextSpan(
                children: parseTextWithMath(
                  r'$P_{\textrm{ERP}} = (P_{\textrm{Sender}} - '
                  r'P_{\textrm{Verluste}}) \cdot G_{\textrm{Antenne}}$ '
                  'bezogen auf einen Halbwellendipol',
                  const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Math), findsAtLeastNWidgets(2));
    final availableRight = tester.getTopRight(find.byKey(formulaKey)).dx;
    for (final math in find.byType(Math).evaluate()) {
      expect(
        tester.getTopRight(find.byWidget(math.widget)).dx,
        lessThanOrEqualTo(availableRight + 0.01),
      );
    }
    expect(tester.takeException(), isNull);
  });

  test('lesson list maps all chapters without skipping or exceeding bounds',
      () {
    final json = Json({
      'sections': List.generate(14, (index) => {'title': 'Chapter $index'}),
    });
    final chapterCount = json.mainchaptersize() as int;
    final itemCount = lessonListItemCount(chapterCount);

    final chapterIndexes = [
      for (int itemIndex = lessonListHeaderItemCount;
          itemIndex < itemCount;
          itemIndex++)
        lessonChapterIndex(itemIndex),
    ];

    expect(itemCount, 16);
    expect(chapterIndexes, List.generate(14, (index) => index));
    expect(chapterIndexes.first, 0);
    expect(chapterIndexes.last, 13);
  });

  test('free learning pages use regulations, operation, technique order', () {
    expect(
      freeLearningMainChaptersForClasses({1}),
      [2, 1, 0],
    );
    expect(freeLearningSwipeHintForClasses({1}, 0), contains('links'));
    expect(
      freeLearningSwipeHintForClasses({1}, 0),
      contains('Betriebsfragen'),
    );
    expect(freeLearningSwipeHintForClasses({1}, 1), contains('rechts'));
    expect(freeLearningSwipeHintForClasses({1}, 1), contains('links'));
    expect(
      freeLearningSwipeHintForClasses({1}, 1),
      contains('Vorschriftsfragen'),
    );
    expect(
      freeLearningSwipeHintForClasses({1}, 1),
      contains('technischen Fragen'),
    );
    expect(freeLearningSwipeHintForClasses({1}, 2), contains('rechts'));
    expect(
      freeLearningSwipeHintForClasses({1}, 2),
      contains('Betriebsfragen'),
    );
  });

  test('free learning overview merges all catalog parts of the course',
      () async {
    final rawCatalog =
        await rootBundle.loadString('assets/questions/Questions.json');
    final expectedQuestionIds = <String>{};

    for (final mainChapter in freeLearningMainChaptersForClasses({1})) {
      final catalog = jsonDecode(rawCatalog) as Map<String, dynamic>;
      final section =
          (catalog['sections'] as List)[mainChapter] as Map<String, dynamic>;
      filterQuestionSections(section, {1});
      expectedQuestionIds.addAll(Json(section).getAllQuestionIds(mainChapter));
    }

    final mergedQuestionIds = freeLearningOverviewQuestionIds(
      jsonDecode(rawCatalog) as Map<String, dynamic>,
      {1},
    );

    expect(mergedQuestionIds.toSet(), expectedQuestionIds);
    expect(mergedQuestionIds, hasLength(expectedQuestionIds.length));
  });

  test('free learning upgrades show only their technical additions', () {
    for (final course in <Set<int>>[
      {2},
      {3},
      {2, 3},
    ]) {
      expect(freeLearningMainChaptersForClasses(course), [0]);
      expect(freeLearningSwipeHintForClasses(course, 0), isNull);
    }
  });

  test('question filter supports direct and nested question sections', () {
    final data = <String, dynamic>{
      'sections': [
        {
          'title': 'Direct',
          'questions': [
            {'class': '1'},
            {'class': '2'},
          ],
        },
        {
          'title': 'Nested',
          'sections': [
            {
              'title': 'Keep',
              'questions': [
                {'class': '1'},
              ],
            },
            {
              'title': 'Remove',
              'questions': [
                {'class': '2'},
              ],
            },
          ],
        },
        {
          'title': 'Remove direct',
          'questions': [
            {'class': '2'},
          ],
        },
      ],
    };

    filterQuestionSections(data, {1});

    final sections = data['sections'] as List;
    expect(sections, hasLength(2));
    expect((sections[0]['questions'] as List), hasLength(1));
    expect((sections[1]['sections'] as List), hasLength(1));
  });

  test('direct chapter questions are counted without fake subchapters', () {
    final json = Json({
      'sections': [
        {
          'title': 'Direct',
          'questions': [
            {'class': '1'},
            {'class': '1'},
          ],
        },
      ],
    });

    expect(json.chaptersize(0), 0);
    expect(json.chapterQuestionCount(0), 2);
    expect(json.getTotalQuestionCount(0), 2);
    expect(isDirectQuestionChapter(json, 0), isTrue);
    expect(lessonRowCount(json, 0), 1);
    expect(lessonRowTitle(json, 0, 0), 'Direct');
    expect(json.getAllQuestionKeys(1), [
      [1, 0, -1, 0],
      [1, 0, -1, 1],
    ]);
  });

  test('real catalog loads all free learning pages', () async {
    final rawCatalog =
        await rootBundle.loadString('assets/questions/Questions.json');
    final catalog = jsonDecode(rawCatalog) as Map<String, dynamic>;

    for (final mainChapter in fullCatalogMainChapters) {
      final section =
          (catalog['sections'] as List)[mainChapter] as Map<String, dynamic>;
      filterQuestionSections(section, {1, 2, 3});

      final json = Json(section);
      expect(json.mainchaptersize(), greaterThan(0));
      expect(json.getAllQuestionKeys(mainChapter), isNotEmpty);
    }
  });

  test('real catalog is non-empty on every page exposed for a course',
      () async {
    final rawCatalog =
        await rootBundle.loadString('assets/questions/Questions.json');
    final selectableCourses = <Set<int>>[
      {1},
      {2},
      {1, 2},
      {3},
      {2, 3},
      {1, 2, 3},
    ];

    for (final course in selectableCourses) {
      for (final mainChapter in freeLearningMainChaptersForClasses(course)) {
        final catalog = jsonDecode(rawCatalog) as Map<String, dynamic>;
        final section =
            (catalog['sections'] as List)[mainChapter] as Map<String, dynamic>;
        filterQuestionSections(section, course);

        final json = Json(section);
        expect(
          json.getAllQuestionIds(mainChapter),
          isNotEmpty,
          reason: 'Empty catalog page $mainChapter for course $course',
        );
      }
    }
  });

  test('upgrade catalog contains exactly the selected additional classes',
      () async {
    final rawCatalog =
        await rootBundle.loadString('assets/questions/Questions.json');
    final cases = [
      (classes: <int>{2}, expectedQuestions: 463),
      (classes: <int>{3}, expectedQuestions: 716),
      (classes: <int>{2, 3}, expectedQuestions: 1179),
    ];

    for (final testCase in cases) {
      final catalog = jsonDecode(rawCatalog) as Map<String, dynamic>;
      final technique =
          (catalog['sections'] as List)[0] as Map<String, dynamic>;
      filterQuestionSections(technique, testCase.classes);

      expect(
        Json(technique).getAllQuestionIds(0),
        hasLength(testCase.expectedQuestions),
      );
    }
  });

  test('current guided courses contain exactly their indexed question sets',
      () async {
    final expectedCounts = {
      'N': 571,
      'E': 462,
      'NE': 1033,
      'A': 717,
      'EA': 1179,
      'NEA': 1750,
    };

    for (final entry in expectedCounts.entries) {
      final course = jsonDecode(
        await rootBundle.loadString('assets/questions/${entry.key}.json'),
      );
      final ids = _allQuestionIds(course);
      expect(ids, hasLength(entry.value), reason: entry.key);
      expect(ids.toSet(), hasLength(entry.value), reason: entry.key);
    }

    final aCourse = jsonDecode(
      await rootBundle.loadString('assets/questions/A.json'),
    );
    final aQuestions = _questionsById(aCourse);
    expect(aQuestions['EI303']?['class'], '2');
  });

  test('solution availability is bundled for every question view', () async {
    await SolutionIndex.load();
    expect(SolutionIndex.hasSolution('AB101'), isTrue);
    expect(SolutionIndex.hasSolution('AB103'), isFalse);
    expect(SolutionIndex.urlFor('AB101'), 'https://50ohm.de/AB101.html');
  });

  test('video availability is bundled for every question view', () async {
    await VideoIndex.load();
    expect(VideoIndex.hasVideo('NA103'), isTrue);
    expect(VideoIndex.hasVideo('AB101'), isFalse);
    expect(
      VideoIndex.urlFor('NA103'),
      'https://www.youtube.com/watch?v=WnOBk1UogjM&t=0s',
    );
  });
}

List<String> _allQuestionIds(dynamic node) {
  final ids = <String>[];

  void visit(dynamic value) {
    if (value is Map) {
      if (value['number'] is String) ids.add(value['number'] as String);
      for (final child in value.values) {
        visit(child);
      }
    } else if (value is List) {
      for (final child in value) {
        visit(child);
      }
    }
  }

  visit(node);
  return ids;
}

Map<String, Map> _questionsById(dynamic node) {
  final questions = <String, Map>{};

  void visit(dynamic value) {
    if (value is Map) {
      if (value['number'] is String) {
        questions[value['number'] as String] = value;
      }
      for (final child in value.values) {
        visit(child);
      }
    } else if (value is List) {
      for (final child in value) {
        visit(child);
      }
    }
  }

  visit(node);
  return questions;
}
