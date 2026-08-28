import 'dart:math';

import 'package:flutter/material.dart';

import 'package:fuenfzigohm/repository/models/course_class.dart';

const examQuestionCount = 25;
const examPassingScore = 19;

class ExamPartDefinition {
  final String code;
  final String label;
  final Duration duration;

  const ExamPartDefinition(this.code, this.label, this.duration);
}

const examPartDefinitions = <String, ExamPartDefinition>{
  'B': ExamPartDefinition(
    'B',
    'Betriebliche Kenntnisse',
    Duration(minutes: 45),
  ),
  'V': ExamPartDefinition(
    'V',
    'Kenntnisse von Vorschriften',
    Duration(minutes: 45),
  ),
  'N': ExamPartDefinition(
    'N',
    'Technische Kenntnisse Klasse N',
    Duration(minutes: 45),
  ),
  'E': ExamPartDefinition(
    'E',
    'Technische Kenntnisse Klasse E',
    Duration(minutes: 45),
  ),
  'A': ExamPartDefinition(
    'A',
    'Technische Kenntnisse Klasse A',
    Duration(minutes: 60),
  ),
};

enum ExamChoiceGroup { primary, upgrade, single }

class ExamChoice {
  final String id;
  final ExamChoiceGroup group;
  final String label;
  final String detail;
  final List<String> parts;
  final Color color;

  const ExamChoice({
    required this.id,
    required this.group,
    required this.label,
    required this.detail,
    required this.parts,
    required this.color,
  });
}

const examChoices = <ExamChoice>[
  ExamChoice(
    id: 'N',
    group: ExamChoiceGroup.primary,
    label: 'Klasse N',
    detail: 'B + V + N',
    parts: ['B', 'V', 'N'],
    color: CourseClass.CLASS_N_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'E',
    group: ExamChoiceGroup.primary,
    label: 'Klasse E',
    detail: 'B + V + N + E',
    parts: ['B', 'V', 'N', 'E'],
    color: CourseClass.CLASS_E_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'A',
    group: ExamChoiceGroup.primary,
    label: 'Klasse A',
    detail: 'B + V + N + E + A',
    parts: ['B', 'V', 'N', 'E', 'A'],
    color: CourseClass.CLASS_A_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'N-E',
    group: ExamChoiceGroup.upgrade,
    label: 'N → E',
    detail: 'Technik E',
    parts: ['E'],
    color: CourseClass.CLASS_E_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'N-A',
    group: ExamChoiceGroup.upgrade,
    label: 'N → A',
    detail: 'Technik E + A',
    parts: ['E', 'A'],
    color: CourseClass.CLASS_A_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'E-A',
    group: ExamChoiceGroup.upgrade,
    label: 'E → A',
    detail: 'Technik A',
    parts: ['A'],
    color: CourseClass.CLASS_A_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'part-B',
    group: ExamChoiceGroup.single,
    label: 'B',
    detail: 'Betriebliche Kenntnisse',
    parts: ['B'],
    color: CourseClass.CLASS_N_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'part-V',
    group: ExamChoiceGroup.single,
    label: 'V',
    detail: 'Kenntnisse von Vorschriften',
    parts: ['V'],
    color: CourseClass.CLASS_N_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'part-N',
    group: ExamChoiceGroup.single,
    label: 'N',
    detail: 'Technik Klasse N',
    parts: ['N'],
    color: CourseClass.CLASS_N_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'part-E',
    group: ExamChoiceGroup.single,
    label: 'E',
    detail: 'Technik Klasse E',
    parts: ['E'],
    color: CourseClass.CLASS_E_SURFACE_COLOR,
  ),
  ExamChoice(
    id: 'part-A',
    group: ExamChoiceGroup.single,
    label: 'A',
    detail: 'Technik Klasse A',
    parts: ['A'],
    color: CourseClass.CLASS_A_SURFACE_COLOR,
  ),
];

class ExamCatalogQuestion {
  final String id;
  final String part;
  final List<int> category;
  final Map<String, dynamic> data;

  const ExamCatalogQuestion({
    required this.id,
    required this.part,
    required this.category,
    required this.data,
  });
}

List<ExamCatalogQuestion> buildExamCatalog(Map<String, dynamic> catalog) {
  final result = <ExamCatalogQuestion>[];
  final sections = catalog['sections'];
  if (sections is! List) return result;

  for (var sectionIndex = 0; sectionIndex < sections.length; sectionIndex++) {
    final section = sections[sectionIndex];
    if (section is! Map) continue;
    _walkExamSection(
      section.cast<String, dynamic>(),
      sectionIndex,
      const [],
      result,
    );
  }
  return result;
}

void _walkExamSection(
  Map<String, dynamic> section,
  int mainSection,
  List<int> category,
  List<ExamCatalogQuestion> result,
) {
  final questions = section['questions'];
  if (questions is List) {
    for (final rawQuestion in questions) {
      if (rawQuestion is! Map) continue;
      final question = rawQuestion.cast<String, dynamic>();
      final part = _examPartForQuestion(mainSection, question['class']);
      final id = question['number']?.toString();
      if (part == null || id == null || id.isEmpty) continue;
      result.add(ExamCatalogQuestion(
        id: id,
        part: part,
        category: List.unmodifiable(category),
        data: question,
      ));
    }
  }

  final children = section['sections'];
  if (children is! List) return;
  for (var childIndex = 0; childIndex < children.length; childIndex++) {
    final child = children[childIndex];
    if (child is! Map) continue;
    _walkExamSection(
      child.cast<String, dynamic>(),
      mainSection,
      [...category, childIndex],
      result,
    );
  }
}

