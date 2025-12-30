import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fuenfzigohm/models/exam_config.dart';
import 'package:fuenfzigohm/models/exam_history.dart';
import 'package:fuenfzigohm/screens/examSelection.dart';

class ExamResultsScreen extends StatefulWidget {
  final ExamConfig config;
  final List<ExamPart> activeParts;
  final List<List<Map<String, dynamic>>> questions;
  final List<List<int?>> userAnswers;
  final List<List<List<int>>> answerOrders;
  final int timeUsed;

  const ExamResultsScreen({
    Key? key,
    required this.config,
    required this.activeParts,
    required this.questions,
    required this.userAnswers,
    required this.answerOrders,
    required this.timeUsed,
  }) : super(key: key);

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  bool _showReview = false;
  int? _reviewPartIndex;
  int? _reviewQuestionIndex;
  bool _resultsSaved = false;

  @override
  void initState() {
    super.initState();
    _saveResults();
  }

  Future<void> _saveResults() async {
    if (_resultsSaved) return;
    _resultsSaved = true;

    final List<PartResultRecord> partRecords = [];
    bool overallPassed = true;

    for (int i = 0; i < widget.activeParts.length; i++) {
      final part = widget.activeParts[i];
      final answers = widget.userAnswers[i];
      final questions = widget.questions[i];
      final answerOrders = widget.answerOrders[i];

      int correct = 0;
      List<QuestionResultRecord> questionResults = [];
      
      for (int q = 0; q < questions.length; q++) {
        final question = questions[q];
        final userAnswer = answers[q];
        final order = answerOrders[q];
        final isCorrect = userAnswer == 0;
        if (isCorrect) correct++;

        // Build answer list in original order (A, B, C, D)
        final answerKeys = ['answer_a', 'answer_b', 'answer_c', 'answer_d'];
        final pictureKeys = ['picture_a', 'picture_b', 'picture_c', 'picture_d'];
        
        questionResults.add(QuestionResultRecord(
          questionNumber: question['number'] ?? '',
          questionText: question['question'] ?? '',
          questionImage: question['picture_question'],
          answers: answerKeys.map((k) => question[k]?.toString() ?? '').toList(),
          answerImages: pictureKeys.map((k) => question[k]?.toString()).toList(),
          correctAnswerIndex: 0, // Answer A is always correct
          userAnswerIndex: userAnswer,
          isCorrect: isCorrect,
        ));
      }

      final result = part.getResult(correct);
      if (result != ExamPartResult.passed) overallPassed = false;

      partRecords.add(PartResultRecord(
        partName: part.name,
        correct: correct,
        total: questions.length,
        passThreshold: part.passThreshold,
        result: result.name,
        questionResults: questionResults,
      ));
    }

    final record = ExamResultRecord(
      licenseClass: widget.config.licenseClass,
      completedAt: DateTime.now(),
      timeUsedSeconds: widget.timeUsed,
      partResults: partRecords,
      passed: overallPassed,
    );

    await ExamHistoryService.saveResult(record);
  }

