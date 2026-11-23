import 'dart:math';

import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/learning/continuous_course.dart';
import 'package:fuenfzigohm/learning_state/learning_state_repository.dart';
import 'package:fuenfzigohm/learning_state/practice_question_selector.dart';

/// Introduces lessons in course order, interleaving new questions with reviews.
/// Reviews use the same three-correct-answer threshold as normal practice.
class ContinuousLearningSession {
  ContinuousLearningSession({
    required Map<String, dynamic> data,
    required this.lessons,
    required this.repository,
    required int initialLesson,
    Random? random,
  })  : lessonIndex = initialLesson,
        _random = random ?? Random() {
    _reviews = PracticeQuestionSelector(random: _random);
    final references = Json(data).getQuestionReferences(-1);
    _questions = [
      for (final lesson in lessons)
        references
            .where((reference) =>
                reference.chapter == lesson.chapter &&
                reference.subchapter == lesson.subchapter)
            .toList(),
    ];
  }

  final List<CourseLesson> lessons;
  final LearningStateRepository repository;
  final Random _random;
  late final PracticeQuestionSelector _reviews;
  late final List<List<QuestionReference>> _questions;
  int lessonIndex;
  bool needsIntroduction = true;
  bool complete = false;
  bool isReview = false;
  bool _reviewDue = false;
  String? _previousQuestionId;

  void introduceLesson() => needsIntroduction = false;

  List<QuestionReference> _reviewQuestions(Set<String> answeredIds) => [
        for (var index = 0; index <= lessonIndex; index++)
          ..._questions[index]
              .where((reference) => answeredIds.contains(reference.questionId)),
      ];

  QuestionReference _nextReview(
      List<QuestionReference> available, String? previousQuestionId) {
    isReview = true;
    final id = _reviews.nextQuestionId(
      courseQuestionIds: available.map((reference) => reference.questionId),
      repository: repository,
      previousQuestionId: previousQuestionId,
    );
    final reference =
        available.firstWhere((reference) => reference.questionId == id);
    _previousQuestionId = reference.questionId;
    return reference;
  }

  /// Null pauses the question screen for an introduction or the course result.
  QuestionReference? nextQuestion({String? previousQuestionId}) {
    if (needsIntroduction || complete) return null;
    previousQuestionId ??= _previousQuestionId;
    final answeredIds = repository.answeredQuestionIds;
    final reviews = _reviewQuestions(answeredIds);
    if (_reviewDue && reviews.isNotEmpty) {
      _reviewDue = false;
      return _nextReview(reviews, previousQuestionId);
    }

    final unseen = _questions[lessonIndex]
        .where((reference) => !answeredIds.contains(reference.questionId))
        .toList();
    if (unseen.isNotEmpty) {
      isReview = false;
      _reviewDue = true;
      final reference = unseen[_random.nextInt(unseen.length)];
      _previousQuestionId = reference.questionId;
      return reference;
    }

    if (lessonIndex + 1 < lessons.length) {
      lessonIndex++;
      needsIntroduction = true;
      _reviewDue = false;
      return null;
    }

    if (reviews.every((reference) =>
        repository.scoreForQuestion(reference.questionId) >=
        PracticeQuestionSelector.learnedThreshold)) {
      complete = true;
      return null;
    }
    return _nextReview(reviews, previousQuestionId);
  }
}
