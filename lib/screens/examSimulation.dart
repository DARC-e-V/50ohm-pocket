import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fuenfzigohm/constants.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:fuenfzigohm/models/exam_config.dart';
import 'package:fuenfzigohm/screens/examResults.dart';
import 'package:fuenfzigohm/screens/pdfViewer.dart';

class ExamSimulationScreen extends StatefulWidget {
  final ExamConfig config;
  final int? partIndex;

  const ExamSimulationScreen({
    Key? key,
    required this.config,
    this.partIndex,
  }) : super(key: key);

  @override
  State<ExamSimulationScreen> createState() => _ExamSimulationScreenState();
}

class _ExamSimulationScreenState extends State<ExamSimulationScreen> {
  List<ExamPart> _activeParts = [];
  int _currentPartIndex = 0;
  int _currentQuestionIndex = 0;
  
  List<List<Map<String, dynamic>>> _partQuestions = [];
  List<List<int?>> _partAnswers = [];
  List<List<List<int>>> _answerOrders = [];
  
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeExam() async {
    try {
      if (widget.partIndex != null) {
        _activeParts = [widget.config.parts[widget.partIndex!]];
      } else {
        _activeParts = widget.config.parts;
      }

      _totalSeconds = _activeParts.fold(0, (sum, part) => sum + part.timeMinutes * 60);
      _remainingSeconds = _totalSeconds;

      final String rawData = await rootBundle.loadString(widget.config.jsonFile);
      final Map<String, dynamic> jsonData = json.decode(rawData);
      
      final List<Map<String, dynamic>> allQuestions = _extractAllQuestions(jsonData);

      final random = Random();
      for (final part in _activeParts) {
        final filteredQuestions = allQuestions.where((q) {
          final number = q['number'] as String? ?? '';
          return part.questionPrefixes.any((prefix) => number.startsWith(prefix));
        }).toList();

        filteredQuestions.shuffle(random);
        final selectedQuestions = filteredQuestions.take(part.questionCount).toList();
        
        _partQuestions.add(selectedQuestions);
        _partAnswers.add(List.filled(selectedQuestions.length, null));
        
        final orders = selectedQuestions.map((_) {
          final order = [0, 1, 2, 3];
          order.shuffle(random);
          return order;
        }).toList();
        _answerOrders.add(orders);
      }

      _startTimer();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Fehler beim Laden der Prüfung: $e';
      });
    }
  }

  List<Map<String, dynamic>> _extractAllQuestions(Map<String, dynamic> jsonData) {
    final List<Map<String, dynamic>> questions = [];
    
    void extractFromSection(dynamic section) {
      if (section is Map<String, dynamic>) {
        if (section.containsKey('questions')) {
          for (final q in section['questions']) {
            questions.add(Map<String, dynamic>.from(q));
          }
        }
        if (section.containsKey('sections')) {
          for (final s in section['sections']) {
            extractFromSection(s);
          }
        }
      }
    }

    if (jsonData.containsKey('sections')) {
      for (final section in jsonData['sections']) {
        extractFromSection(section);
      }
    }

    return questions;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _submitExam();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _partAnswers[_currentPartIndex][_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _partQuestions[_currentPartIndex].length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else if (_currentPartIndex < _activeParts.length - 1) {
      setState(() {
        _currentPartIndex++;
        _currentQuestionIndex = 0;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    } else if (_currentPartIndex > 0) {
      setState(() {
        _currentPartIndex--;
        _currentQuestionIndex = _partQuestions[_currentPartIndex].length - 1;
      });
    }
  }

  void _goToQuestion(int partIndex, int questionIndex) {
    setState(() {
      _currentPartIndex = partIndex;
      _currentQuestionIndex = questionIndex;
    });
    Navigator.pop(context);
  }

  void _confirmSubmit() {
    final unanswered = _partAnswers.expand((a) => a).where((a) => a == null).length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prüfung abgeben?'),
        content: unanswered > 0
            ? Text('Du hast noch $unanswered unbeantwortete Fragen. Trotzdem abgeben?')
            : const Text('Möchtest du die Prüfung jetzt abgeben?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zurück'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            child: const Text('Abgeben'),
          ),
        ],
      ),
    );
  }

  void _submitExam() {
    _timer?.cancel();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExamResultsScreen(
          config: widget.config,
          activeParts: _activeParts,
          questions: _partQuestions,
          userAnswers: _partAnswers,
          answerOrders: _answerOrders,
          timeUsed: _totalSeconds - _remainingSeconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.config.displayName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.config.displayName)),
        body: Center(child: Text(_error!)),
      );
    }

    final currentPart = _activeParts[_currentPartIndex];
    final currentQuestions = _partQuestions[_currentPartIndex];
    final currentQuestion = currentQuestions[_currentQuestionIndex];
    final currentAnswerOrder = _answerOrders[_currentPartIndex][_currentQuestionIndex];
    final selectedAnswer = _partAnswers[_currentPartIndex][_currentQuestionIndex];

    int totalQuestionsBeforeCurrent = 0;
    for (int i = 0; i < _currentPartIndex; i++) {
      totalQuestionsBeforeCurrent += _partQuestions[i].length;
    }
    final globalQuestionNumber = totalQuestionsBeforeCurrent + _currentQuestionIndex + 1;
    final totalQuestions = _partQuestions.fold(0, (sum, q) => sum + q.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPart.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'Hilfsmittel',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PdfViewer(1, "assets/pdf/Hilfsmittel_12062024.pdf", "Hilfsmittel"),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _remainingSeconds < 300 ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 20,
                  color: _remainingSeconds < 300 ? Colors.red : null,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _remainingSeconds < 300 ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: _buildQuestionNavigationDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: globalQuestionNumber / totalQuestions,
              backgroundColor: Colors.grey[300],
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frage $globalQuestionNumber von $totalQuestions',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    currentQuestion['number'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 120),
                    children: [
                      // Fragetext
                      Center(
                        child: _buildQuestionText(currentQuestion['question'] ?? ''),
                      ),
                      // Fragebild falls vorhanden
                      if (currentQuestion['picture_question'] != null) ...[
                        const SizedBox(height: 16),
                        _buildQuestionImage(currentQuestion['picture_question']),
                      ],
                      const Divider(height: 32),
                      // Antwortoptionen
                      _buildAnswerOptionsWidget(currentQuestion, currentAnswerOrder, selectedAnswer),
                    ],
                  ),
                  // Navigation Buttons am unteren Rand
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
                      child: (_currentPartIndex == _activeParts.length - 1 &&
                              _currentQuestionIndex == currentQuestions.length - 1)
                          ? ElevatedButton(
                              autofocus: false,
                              style: buttonstyle(Colors.green),
                              onPressed: _confirmSubmit,
                              child: Text('Abgeben', style: TextStyle(color: Colors.black)),
                            )
                          : ElevatedButton(
                              autofocus: false,
                              style: buttonstyle(main_col),
                              onPressed: _nextQuestion,
                              child: Text('Weiter', style: TextStyle(color: Colors.black)),
                            ),
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

  Widget _buildQuestionNavigationDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Fragenübersicht',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _activeParts.length,
                itemBuilder: (context, partIndex) {
                  final part = _activeParts[partIndex];
                  final questions = _partQuestions[partIndex];
                  final answers = _partAnswers[partIndex];

                  return ExpansionTile(
                    title: Text(part.name),
                    subtitle: Text('${answers.where((a) => a != null).length}/${questions.length} beantwortet'),
                    initiallyExpanded: partIndex == _currentPartIndex,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(questions.length, (qIndex) {
                            final isAnswered = answers[qIndex] != null;
                            final isCurrent = partIndex == _currentPartIndex && qIndex == _currentQuestionIndex;

                            return InkWell(
                              onTap: () => _goToQuestion(partIndex, qIndex),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? Theme.of(context).colorScheme.primary
                                      : isAnswered
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.2),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmSubmit();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Prüfung abgeben'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionImage(String imageName) {
    final svgPath = 'assets/svgs/$imageName.svg';
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final colorFilter = isDark
        ? const ColorFilter.matrix(<double>[
            -1.0, 0.0, 0.0, 0.0, 255.0,
            0.0, -1.0, 0.0, 0.0, 255.0,
            0.0, 0.0, -1.0, 0.0, 255.0,
            0.0, 0.0, 0.0, 1.0, 0.0,
          ])
        : null;
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20.0),
      maxScale: 2.0,
      panEnabled: false,
      child: SvgPicture.asset(
        svgPath,
        height: 200,
        colorFilter: colorFilter,
        placeholderBuilder: (context) => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildQuestionText(String text) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    return parseTextWithMath(text, TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: textColor));
  }

  Widget _buildAnswerOptionsWidget(
    Map<String, dynamic> question,
    List<int> order,
    int? selectedAnswer,
  ) {
    final answerKeys = ['answer_a', 'answer_b', 'answer_c', 'answer_d'];
    final pictureKeys = ['picture_a', 'picture_b', 'picture_c', 'picture_d'];
    final hasImages = question['picture_a'] != null;
    final questionColor = MediaQuery.of(context).platformBrightness == Brightness.dark 
        ? const Color.fromARGB(135, 0, 94, 255) 
        : Colors.blue.shade200;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (context, i) {
        final actualIndex = order[i];
        final isSelected = selectedAnswer == actualIndex;
        
        if (hasImages) {
          final pictureName = question[pictureKeys[actualIndex]];
          return Container(
            decoration: BoxDecoration(
              color: isSelected ? questionColor : Colors.transparent,
            ),
            child: RadioListTile<int>(
              activeColor: Theme.of(context).colorScheme.primary,
              value: actualIndex,
              groupValue: selectedAnswer,
              onChanged: (v) => _selectAnswer(actualIndex),
              title: pictureName != null
                  ? _buildQuestionImage(pictureName)
                  : const Text('Bild nicht verfügbar'),
            ),
          );
        } else {
          final answerText = question[answerKeys[actualIndex]] ?? '';
          final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
          return Container(
            decoration: BoxDecoration(
              color: isSelected ? questionColor : Colors.transparent,
            ),
            child: RadioListTile<int>(
              activeColor: Theme.of(context).colorScheme.primary,
              value: actualIndex,
              groupValue: selectedAnswer,
              onChanged: (v) => _selectAnswer(actualIndex),
              title: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: _parseTextWithMathSpans(
                    answerText,
                    TextStyle(fontWeight: FontWeight.w400, fontSize: 22, color: textColor),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  List<InlineSpan> _parseTextWithMathSpans(String input, TextStyle textStyle) {
    RegExp mathPattern = RegExp(r'\$(.*?)\$');
    List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (Match match in mathPattern.allMatches(input)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: input.substring(lastIndex, match.start), style: textStyle));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(match.group(1)!, textStyle: textStyle),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      spans.add(TextSpan(text: input.substring(lastIndex), style: textStyle));
    }

    return spans;
  }
}

Widget parseTextWithMath(String input, TextStyle textStyle) {
  RegExp mathPattern = RegExp(r'\$(.*?)\$');
  List<InlineSpan> spans = [];
  int lastIndex = 0;

  for (Match match in mathPattern.allMatches(input)) {
    if (match.start > lastIndex) {
      spans.add(TextSpan(text: input.substring(lastIndex, match.start)));
    }
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          match.group(1)!,
          textStyle: textStyle,
        ),
      ),
    );
    lastIndex = match.end;
  }

  if (lastIndex < input.length) {
    spans.add(TextSpan(text: input.substring(lastIndex)));
  }

  return RichText(
    text: TextSpan(
      style: textStyle,
      children: spans,
    ),
  );
}
