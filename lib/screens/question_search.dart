import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fuenfzigohm/screens/question.dart';

const questionSearchResultLimit = 100;

class QuestionSearchEntry {
  final String questionId;
  final Map<String, dynamic> data;

  const QuestionSearchEntry({
    required this.questionId,
    required this.data,
  });
}

List<QuestionSearchEntry> buildQuestionSearchIndex(dynamic catalog) {
  final questions = <QuestionSearchEntry>[];

  void visit(dynamic value) {
    if (value is Map) {
      final questionId = value['number']?.toString();
      if (questionId != null && questionId.isNotEmpty) {
        questions.add(
          QuestionSearchEntry(
            questionId: questionId,
            data: value.cast<String, dynamic>(),
          ),
        );
        return;
      }
      for (final child in value.values) {
        visit(child);
      }
    } else if (value is List) {
      for (final child in value) {
        visit(child);
      }
    }
  }

  visit(catalog);
  questions.sort((left, right) => left.questionId.compareTo(right.questionId));
  return questions;
}

String normalizeQuestionNumber(String value) =>
    value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

List<QuestionSearchEntry> searchQuestionNumbers(
  Iterable<QuestionSearchEntry> questions,
  String query, {
  int limit = questionSearchResultLimit,
}) {
  final normalizedQuery = normalizeQuestionNumber(query);
  if (normalizedQuery.isEmpty) return const [];

  final exact = <QuestionSearchEntry>[];
  final prefixes = <QuestionSearchEntry>[];
  final remaining = <QuestionSearchEntry>[];
  for (final question in questions) {
    final questionId = normalizeQuestionNumber(question.questionId);
    if (questionId == normalizedQuery) {
      exact.add(question);
    } else if (questionId.startsWith(normalizedQuery)) {
      prefixes.add(question);
    } else if (questionId.contains(normalizedQuery)) {
      remaining.add(question);
    }
  }

  return [...exact, ...prefixes, ...remaining].take(limit).toList();
}

class QuestionSearchPage extends StatefulWidget {
  const QuestionSearchPage({super.key});

  @override
  State<QuestionSearchPage> createState() => _QuestionSearchPageState();
}

class _QuestionSearchPageState extends State<QuestionSearchPage> {
  bool _loaded = false;
  List<QuestionSearchEntry> _questions = const [];
  List<QuestionSearchEntry> _matches = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final raw =
          await rootBundle.loadString('assets/questions/Questions.json');
      final catalog = jsonDecode(raw) as Map<String, dynamic>;
      final questions = buildQuestionSearchIndex(catalog);
      if (!mounted) return;
      setState(() {
        _loaded = true;
        _questions = questions;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Die Fragen konnten nicht geladen werden.');
      debugPrint('Could not load question search catalog: $error');
    }
  }

  void _search(String query) {
    setState(() {
      _matches = searchQuestionNumbers(_questions, query);
    });
  }

  void _openQuestion(QuestionSearchEntry question) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Question.single(context, question.data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Frage suchen')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                key: const Key('question-search-field'),
                autofocus: true,
                enabled: _loaded,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Fragennummer',
                  hintText: 'Zum Beispiel NA103',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _search,
                onSubmitted: (query) {
                  final matches = searchQuestionNumbers(_questions, query);
                  if (matches.length == 1) _openQuestion(matches.single);
                },
              ),
              const SizedBox(height: 12),
              if (!_loaded && _error == null)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Expanded(child: Center(child: Text(_error!)))
              else
                Expanded(
                  child: _matches.isEmpty
                      ? const Center(
                          child: Text(
                            'Gib eine vollständige Fragennummer oder einen '
                            'Teil davon ein.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          itemCount: _matches.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final question = _matches[index];
                            return ListTile(
                              leading: const Icon(Icons.quiz_outlined),
                              title: Text(question.questionId),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _openQuestion(question),
                            );
                          },
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
