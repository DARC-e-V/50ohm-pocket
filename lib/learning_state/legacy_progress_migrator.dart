import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';

import 'learning_state_repository.dart';

typedef AssetStringLoader = Future<String> Function(String path);

class LegacyMigrationResult {
  final bool alreadyMigrated;
  final int migratedEvents;
  final int unresolvedScores;
  final String selectedCourseAsset;

  const LegacyMigrationResult({
    required this.alreadyMigrated,
    required this.migratedEvents,
    required this.unresolvedScores,
    required this.selectedCourseAsset,
  });
}

class LegacyProgressMigrator {
  static const String migrationSettingsKey = 'learningStateMigrationV1';
  static const String legacySnapshotAsset = 'assets/questions/legacy_v1.json';

  final Box<dynamic> legacyProgressBox;
  final Box<dynamic> settingsBox;
  final LearningStateRepository learningStateRepository;
  final AssetStringLoader loadAsset;

  LegacyProgressMigrator({
    required this.legacyProgressBox,
    required this.settingsBox,
    required this.learningStateRepository,
    AssetStringLoader? loadAsset,
  }) : loadAsset = loadAsset ?? rootBundle.loadString;

  Future<LegacyMigrationResult> migrateIfNeeded() async {
    final selectedClasses = _selectedClasses();
    final selectedCourseAsset = _courseAssetFor(selectedClasses);
    final migrationState = settingsBox.get(migrationSettingsKey);
    if (migrationState is Map && migrationState['completed'] == true) {
      return LegacyMigrationResult(
        alreadyMigrated: true,
        migratedEvents: 0,
        unresolvedScores: 0,
        selectedCourseAsset: selectedCourseAsset,
      );
    }

    final snapshot = jsonDecode(await loadAsset(legacySnapshotAsset)) as Map;
    final courses = snapshot['courses'] as Map;
    final rawReferences = courses[_courseIdFor(selectedClasses)] as Map;
    final referencesByLegacyKey = rawReferences.map(
      (key, value) => MapEntry(
        key.toString(),
        (value as List).map((questionId) => questionId.toString()).toList(),
      ),
    );

    int migratedEvents = 0;
    int unresolvedScores = 0;

    for (final legacyKey in legacyProgressBox.keys.whereType<String>()) {
      final rawScores = legacyProgressBox.get(legacyKey);
      if (rawScores is! List) continue;

      final questionIds = referencesByLegacyKey[legacyKey] ?? const [];
      for (int questionIndex = 0;
          questionIndex < rawScores.length;
          questionIndex++) {
        final rawScore = rawScores[questionIndex];
        final score = rawScore is num ? rawScore.toInt() : 0;
        if (score <= 0) continue;

        if (questionIndex >= questionIds.length) {
          unresolvedScores += score;
          continue;
        }
        final questionId = questionIds[questionIndex];

        for (int attempt = 0; attempt < score; attempt++) {
          final eventId = _legacyEventId(
            legacyKey: legacyKey,
            questionIndex: questionIndex,
            questionId: questionId,
            attempt: attempt,
          );
          final inserted =
              await learningStateRepository.recordLegacyCorrectAnswer(
            eventId: eventId,
            questionId: questionId,
            legacySourceKey: '$legacyKey[$questionIndex]',
          );
          if (inserted) migratedEvents++;
        }
      }
    }

    await settingsBox.put(migrationSettingsKey, {
      'completed': true,
      'completedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'selectedClasses': selectedClasses.toList()..sort(),
      'selectedCourseAsset': selectedCourseAsset,
      'migratedEvents': migratedEvents,
      'unresolvedScores': unresolvedScores,
    });

    return LegacyMigrationResult(
      alreadyMigrated: false,
      migratedEvents: migratedEvents,
      unresolvedScores: unresolvedScores,
      selectedCourseAsset: selectedCourseAsset,
    );
  }

  Set<int> _selectedClasses() {
    final storedClasses = settingsBox.get('Klasse');
    if (storedClasses is! Iterable) return {1};
    final classes =
        storedClasses.whereType<num>().map((value) => value.toInt()).toSet();
    return classes.isEmpty ? {1} : classes;
  }

  String _courseAssetFor(Set<int> classes) {
    return 'assets/questions/${_courseIdFor(classes)}.json';
  }

  String _courseIdFor(Set<int> classes) {
    final sorted = classes.toList()..sort();
    final key = sorted.join(',');
    return switch (key) {
      '1' => 'N',
      '1,2' => 'NE',
      '1,2,3' => 'NEA',
      '2' => 'E',
      '3' => 'A',
      '2,3' => 'EA',
      _ => 'N',
    };
  }

  String _legacyEventId({
    required String legacyKey,
    required int questionIndex,
    required String questionId,
    required int attempt,
  }) =>
      'legacy-v1:$legacyKey:$questionIndex:$questionId:$attempt';
}
