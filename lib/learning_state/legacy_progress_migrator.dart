import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'package:fuenfzigohm/custom_libs/json.dart';

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

    final referencesByLegacyKey = <String, List<QuestionReference>>{};
    await _addSelectedCourseReferences(
      selectedCourseAsset,
      selectedClasses,
      referencesByLegacyKey,
    );
    await _addCatalogReferences(selectedClasses, referencesByLegacyKey);

    int migratedEvents = 0;
    int unresolvedScores = 0;

    for (final legacyKey in legacyProgressBox.keys.whereType<String>()) {
      final rawScores = legacyProgressBox.get(legacyKey);
      if (rawScores is! List) continue;

      final references = referencesByLegacyKey[legacyKey] ?? const [];
      for (int questionIndex = 0;
          questionIndex < rawScores.length;
          questionIndex++) {
        final rawScore = rawScores[questionIndex];
        final score = rawScore is num ? rawScore.toInt() : 0;
        if (score <= 0) continue;

        final matchingReference = references
            .where((reference) => reference.questionIndex == questionIndex)
            .firstOrNull;
        if (matchingReference == null) {
          unresolvedScores += score;
          continue;
        }

        for (int attempt = 0; attempt < score; attempt++) {
          final eventId = _legacyEventId(
            legacyKey: legacyKey,
            questionIndex: questionIndex,
            questionId: matchingReference.questionId,
            attempt: attempt,
          );
          final inserted =
              await learningStateRepository.recordLegacyCorrectAnswer(
            eventId: eventId,
            questionId: matchingReference.questionId,
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

  Future<void> _addSelectedCourseReferences(
    String assetPath,
    Set<int> selectedClasses,
    Map<String, List<QuestionReference>> target,
  ) async {
    final data = jsonDecode(await loadAsset(assetPath)) as Map<String, dynamic>;
    filterQuestionSections(data, selectedClasses);
    _addReferences(Json(data).getQuestionReferences(-1), target);
  }

  Future<void> _addCatalogReferences(
    Set<int> selectedClasses,
    Map<String, List<QuestionReference>> target,
  ) async {
    final catalog = jsonDecode(
      await loadAsset('assets/questions/Questions.json'),
    ) as Map<String, dynamic>;
    final mainSections = catalog['sections'] as List;

    for (int mainChapter = 0;
        mainChapter < mainSections.length;
        mainChapter++) {
      final sectionCopy = jsonDecode(jsonEncode(mainSections[mainChapter]))
          as Map<String, dynamic>;
      filterQuestionSections(sectionCopy, selectedClasses);
      _addReferences(
        Json(sectionCopy).getQuestionReferences(mainChapter),
        target,
      );
    }
  }

  void _addReferences(
    Iterable<QuestionReference> references,
    Map<String, List<QuestionReference>> target,
  ) {
    for (final reference in references) {
      target.putIfAbsent(reference.legacyKey, () => []).add(reference);
    }
  }

  String _courseAssetFor(Set<int> classes) {
    final sorted = classes.toList()..sort();
    final key = sorted.join(',');
    return switch (key) {
      '1' => 'assets/questions/N.json',
      '1,2' => 'assets/questions/NE.json',
      '1,2,3' => 'assets/questions/NEA.json',
      '2' => 'assets/questions/E.json',
      '3' => 'assets/questions/A.json',
      '2,3' => 'assets/questions/EA.json',
      _ => 'assets/questions/N.json',
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

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
