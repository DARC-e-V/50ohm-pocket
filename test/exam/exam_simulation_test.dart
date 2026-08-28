import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fuenfzigohm/exam/exam_simulation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog exposes enough questions for every official exam part',
      () async {
    final raw = await rootBundle.loadString('assets/questions/Questions.json');
    final catalog = buildExamCatalog(
      jsonDecode(raw) as Map<String, dynamic>,
    );

    expect(catalog.map((question) => question.id).toSet(), hasLength(1750));
    for (final part in examPartDefinitions.keys) {
      expect(
        catalog.where((question) => question.part == part).length,
        greaterThanOrEqualTo(examQuestionCount),
        reason: 'Not enough questions for part $part',
      );
    }
  });

  test('all official simulations contain 25 unique questions per part',
      () async {
    final raw = await rootBundle.loadString('assets/questions/Questions.json');
    final catalog = buildExamCatalog(
      jsonDecode(raw) as Map<String, dynamic>,
    );

    for (final choice in examChoices) {
      final parts = ExamBuilder(random: Random(42)).build(catalog, choice);
      expect(parts.map((part) => part.definition.code), choice.parts);
      for (final part in parts) {
        expect(part.questions, hasLength(examQuestionCount));
        expect(
          part.questions.map((question) => question.question.id).toSet(),
          hasLength(examQuestionCount),
          reason: '${choice.id}/${part.definition.code}',
        );
        expect(
          part.questions.every(
            (question) =>
                question.question.part == part.definition.code &&
                question.answerOrder.toSet().length == 4,
          ),
          isTrue,
        );
      }
    }
  });

  test('overall result follows the 50ohm.de passing and oral rules', () {
    ExamPartResult result(int score) {
      final part = ExamPartResult(
        definition: examPartDefinitions['N']!,
        questions: const [],
      );
      part.score = score;
      return part;
    }

    expect(
      evaluateExam([result(19), result(25)]),
      ExamOverallState.passed,
    );
    expect(
      evaluateExam([result(18), result(25)]),
      ExamOverallState.oral,
    );
    expect(
      evaluateExam([result(18), result(18)]),
      ExamOverallState.failed,
    );
    expect(
      evaluateExam([result(16), result(25)]),
      ExamOverallState.failed,
    );
  });

  test('share URL uses the exact 50ohm.de result schema', () {
    final choice = examChoices.first;
    final scores = [20, 21, 23].map((score) {
      final part = ExamPartResult(
        definition: examPartDefinitions['N']!,
        questions: const [],
      );
      part.score = score;
      return part;
    }).toList();

    expect(encodedExamResult(choice, scores), '1.N.20.21.23');
    expect(
      examResultUri(choice, scores).toString(),
      'https://50ohm.de/result-nbv.html?result=1.N.20.21.23',
    );
    expect(examShareText(choice, scores), contains('bestanden!'));
  });
}
