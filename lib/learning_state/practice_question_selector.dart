import 'dart:math';

import 'learning_state_repository.dart';

/// Selects questions that have already been answered at least once.
///
/// Questions below the learned threshold are preferred. If both pools are
/// available, every fifth selection comes from the learned pool so learned
/// material is repeated without displacing questions that are still in work.
class PracticeQuestionSelector {
  static const int learnedThreshold = 3;

  final Random _random;
  int _selectionCount = 0;

  PracticeQuestionSelector({Random? random}) : _random = random ?? Random();

  String? nextQuestionId({
    required Iterable<String> courseQuestionIds,
    required LearningStateRepository repository,
    String? previousQuestionId,
  }) {
    final seenIds = repository.answeredQuestionIds;
    final inProgress = <String>[];
    final learned = <String>[];

    for (final questionId in courseQuestionIds) {
      if (!seenIds.contains(questionId)) continue;
      if (repository.scoreForQuestion(questionId) >= learnedThreshold) {
        learned.add(questionId);
      } else {
        inProgress.add(questionId);
      }
    }

    if (inProgress.isEmpty && learned.isEmpty) return null;

    final useLearned = learned.isNotEmpty &&
        (inProgress.isEmpty || (_selectionCount + 1) % 5 == 0);
    _selectionCount++;
    var pool = useLearned ? learned : inProgress;
    if (pool.length == 1 &&
        pool.single == previousQuestionId &&
        (useLearned ? inProgress : learned).isNotEmpty) {
      pool = useLearned ? inProgress : learned;
    }
    final candidates = pool.length > 1 && previousQuestionId != null
        ? pool.where((id) => id != previousQuestionId).toList()
        : pool;
    return candidates[_random.nextInt(candidates.length)];
  }
}