String? _examPartForQuestion(int mainSection, Object? questionClass) {
  if (mainSection == 1) return 'B';
  if (mainSection == 2) return 'V';
  if (mainSection != 0) return null;
  return const {'1': 'N', '2': 'E', '3': 'A'}[questionClass.toString()];
}

class ExamQuestionResult {
  final ExamCatalogQuestion question;
  final List<int> answerOrder;
  int? selectedAnswer;

  ExamQuestionResult({
    required this.question,
    required this.answerOrder,
    this.selectedAnswer,
  });

  bool get answered => selectedAnswer != null;
  bool get correct => selectedAnswer == 0;
}

class ExamPartResult {
  final ExamPartDefinition definition;
  final List<ExamQuestionResult> questions;
  int? score;
  bool timedOut = false;

  ExamPartResult({required this.definition, required this.questions});

  int evaluate() =>
      score = questions.where((question) => question.correct).length;
}

enum ExamOverallState { incomplete, passed, oral, failed }

ExamOverallState evaluateExam(List<ExamPartResult> parts) {
  if (parts.any((part) => part.score == null))
    return ExamOverallState.incomplete;
  final failed = parts.where((part) => part.score! < examPassingScore).toList();
  if (failed.isEmpty) return ExamOverallState.passed;
  if (failed.length == 1 && failed.single.score! >= 17) {
    return ExamOverallState.oral;
  }
  return ExamOverallState.failed;
}

class ExamBuilder {
  final Random random;

  ExamBuilder({Random? random}) : random = random ?? Random();

  List<ExamPartResult> build(
    List<ExamCatalogQuestion> catalog,
    ExamChoice choice,
  ) {
    return choice.parts.map((partCode) {
      final pool =
          catalog.where((question) => question.part == partCode).toList();
      final picked = balancedSample(pool, examQuestionCount, random);
      return ExamPartResult(
        definition: examPartDefinitions[partCode]!,
        questions: picked.map((question) {
          final order = [0, 1, 2, 3]..shuffle(random);
          return ExamQuestionResult(question: question, answerOrder: order);
        }).toList(),
      );
    }).toList();
  }
}

class _CategoryNode {
  final Map<int, _CategoryNode> children = {};
  final List<ExamCatalogQuestion> items = [];
  int size = 0;
}

List<ExamCatalogQuestion> balancedSample(
  List<ExamCatalogQuestion> pool,
  int count,
  Random random,
) {
  if (pool.length < count) {
    throw StateError(
      'Für diesen Prüfungsteil stehen nicht genügend Fragen zur Verfügung.',
    );
  }
  final root = _CategoryNode();
  for (final item in pool) {
    var node = root;
    node.size++;
    for (final categoryPart in item.category) {
      node = node.children.putIfAbsent(categoryPart, _CategoryNode.new);
      node.size++;
    }
    node.items.add(item);
  }
  return _pickFromTree(root, count, random)..shuffle(random);
}

List<ExamCatalogQuestion> _pickFromTree(
  _CategoryNode node,
  int quota,
  Random random,
) {
  if (quota <= 0) return [];
  if (node.children.isEmpty) {
    final items = [...node.items]..shuffle(random);
    return items.take(quota).toList();
  }

  final children = node.children.values.toList();
  final allocations = <_QuotaAllocation>[];
  var assigned = 0;
  for (final child in children) {
    final target = quota * child.size / node.size;
    final allocated = target.floor();
    allocations.add(_QuotaAllocation(child, allocated, target - allocated));
    assigned += allocated;
  }

  while (assigned < quota) {
    final candidates = allocations
        .where((allocation) => allocation.quota < allocation.child.size)
        .toList();
    final weight = candidates.fold<double>(
      0,
      (sum, allocation) => sum + allocation.fraction,
    );
    _QuotaAllocation selected;
    if (weight <= 0) {
      selected = candidates[random.nextInt(candidates.length)];
    } else {
      var draw = random.nextDouble() * weight;
      selected = candidates.last;
      for (final candidate in candidates) {
        draw -= candidate.fraction;
        if (draw <= 0) {
          selected = candidate;
          break;
        }
      }
    }
    selected.quota++;
    selected.fraction = 0;
    assigned++;
  }

  final result = <ExamCatalogQuestion>[];
  for (final allocation in allocations) {
    result.addAll(_pickFromTree(allocation.child, allocation.quota, random));
  }
  return result;
}

class _QuotaAllocation {
  final _CategoryNode child;
  int quota;
  double fraction;

  _QuotaAllocation(this.child, this.quota, this.fraction);
}

String encodedExamResult(ExamChoice choice, List<ExamPartResult> parts) {
  return '1.${choice.id}.${parts.map((part) => part.score).join('.')}';
}

String examResultImageCode(ExamChoice choice, bool passed) {
  if (!passed) return '';
  const order = ['A', 'E', 'N', 'B', 'V'];
  return order.where(choice.parts.contains).join().toLowerCase();
}

Uri examResultUri(ExamChoice choice, List<ExamPartResult> parts) {
  final passed = evaluateExam(parts) == ExamOverallState.passed;
  final imageCode = examResultImageCode(choice, passed);
  final page = imageCode.isEmpty ? 'result.html' : 'result-$imageCode.html';
  return Uri.https(
    '50ohm.de',
    '/$page',
    {'result': encodedExamResult(choice, parts)},
  );
}

String examShareText(ExamChoice choice, List<ExamPartResult> parts) {
  final scores = <String>[];
  for (var index = 0; index < choice.parts.length; index++) {
    scores.add('${choice.parts[index]}: ${parts[index].score}/25');
  }
  final passed = evaluateExam(parts) == ExamOverallState.passed;
  return 'Meine 50ohm.de-Prüfungssimulation ${choice.label}: '
      '${scores.join(', ')} – '
      '${passed ? 'bestanden!' : 'noch nicht bestanden.'}';
}
