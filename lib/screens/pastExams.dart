import 'package:flutter/material.dart';
import 'package:fuenfzigohm/models/exam_history.dart';

class PastExamsScreen extends StatefulWidget {
  const PastExamsScreen({Key? key}) : super(key: key);

  @override
  State<PastExamsScreen> createState() => _PastExamsScreenState();
}

class _PastExamsScreenState extends State<PastExamsScreen> {
  List<ExamResultRecord> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    await ExamHistoryService.init();
    setState(() {
      _results = ExamHistoryService.getResults();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vergangene Prüfungen'),
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Verlauf löschen',
              onPressed: _confirmClearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? _buildEmptyState()
              : _buildResultsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Keine vergangenen Prüfungen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Absolvierte Prüfungssimulationen werden hier angezeigt.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(ExamResultRecord result) {
    final d = result.completedAt;
    final dateStr = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final totalCorrect = result.partResults.fold(0, (sum, p) => sum + p.correct);
    final totalQuestions = result.partResults.fold(0, (sum, p) => sum + p.total);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showResultDetails(result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Klasse ${result.licenseClass}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: result.passed
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.passed ? 'BESTANDEN' : 'NICHT BESTANDEN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: result.passed ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: totalCorrect / totalQuestions,
                      backgroundColor: Colors.grey[300],
                      color: result.passed ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$totalCorrect/$totalQuestions',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Zeit: ${_formatTime(result.timeUsedSeconds)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDetails(ExamResultRecord result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PastExamReviewScreen(result: result),
      ),
    );
  }



  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verlauf löschen?'),
        content: const Text('Alle vergangenen Prüfungsergebnisse werden unwiderruflich gelöscht.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ExamHistoryService.clearHistory();
              setState(() {
                _results = [];
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _PastExamReviewScreen extends StatefulWidget {
  final ExamResultRecord result;

  const _PastExamReviewScreen({Key? key, required this.result}) : super(key: key);

  @override
  State<_PastExamReviewScreen> createState() => _PastExamReviewScreenState();
}

class _PastExamReviewScreenState extends State<_PastExamReviewScreen> {
  int _currentPartIndex = 0;
  int _currentQuestionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final part = widget.result.partResults[_currentPartIndex];

    final question = part.questionResults[_currentQuestionIndex];
    final totalQuestions = widget.result.partResults.fold<int>(0, (sum, p) => sum + p.questionResults.length);
    int globalIndex = 0;
    for (int i = 0; i < _currentPartIndex; i++) {
      globalIndex += widget.result.partResults[i].questionResults.length;
    }
    globalIndex += _currentQuestionIndex + 1;

    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('${part.partName} - $globalIndex/$totalQuestions'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: question.isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              question.isCorrect ? '✓ Richtig' : '✗ Falsch',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: question.isCorrect ? Colors.green : Colors.red,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Schließen',
          ),
        ],
      ),
      drawer: _buildReviewNavigationDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frage ${question.questionNumber}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.questionText,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: textColor),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(4, (i) => _buildAnswerTile(question, i, textColor)),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _currentPartIndex == 0 && _currentQuestionIndex == 0
                          ? null
                          : _previousQuestion,
                      child: const Text('Zurück'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _isLastQuestion()
                        ? ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fertig'),
                          )
                        : ElevatedButton(
                            onPressed: _nextQuestion,
                            child: const Text('Weiter'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewNavigationDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fragenübersicht',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Klasse ${widget.result.licenseClass}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.result.partResults.length,
                itemBuilder: (context, partIndex) {
                  final part = widget.result.partResults[partIndex];
                  final questions = part.questionResults;

                  return ExpansionTile(
                    title: Text(part.partName),
                    subtitle: Text('${part.correct}/${part.total} richtig'),
                    initiallyExpanded: partIndex == _currentPartIndex,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(questions.length, (qIndex) {
                            final q = questions[qIndex];
                            final isCorrect = q.isCorrect;
                            final isCurrent = partIndex == _currentPartIndex && qIndex == _currentQuestionIndex;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _currentPartIndex = partIndex;
                                  _currentQuestionIndex = qIndex;
                                });
                                Navigator.pop(context); // Close drawer
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? Theme.of(context).colorScheme.primary
                                      : isCorrect
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: isCurrent
                                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '${qIndex + 1}',
                                    style: TextStyle(
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                      color: isCurrent ? Colors.white : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerTile(QuestionResultRecord question, int index, Color textColor) {
    final isCorrect = index == question.correctAnswerIndex;
    final wasSelected = index == question.userAnswerIndex;
    
    Color getBorderColor() {
      if (isCorrect) return Colors.green;
      if (wasSelected) return Colors.red;
      return Colors.grey;
    }

    Color? getBackgroundColor() {
      if (isCorrect) return Colors.green.withOpacity(0.1);
      if (wasSelected && !isCorrect) return Colors.red.withOpacity(0.1);
      return null;
    }

    String getIndicator() {
      if (isCorrect && wasSelected) return '✓';
      if (isCorrect) return '✓';
      if (wasSelected) return '✗';
      return '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: getBorderColor(),
          width: isCorrect || wasSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: getBackgroundColor(),
      ),
      child: Row(
        children: [
          if (getIndicator().isNotEmpty)
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  getIndicator(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            const SizedBox(width: 32),
          Expanded(
            child: Text(
              question.answers[index],
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  bool _isLastQuestion() {
    final isLastPart = _currentPartIndex == widget.result.partResults.length - 1;
    final isLastQuestion = _currentQuestionIndex == widget.result.partResults[_currentPartIndex].questionResults.length - 1;
    return isLastPart && isLastQuestion;
  }

  void _nextQuestion() {
    final currentPartQuestions = widget.result.partResults[_currentPartIndex].questionResults.length;
    if (_currentQuestionIndex < currentPartQuestions - 1) {
      setState(() => _currentQuestionIndex++);
    } else if (_currentPartIndex < widget.result.partResults.length - 1) {
      setState(() {
        _currentPartIndex++;
        _currentQuestionIndex = 0;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    } else if (_currentPartIndex > 0) {
      setState(() {
        _currentPartIndex--;
        _currentQuestionIndex = widget.result.partResults[_currentPartIndex].questionResults.length - 1;
      });
    }
  }
}
