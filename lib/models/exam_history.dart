import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Represents a completed exam result that can be stored and retrieved
class ExamResultRecord {
  final String licenseClass;
  final DateTime completedAt;
  final int timeUsedSeconds;
  final List<PartResultRecord> partResults;
  final bool passed;

  ExamResultRecord({
    required this.licenseClass,
    required this.completedAt,
    required this.timeUsedSeconds,
    required this.partResults,
    required this.passed,
  });

  Map<String, dynamic> toJson() => {
    'licenseClass': licenseClass,
    'completedAt': completedAt.toIso8601String(),
    'timeUsedSeconds': timeUsedSeconds,
    'partResults': partResults.map((p) => p.toJson()).toList(),
    'passed': passed,
  };

  factory ExamResultRecord.fromJson(Map<String, dynamic> json) => ExamResultRecord(
    licenseClass: json['licenseClass'],
    completedAt: DateTime.parse(json['completedAt']),
    timeUsedSeconds: json['timeUsedSeconds'],
    partResults: (json['partResults'] as List).map((p) => PartResultRecord.fromJson(p)).toList(),
    passed: json['passed'],
  );
}

class PartResultRecord {
  final String partName;
  final int correct;
  final int total;
  final int passThreshold;
  final String result; // 'passed', 'oralExam', 'failed'
  final List<QuestionResultRecord> questionResults;

  PartResultRecord({
    required this.partName,
    required this.correct,
    required this.total,
    required this.passThreshold,
    required this.result,
    this.questionResults = const [],
  });

  Map<String, dynamic> toJson() => {
    'partName': partName,
    'correct': correct,
    'total': total,
    'passThreshold': passThreshold,
    'result': result,
    'questionResults': questionResults.map((q) => q.toJson()).toList(),
  };

  factory PartResultRecord.fromJson(Map<String, dynamic> json) => PartResultRecord(
    partName: json['partName'],
    correct: json['correct'],
    total: json['total'],
    passThreshold: json['passThreshold'],
    result: json['result'],
    questionResults: json['questionResults'] != null 
        ? (json['questionResults'] as List).map((q) => QuestionResultRecord.fromJson(q)).toList()
        : [],
  );
}

/// Stores details about each question in the exam
class QuestionResultRecord {
  final String questionNumber;
  final String questionText;
  final String? questionImage;
  final List<String> answers;
  final List<String?> answerImages;
  final int correctAnswerIndex;
  final int? userAnswerIndex;
  final bool isCorrect;

  QuestionResultRecord({
    required this.questionNumber,
    required this.questionText,
    this.questionImage,
    required this.answers,
    required this.answerImages,
    required this.correctAnswerIndex,
    this.userAnswerIndex,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
    'questionNumber': questionNumber,
    'questionText': questionText,
    'questionImage': questionImage,
    'answers': answers,
    'answerImages': answerImages,
    'correctAnswerIndex': correctAnswerIndex,
    'userAnswerIndex': userAnswerIndex,
    'isCorrect': isCorrect,
  };

  factory QuestionResultRecord.fromJson(Map<String, dynamic> json) => QuestionResultRecord(
    questionNumber: json['questionNumber'] ?? '',
    questionText: json['questionText'] ?? '',
    questionImage: json['questionImage'],
    answers: List<String>.from(json['answers'] ?? []),
    answerImages: List<String?>.from(json['answerImages'] ?? []),
    correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
    userAnswerIndex: json['userAnswerIndex'],
    isCorrect: json['isCorrect'] ?? false,
  );
}

/// Service to store and retrieve exam results
class ExamHistoryService {
  static const String _boxName = 'exam_history';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static Future<void> saveResult(ExamResultRecord record) async {
    if (_box == null) await init();
    
    final results = getResults();
    results.insert(0, record); // Add at beginning (most recent first)
    
    // Keep only last 20 results (with full question data they take more space)
    if (results.length > 20) {
      results.removeRange(20, results.length);
    }
    
    final jsonList = results.map((r) => jsonEncode(r.toJson())).toList();
    await _box!.put('results', jsonList);
  }

  static List<ExamResultRecord> getResults() {
    if (_box == null) return [];
    
    final jsonList = _box!.get('results', defaultValue: <String>[]) as List;
    return jsonList
        .map((json) => ExamResultRecord.fromJson(jsonDecode(json as String)))
        .toList();
  }

  static Future<void> clearHistory() async {
    if (_box == null) await init();
    await _box!.delete('results');
  }
}
