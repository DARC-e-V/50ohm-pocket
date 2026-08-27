import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

import 'package:fuenfzigohm/constants.dart';
import 'package:fuenfzigohm/custom_libs/database.dart';
import 'package:fuenfzigohm/custom_libs/solution_index.dart';
import 'package:fuenfzigohm/custom_libs/url_launcher.dart';
import 'package:fuenfzigohm/custom_libs/video_index.dart';
import 'package:fuenfzigohm/exam/exam_simulation.dart';
import 'package:fuenfzigohm/screens/pdfViewer.dart';
import 'package:fuenfzigohm/screens/question.dart';
import 'package:fuenfzigohm/style/style.dart';

class ExamSimulationPage extends StatefulWidget {
  final List<ExamCatalogQuestion>? initialCatalog;

  const ExamSimulationPage({super.key, this.initialCatalog});

  @override
  State<ExamSimulationPage> createState() => _ExamSimulationPageState();
}

class _ExamSimulationPageState extends State<ExamSimulationPage> {
  List<ExamCatalogQuestion>? _catalog;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialCatalog != null) {
      _catalog = widget.initialCatalog;
    } else {
      _loadCatalog();
    }
  }

  Future<void> _loadCatalog() async {
    try {
      final raw =
          await rootBundle.loadString('assets/questions/Questions.json');
      final catalog = buildExamCatalog(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (!mounted) return;
      setState(() => _catalog = catalog);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Der Fragenkatalog konnte nicht geladen werden.');
      debugPrint('Could not load exam catalog: $error');
    }
  }

  void _startExam(ExamChoice choice) {
    final catalog = _catalog;
    if (catalog == null) return;
    try {
      final parts = ExamBuilder().build(catalog, choice);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExamSessionPage(choice: choice, parts: parts),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prüfungssimulation')),
      body: SafeArea(
        child: _error != null
            ? Center(child: Text(_error!))
            : _catalog == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 850),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Prüfungssimulation',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Welche Prüfung möchtest du simulieren?',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 36),
                            _ExamChoiceSection(
                              title: 'Erstprüfung',
                              description: 'Du hast noch keine '
                                  'Amateurfunkprüfung abgelegt? Dann ist das '
                                  'die richtige Simulation für dich.',
                              choices: _choices(ExamChoiceGroup.primary),
                              onSelected: _startExam,
                            ),
                            const SizedBox(height: 32),
                            _ExamChoiceSection(
                              title: 'Aufstockungsprüfung',
                              description: 'Du hast bereits eine Zulassung '
                                  'zum Amateurfunkdienst und möchtest in eine '
                                  'höhere Klasse aufstocken? Dann wähle hier '
                                  'die passende Prüfung.',
                              choices: _choices(ExamChoiceGroup.upgrade),
                              onSelected: _startExam,
                            ),
                            const SizedBox(height: 32),
                            _ExamChoiceSection(
                              title: 'Einzelne Prüfungsteile',
                              description: 'Übe gezielt einen Prüfungsteil '
                                  'unter Prüfungsbedingungen.',
                              choices: _choices(ExamChoiceGroup.single),
                              onSelected: _startExam,
                              compact: true,
                            ),
                            const SizedBox(height: 28),
                            Card(
                              child: const Padding(
                                padding: EdgeInsets.all(18),
                                child: Text(
                                  'Jeder Prüfungsteil enthält 25 Fragen. Für '
                                  'B, V, N und E stehen jeweils 45 Minuten '
                                  'zur Verfügung, für Technik A 60 Minuten. '
                                  'Ein Teil ist ab 19 Punkten bestanden.',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  List<ExamChoice> _choices(ExamChoiceGroup group) =>
      examChoices.where((choice) => choice.group == group).toList();
}

class _ExamChoiceSection extends StatelessWidget {
  final String title;
  final String description;
  final List<ExamChoice> choices;
  final ValueChanged<ExamChoice> onSelected;
  final bool compact;

  const _ExamChoiceSection({
    required this.title,
    required this.description,
    required this.choices,
    required this.onSelected,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(description, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700
                ? (compact ? 5 : 3)
                : constraints.maxWidth >= 470
                    ? 3
                    : 1;
            final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: choices.map((choice) {
                return SizedBox(
                  width: width,
                  height: compact ? 100 : 96,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: choice.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => onSelected(choice),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          choice.label,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          choice.detail,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class ExamSessionPage extends StatefulWidget {
  final ExamChoice choice;
  final List<ExamPartResult> parts;

  const ExamSessionPage({
    super.key,
    required this.choice,
    required this.parts,
  });

  @override
  State<ExamSessionPage> createState() => _ExamSessionPageState();
}

class _ExamSessionPageState extends State<ExamSessionPage> {
  int _partIndex = 0;
  int _questionIndex = 0;
  int? _selectedAnswer;
  late DateTime _deadline;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _transitioning = false;
  bool _paused = false;

  ExamPartResult get _part => widget.parts[_partIndex];
  ExamQuestionResult get _question => _part.questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _startPartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPartTimer() {
    _timer?.cancel();
    _deadline = DateTime.now().add(_part.definition.duration);
    _remainingSeconds = _part.definition.duration.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _transitioning || _paused) return;
      final remaining = _deadline.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        setState(() => _remainingSeconds = 0);
        _finishPart(timedOut: true);
      } else {
        setState(() => _remainingSeconds = remaining);
      }
    });
  }

  void _toggleTimer() {
    if (_transitioning) return;
    setState(() {
      if (_paused) {
        _deadline = DateTime.now().add(Duration(seconds: _remainingSeconds));
      }
      _paused = !_paused;
    });
  }

  Future<void> _continue() async {
    if (_selectedAnswer == null || _transitioning) return;
    await _recordCurrentAnswer();
    if (!mounted) return;
    if (_questionIndex < _part.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedAnswer = _part.questions[_questionIndex].selectedAnswer;
      });
      return;
    }
    await _finishPart(timedOut: false);
  }

  Future<void> _recordCurrentAnswer() async {
    final selected = _selectedAnswer;
    if (selected == null || _question.selectedAnswer != null) return;
    _question.selectedAnswer = selected;
    await DatabaseWidget.of(context).learningStateRepository.recordAnswer(
          questionId: _question.question.id,
          correct: selected == 0,
          selectedAnswerKey: const ['a', 'b', 'c', 'd'][selected],
          source: 'exam',
        );
  }

  Future<void> _finishPart({required bool timedOut}) async {
    if (_transitioning) return;
    _transitioning = true;
    _timer?.cancel();
    if (_selectedAnswer != null) await _recordCurrentAnswer();
    _part.timedOut = timedOut;
    _part.evaluate();
    if (!mounted) return;

    if (_partIndex == widget.parts.length - 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ExamResultPage(
            choice: widget.choice,
            parts: widget.parts,
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          timedOut ? 'Die Zeit ist abgelaufen' : 'Prüfungsteil abgeschlossen',
        ),
        content: Text(
          'Als Nächstes folgt ${widget.parts[_partIndex + 1].definition.label}. '
          'Die Auswertung erhältst du am Ende der Simulation.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Nächsten Teil starten'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() {
      _partIndex++;
      _questionIndex = 0;
      _selectedAnswer = null;
      _transitioning = false;
      _paused = false;
    });
    _startPartTimer();
  }

  Future<bool> _confirmAbort() async {
    if (_transitioning) return false;
    final abort = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Simulation abbrechen?'),
        content: const Text(
          'Bereits beantwortete Fragen bleiben in deinem Lernstand gespeichert.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Fortsetzen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
    if (abort == true) {
      await _recordCurrentAnswer();
      return true;
    }
    return false;
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop || !await _confirmAbort() || !context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.choice.label),
          actions: [
            IconButton(
              icon: const Icon(Icons.description),
              tooltip: 'Hilfsmittel',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfViewer(
                    1,
                    'assets/pdf/Hilfsmittel_12062024.pdf',
                    'Hilfsmittel',
                  ),
                ),
              ),
            ),
            Semantics(
              button: true,
              label: _paused
                  ? 'Timer fortsetzen, verbleibende Zeit $_formattedTime'
                  : 'Timer pausieren, verbleibende Zeit $_formattedTime',
              child: TextButton.icon(
                onPressed: _toggleTimer,
                icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
                label: Text(
                  _formattedTime,
                  style: TextStyle(
                    color: _remainingSeconds <= 300
                        ? Theme.of(context).colorScheme.error
                        : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_questionIndex + 1) / _part.questions.length,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _part.definition.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${_questionIndex + 1}/${_part.questions.length}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    ExamQuestionCard(
                      key: ValueKey(_question.question.id),
                      question: _question,
                      selectedAnswer: _selectedAnswer,
                      onSelected: _paused
                          ? null
                          : (answer) {
                              setState(() => _selectedAnswer = answer);
                            },
                    ),
                    if (_paused)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.92),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.pause_circle_outline, size: 64),
                                SizedBox(height: 12),
                                Text(
                                  'Timer pausiert',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: buttonstyle(main_col),
                      onPressed:
                          _selectedAnswer == null || _transitioning || _paused
                              ? null
                              : _continue,
                      child: Text(
                        _questionIndex == _part.questions.length - 1
                            ? 'Prüfungsteil abschließen'
                            : 'Weiter',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExamQuestionCard extends StatelessWidget {
  final ExamQuestionResult question;
  final int? selectedAnswer;
  final ValueChanged<int>? onSelected;
  final bool revealResult;

  const ExamQuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswer,
    this.onSelected,
    this.revealResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = question.question.data;
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 40),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text.rich(
            TextSpan(
              children: parseTextWithMath(
                data['question']?.toString() ?? '',
                Theme.of(context).textTheme.titleLarge ?? const TextStyle(),
              ),
            ),
          ),
        ),
        if (data['picture_question'] != null) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ExamPicture(
              id: data['picture_question'].toString(),
            ),
          ),
        ],
        const Divider(height: 32),
        for (var displayIndex = 0;
            displayIndex < question.answerOrder.length;
            displayIndex++)
          _ExamAnswerTile(
            data: data,
            sourceIndex: question.answerOrder[displayIndex],
            selected: selectedAnswer == question.answerOrder[displayIndex],
            revealResult: revealResult,
            onTap: onSelected == null
                ? null
                : () => onSelected!(question.answerOrder[displayIndex]),
          ),
      ],
    );
  }
}

class _ExamAnswerTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final int sourceIndex;
  final bool selected;
  final bool revealResult;
  final VoidCallback? onTap;

  const _ExamAnswerTile({
    required this.data,
    required this.sourceIndex,
    required this.selected,
    required this.revealResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const keys = ['a', 'b', 'c', 'd'];
    final key = keys[sourceIndex];
    final isCorrect = sourceIndex == 0;
    final background = revealResult
        ? isCorrect
            ? correctFeedbackColor
            : selected
                ? incorrectFeedbackColor
                : Colors.transparent
        : Colors.transparent;
    final text = data['answer_$key']?.toString();
    final picture = data['picture_$key']?.toString();

    return Container(
      color: background,
      child: RadioListTile<int>(
        value: sourceIndex,
        groupValue: selected ? sourceIndex : null,
        onChanged: onTap == null ? null : (_) => onTap!(),
        fillColor: MaterialStateColor.resolveWith((states) => main_col),
        activeColor: main_col,
        secondary: revealResult && (isCorrect || selected)
            ? Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (text != null && text.isNotEmpty)
              Text.rich(
                TextSpan(
                  children: parseTextWithMath(
                    text,
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: revealResult && (isCorrect || selected)
                                  ? Colors.black87
                                  : null,
                            ) ??
                        const TextStyle(),
                  ),
                ),
              ),
            if (picture != null && picture.isNotEmpty)
              _ExamPicture(
                id: picture,
                useDarkForeground: revealResult && (isCorrect || selected),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExamPicture extends StatelessWidget {
  final String id;
  final bool useDarkForeground;

  const _ExamPicture({required this.id, this.useDarkForeground = false});

  @override
  Widget build(BuildContext context) {
    const pngPictures = {
      'BE207_q',
      'NF106_q',
      'BE209_q',
      'NF104_q',
      'NF102_q',
      'NF105_q',
      'BE208_q',
      'NE209_q',
      'NG302_q',
      'NF103_q',
      'NF101_q',
    };
    final width = min(MediaQuery.sizeOf(context).width * 0.8, 500.0);
    final invert =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark &&
            !useDarkForeground;
    final filter = invert
        ? const ColorFilter.matrix([
            -1,
            0,
            0,
            0,
            255,
            0,
            -1,
            0,
            0,
            255,
            0,
            0,
            -1,
            0,
            255,
            0,
            0,
            0,
            1,
            0,
          ])
        : null;
    final image = pngPictures.contains(id)
        ? Image.asset('assets/svgs/$id.png', width: width)
        : SvgPicture.asset('assets/svgs/$id.svg', width: width);
    return Center(
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        maxScale: 1.6,
        panEnabled: false,
        child: filter == null
            ? image
            : ColorFiltered(colorFilter: filter, child: image),
      ),
    );
  }
}

class ExamResultPage extends StatelessWidget {
  final ExamChoice choice;
  final List<ExamPartResult> parts;

  const ExamResultPage({
    super.key,
    required this.choice,
    required this.parts,
  });

  @override
  Widget build(BuildContext context) {
    final state = evaluateExam(parts);
    return Scaffold(
      appBar: AppBar(title: const Text('Prüfungsergebnis')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    _resultIcon(state),
                    size: 72,
                    color: _resultColor(context, state),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _resultTitle(state),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _resultDescription(state),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _share(context),
                    icon: const Icon(Icons.share),
                    label: const Text('Ergebnis teilen'),
                  ),
                  const SizedBox(height: 28),
                  for (var partIndex = 0;
                      partIndex < parts.length;
                      partIndex++) ...[
                    _PartResultCard(part: parts[partIndex]),
                    const SizedBox(height: 16),
                  ],
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Neue Simulation'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      '${examShareText(choice, parts)}\n${examResultUri(choice, parts)}',
      subject: '50ohm.de-Prüfungssimulation',
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  static IconData _resultIcon(ExamOverallState state) => switch (state) {
        ExamOverallState.passed => Icons.verified,
        ExamOverallState.oral => Icons.record_voice_over,
        ExamOverallState.failed => Icons.cancel,
        ExamOverallState.incomplete => Icons.stop_circle,
      };

  static Color _resultColor(BuildContext context, ExamOverallState state) =>
      switch (state) {
        ExamOverallState.passed => Colors.green,
        ExamOverallState.oral => Colors.orange,
        ExamOverallState.failed ||
        ExamOverallState.incomplete =>
          Theme.of(context).colorScheme.error,
      };

  static String _resultTitle(ExamOverallState state) => switch (state) {
        ExamOverallState.passed => 'Prüfung bestanden',
        ExamOverallState.oral => 'Mündliche Nachprüfung möglich',
        ExamOverallState.failed => 'Prüfung nicht bestanden',
        ExamOverallState.incomplete => 'Prüfung vorzeitig beendet',
      };

  static String _resultDescription(ExamOverallState state) => switch (state) {
        ExamOverallState.passed =>
          'Gratulation! Du hast jeden Prüfungsteil mit mindestens 19 Punkten bestanden.',
        ExamOverallState.oral =>
          'In genau einem Prüfungsteil wurden 17 oder 18 Punkte erreicht. Eine mündliche Nachprüfung kann möglich sein.',
        ExamOverallState.failed =>
          'Mindestens ein Prüfungsteil wurde nicht bestanden.',
        ExamOverallState.incomplete =>
          'Nicht alle Prüfungsteile wurden abgeschlossen.',
      };
}

class _PartResultCard extends StatelessWidget {
  final ExamPartResult part;

  const _PartResultCard({required this.part});

  @override
  Widget build(BuildContext context) {
    final score = part.score ?? 0;
    final color = score >= examPassingScore
        ? Colors.green
        : score >= 17
            ? Colors.orange
            : Theme.of(context).colorScheme.error;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${part.definition.code} – ${part.definition.label}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '$score/${part.questions.length}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < part.questions.length; index++)
                  _QuestionResultButton(
                    number: index + 1,
                    result: part.questions[index],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionResultButton extends StatelessWidget {
  final int number;
  final ExamQuestionResult result;

  const _QuestionResultButton({required this.number, required this.result});

  @override
  Widget build(BuildContext context) {
    final color = !result.answered
        ? Colors.grey
        : result.correct
            ? Colors.green
            : Theme.of(context).colorScheme.error;
    return Tooltip(
      message: !result.answered
          ? 'Nicht beantwortet'
          : result.correct
              ? 'Richtig beantwortet'
              : 'Falsch beantwortet – Auswertung öffnen',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: result.answered
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExamReviewPage(result: result),
                  ),
                )
            : null,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ExamReviewPage extends StatelessWidget {
  final ExamQuestionResult result;

  const ExamReviewPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(result.question.id),
        actions: [
          if (SolutionIndex.hasSolution(result.question.id))
            IconButton(
              icon: const Icon(Icons.lightbulb, color: Colors.amber),
              tooltip: 'Lösungshinweis auf 50ohm.de',
              onPressed: () => launchURL(
                SolutionIndex.urlFor(result.question.id),
              ),
            ),
          if (VideoIndex.hasVideo(result.question.id))
            IconButton(
              icon: const Icon(Icons.smart_display, color: Colors.red),
              tooltip: 'Lernvideo von DL2YMR',
              onPressed: () => launchExternalURL(
                VideoIndex.urlFor(result.question.id)!,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ExamQuestionCard(
          question: result,
          selectedAnswer: result.selectedAnswer,
          revealResult: true,
        ),
      ),
    );
  }
}
