import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import 'answer_event.dart';

class LearningStateRepository {
  static const String deviceIdSettingsKey = 'learningStateDeviceId';
  static const String catalogVersion = 'afu-2024-03';

  final Box<dynamic> eventsBox;
  final Box<dynamic> settingsBox;
  final Uuid _uuid;

  Map<String, int>? _scoreByQuestionId;
  Set<String>? _answeredQuestionIds;
  String? _deviceId;

  LearningStateRepository({
    required this.eventsBox,
    required this.settingsBox,
    Uuid uuid = const Uuid(),
  }) : _uuid = uuid;

  Future<String> _getOrCreateDeviceId() async {
    final cachedId = _deviceId;
    if (cachedId != null) return cachedId;

    final storedId = settingsBox.get(deviceIdSettingsKey);
    if (storedId is String && storedId.isNotEmpty) {
      return _deviceId = storedId;
    }

    final newId = _uuid.v4();
    await settingsBox.put(deviceIdSettingsKey, newId);
    return _deviceId = newId;
  }

  Map<String, int> get _scores {
    final cached = _scoreByQuestionId;
    if (cached != null) return cached;

    final scores = <String, int>{};
    for (final rawEvent in eventsBox.values) {
      try {
        if (rawEvent is! Map) continue;
        final event = AnswerEvent.fromMap(rawEvent);
        if (event.correct) {
          scores.update(event.questionId, (score) => score + 1,
              ifAbsent: () => 1);
        }
      } catch (_) {
        // Ignore malformed events while retaining the rest of the log.
      }
    }
    return _scoreByQuestionId = scores;
  }

  int scoreForQuestion(String questionId) => _scores[questionId] ?? 0;

  Set<String> get answeredQuestionIds {
    final cached = _answeredQuestionIds;
    if (cached != null) return Set.unmodifiable(cached);

    final ids = <String>{};
    for (final rawEvent in eventsBox.values) {
      try {
        if (rawEvent is! Map) continue;
        ids.add(AnswerEvent.fromMap(rawEvent).questionId);
      } catch (_) {
        // Ignore malformed events while retaining the rest of the log.
      }
    }
    _answeredQuestionIds = ids;
    return Set.unmodifiable(ids);
  }

  bool hasAnsweredQuestion(String questionId) =>
      answeredQuestionIds.contains(questionId);

  List<bool> answeredForQuestions(Iterable<String> questionIds) {
    final answeredIds = answeredQuestionIds;
    return questionIds.map(answeredIds.contains).toList();
  }

  List<int> scoresForQuestions(Iterable<String> questionIds) =>
      questionIds.map(scoreForQuestion).toList();

  double progressForQuestions(Iterable<String> questionIds) {
    final ids = questionIds.toList();
    if (ids.isEmpty) return 0;
    final scoreSum = ids.fold<int>(
      0,
      (sum, id) => sum + scoreForQuestion(id).clamp(0, 3),
    );
    return scoreSum / (ids.length * 3);
  }

  Future<AnswerEvent> recordAnswer({
    required String questionId,
    required bool correct,
    required String? selectedAnswerKey,
    DateTime? answeredAtUtc,
    String source = 'answer',
  }) async {
    final now = DateTime.now().toUtc();
    final deviceId = await _getOrCreateDeviceId();
    final event = AnswerEvent(
      id: _uuid.v4(),
      questionId: questionId,
      answeredAtUtc: answeredAtUtc ?? now,
      recordedAtUtc: now,
      correct: correct,
      selectedAnswerKey: selectedAnswerKey,
      catalogVersion: catalogVersion,
      deviceId: deviceId,
      source: source,
    );
    await _storeEvent(event);
    return event;
  }

  Future<bool> recordLegacyCorrectAnswer({
    required String eventId,
    required String questionId,
    required String legacySourceKey,
  }) async {
    if (eventsBox.containsKey(eventId)) return false;

    final deviceId = await _getOrCreateDeviceId();
    final event = AnswerEvent(
      id: eventId,
      questionId: questionId,
      answeredAtUtc: null,
      recordedAtUtc: DateTime.now().toUtc(),
      correct: true,
      selectedAnswerKey: null,
      catalogVersion: catalogVersion,
      deviceId: deviceId,
      source: 'legacyMigration',
      legacySourceKey: legacySourceKey,
    );
    await _storeEvent(event);
    return true;
  }

  Future<void> _storeEvent(AnswerEvent event) async {
    final cachedScores = _scoreByQuestionId;
    final cachedAnsweredIds = _answeredQuestionIds;
    await eventsBox.put(event.id, event.toMap());
    cachedAnsweredIds?.add(event.questionId);
    if (event.correct && cachedScores != null) {
      cachedScores.update(event.questionId, (score) => score + 1,
          ifAbsent: () => 1);
    }
  }

  Future<void> clearAnswers() async {
    await eventsBox.clear();
    _scoreByQuestionId = <String, int>{};
    _answeredQuestionIds = <String>{};
  }

  void rebuildProjection() {
    _scoreByQuestionId = null;
    _answeredQuestionIds = null;
  }
}
