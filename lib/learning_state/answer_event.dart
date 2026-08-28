class AnswerEvent {
  static const int currentSchemaVersion = 1;

  final String id;
  final String questionId;
  final DateTime? answeredAtUtc;
  final DateTime recordedAtUtc;
  final bool correct;
  final String? selectedAnswerKey;
  final String? catalogVersion;
  final String deviceId;
  final String source;
  final String? legacySourceKey;

  const AnswerEvent({
    required this.id,
    required this.questionId,
    required this.answeredAtUtc,
    required this.recordedAtUtc,
    required this.correct,
    required this.selectedAnswerKey,
    required this.catalogVersion,
    required this.deviceId,
    required this.source,
    this.legacySourceKey,
  });

  Map<String, dynamic> toMap() => {
        'schemaVersion': currentSchemaVersion,
        'id': id,
        'questionId': questionId,
        'answeredAtUtc': answeredAtUtc?.toIso8601String(),
        'recordedAtUtc': recordedAtUtc.toIso8601String(),
        'correct': correct,
        'selectedAnswerKey': selectedAnswerKey,
        'catalogVersion': catalogVersion,
        'deviceId': deviceId,
        'source': source,
        'legacySourceKey': legacySourceKey,
      };

  factory AnswerEvent.fromMap(Map<dynamic, dynamic> map) {
    final answeredAt = map['answeredAtUtc'] as String?;
    return AnswerEvent(
      id: map['id'] as String,
      questionId: map['questionId'] as String,
      answeredAtUtc: answeredAt == null ? null : DateTime.parse(answeredAt),
      recordedAtUtc: DateTime.parse(map['recordedAtUtc'] as String),
      correct: map['correct'] as bool,
      selectedAnswerKey: map['selectedAnswerKey'] as String?,
      catalogVersion: map['catalogVersion'] as String?,
      deviceId: map['deviceId'] as String,
      source: map['source'] as String,
      legacySourceKey: map['legacySourceKey'] as String?,
    );
  }
}
