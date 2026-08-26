import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