  @override
  Widget build(BuildContext context) {
    final List<_PartResult> partResults = [];
    for (int i = 0; i < widget.activeParts.length; i++) {
      final part = widget.activeParts[i];
      final questions = widget.questions[i];
      final answers = widget.userAnswers[i];

      int correct = 0;
      for (int q = 0; q < questions.length; q++) {
        if (answers[q] == 0) {
          correct++;
        }
      }

      partResults.add(_PartResult(
        part: part,
        correct: correct,
        total: questions.length,
        result: part.getResult(correct),
      ));
    }

    final overallPassed = partResults.every((r) => r.result == ExamPartResult.passed);
    final hasOralExam = partResults.any((r) => r.result == ExamPartResult.oralExam);
    final hasFailed = partResults.any((r) => r.result == ExamPartResult.failed);

    if (_showReview && _reviewPartIndex != null && _reviewQuestionIndex != null) {
      return _buildQuestionReview();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prüfungsergebnis'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: overallPassed
                      ? Colors.green.withOpacity(0.2)
                      : hasOralExam && !hasFailed
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: overallPassed
                        ? Colors.green
                        : hasOralExam && !hasFailed
                            ? Colors.orange
                            : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      overallPassed
                          ? Icons.check_circle
                          : hasOralExam && !hasFailed
                              ? Icons.help_outline
                              : Icons.cancel,
                      size: 64,
                      color: overallPassed
                          ? Colors.green
                          : hasOralExam && !hasFailed
                              ? Colors.orange
                              : Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      overallPassed
                          ? 'BESTANDEN'
                          : hasOralExam && !hasFailed
                              ? 'MÜNDLICHE NACHPRÜFUNG'
                              : 'NICHT BESTANDEN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: overallPassed
                            ? Colors.green
                            : hasOralExam && !hasFailed
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Zeit: ${_formatTime(widget.timeUsed)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Ergebnisse nach Prüfungsteil',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...partResults.asMap().entries.map((entry) => 
                _buildPartResultCard(entry.key, entry.value)),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showReview = true;
                    _reviewPartIndex = 0;
                    _reviewQuestionIndex = 0;
                  });
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Fragen überprüfen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ExamSelectionScreen()),
                    (route) => route.isFirst,
                  );
                },
                icon: const Icon(Icons.replay),
                label: const Text('Neue Prüfung'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home),
                label: const Text('Zurück zum Lernen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartResultCard(int partIndex, _PartResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.part.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        result.part.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: result.result == ExamPartResult.passed
                        ? Colors.green.withOpacity(0.2)
                        : result.result == ExamPartResult.oralExam
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${result.result.emoji} ${result.result.label}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: result.result == ExamPartResult.passed
                          ? Colors.green[700]
                          : result.result == ExamPartResult.oralExam
                              ? Colors.orange[700]
                              : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: result.correct / result.total,
                    backgroundColor: Colors.grey[300],
                    color: result.result == ExamPartResult.passed
                        ? Colors.green
                        : result.result == ExamPartResult.oralExam
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${result.correct}/${result.total}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Benötigt zum Bestehen: ${result.part.passThreshold}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionReview() {
    final partIndex = _reviewPartIndex!;
    final questionIndex = _reviewQuestionIndex!;
    final part = widget.activeParts[partIndex];
    final question = widget.questions[partIndex][questionIndex];
    final userAnswer = widget.userAnswers[partIndex][questionIndex];
    final answerOrder = widget.answerOrders[partIndex][questionIndex];

    final isCorrect = userAnswer == 0;
    final totalQuestions = widget.questions[partIndex].length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${part.name} - Überprüfung'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _showReview = false;
              _reviewPartIndex = null;
              _reviewQuestionIndex = null;
            });
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: (questionIndex + 1) / totalQuestions,
              backgroundColor: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Frage ${questionIndex + 1} von $totalQuestions'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCorrect ? '✓ Richtig' : '✗ Falsch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (question['picture_question'] != null) ...[
                      Center(
                        child: SvgPicture.asset(
                          'assets/svgs/${question['picture_question']}.svg',
                          height: 150,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _parseTextWithMath(question['question'] ?? '', const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),

                    ..._buildReviewAnswers(question, answerOrder, userAnswer),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: questionIndex == 0 && partIndex == 0
                          ? null
                          : () => _goToPreviousReviewQuestion(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Zurück'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: questionIndex == totalQuestions - 1 &&
                            partIndex == widget.activeParts.length - 1
                        ? ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showReview = false;
                                _reviewPartIndex = null;
                                _reviewQuestionIndex = null;
                              });
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Fertig'),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _goToNextReviewQuestion(),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Weiter'),
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

  List<Widget> _buildReviewAnswers(
    Map<String, dynamic> question,
    List<int> order,
    int? userAnswer,
  ) {
    final answerKeys = ['answer_a', 'answer_b', 'answer_c', 'answer_d'];
    final pictureKeys = ['picture_a', 'picture_b', 'picture_c', 'picture_d'];
    final hasImages = question['picture_a'] != null;

    return order.asMap().entries.map((entry) {
      final actualIndex = entry.value;
      final isCorrect = actualIndex == 0;
      final wasSelected = userAnswer == actualIndex;

      Color getBorderColor() {
        if (isCorrect) return Colors.green;
        if (wasSelected) return Colors.red;
        return Colors.grey;
      }

      Color? getBackgroundColor() {
        if (isCorrect) return Colors.green.withOpacity(0.1);
        if (wasSelected) return Colors.red.withOpacity(0.1);
        return null;
      }

      Widget buildIndicator() {
        if (isCorrect) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 16, color: Colors.white),
          );
        }
        if (wasSelected) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 16, color: Colors.white),
          );
        }
        return const SizedBox(width: 24, height: 24);
      }

      if (hasImages) {
        final pictureName = question[pictureKeys[actualIndex]];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: getBorderColor(), width: isCorrect || wasSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
              color: getBackgroundColor(),
            ),
            child: Row(
              children: [
                buildIndicator(),
                const SizedBox(width: 8),
                Expanded(
                  child: pictureName != null
                      ? SvgPicture.asset('assets/svgs/$pictureName.svg', height: 80)
                      : const Text('Bild nicht verfügbar'),
                ),
              ],
            ),
          ),
        );
      } else {
        final answerText = question[answerKeys[actualIndex]] ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: getBorderColor(), width: isCorrect || wasSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
              color: getBackgroundColor(),
            ),
            child: Row(
              children: [
                buildIndicator(),
                const SizedBox(width: 8),
                Expanded(child: _parseTextWithMath(answerText, const TextStyle(fontSize: 16))),
              ],
            ),
          ),
        );
      }
    }).toList();
  }

  void _goToNextReviewQuestion() {
    final currentPartQuestions = widget.questions[_reviewPartIndex!].length;
    if (_reviewQuestionIndex! < currentPartQuestions - 1) {
      setState(() {
        _reviewQuestionIndex = _reviewQuestionIndex! + 1;
      });
    } else if (_reviewPartIndex! < widget.activeParts.length - 1) {
      setState(() {
        _reviewPartIndex = _reviewPartIndex! + 1;
        _reviewQuestionIndex = 0;
      });
    }
  }

  void _goToPreviousReviewQuestion() {
    if (_reviewQuestionIndex! > 0) {
      setState(() {
        _reviewQuestionIndex = _reviewQuestionIndex! - 1;
      });
    } else if (_reviewPartIndex! > 0) {
      setState(() {
        _reviewPartIndex = _reviewPartIndex! - 1;
        _reviewQuestionIndex = widget.questions[_reviewPartIndex!].length - 1;
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _parseTextWithMath(String input, TextStyle textStyle) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final styledTextStyle = textStyle.copyWith(color: textColor);
    
    RegExp mathPattern = RegExp(r'\$(.*?)\$');
    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (Match match in mathPattern.allMatches(input)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: input.substring(lastIndex, match.start), style: styledTextStyle));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            match.group(1)!,
            textStyle: styledTextStyle,
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      spans.add(TextSpan(text: input.substring(lastIndex), style: styledTextStyle));
    }

    return RichText(
      text: TextSpan(
        style: styledTextStyle,
        children: spans,
      ),
    );
  }
}

class _PartResult {
  final ExamPart part;
  final int correct;
  final int total;
  final ExamPartResult result;

  const _PartResult({
    required this.part,
    required this.correct,
    required this.total,
    required this.result,
  });
}
