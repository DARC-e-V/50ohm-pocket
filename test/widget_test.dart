import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/custom_libs/solution_index.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/screens/practice.dart';
import 'package:fuenfzigohm/widgets/progress_overview_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
