import 'package:flutter/material.dart';
import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/custom_libs/database.dart';
import 'package:fuenfzigohm/custom_libs/url_launcher.dart';
import 'package:fuenfzigohm/learning/continuous_course.dart';
import 'package:fuenfzigohm/learning/continuous_learning_session.dart';
import 'package:fuenfzigohm/screens/question.dart';

class ContinuousLearningPage extends StatefulWidget {
  const ContinuousLearningPage({
    super.key,
    required this.data,
    required this.lessons,
    required this.initialLesson,
  });

  final Map<String, dynamic> data;
  final List<CourseLesson> lessons;
  final int initialLesson;

  @override
  State<ContinuousLearningPage> createState() => _ContinuousLearningPageState();
}

class _ContinuousLearningPageState extends State<ContinuousLearningPage> {
  ContinuousLearningSession? _session;
  bool _openingLesson = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _session ??= ContinuousLearningSession(
      data: widget.data,
      lessons: widget.lessons,
      initialLesson: widget.initialLesson,
      repository: DatabaseWidget.of(context).learningStateRepository,
    );
  }

  Future<void> _startLesson(BuildContext courseContext) async {
    setState(() => _openingLesson = true);
    final session = _session!;
    session.introduceLesson();
    final first = session.nextQuestion();
    if (first == null) {
      setState(() => _openingLesson = false);
      return;
    }
    await Navigator.of(context).push<Object>(MaterialPageRoute(
      builder: (_) => Question.practice(
        courseContext,
        widget.data,
        [first],
        continuousSession: session,
      ),
    ));
    if (!mounted) return;
    setState(() {
      _openingLesson = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _session!;
    final lesson =
        session.complete ? null : widget.lessons[session.lessonIndex];
    return JsonWidget(
      Builder(builder: (courseContext) {
        return Scaffold(
          appBar: AppBar(title: const Text('Fortlaufend lernen')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (lesson == null) ...[
                      const Icon(Icons.check_circle_outline, size: 64),
                      const SizedBox(height: 24),
                      Text('Du hast deine Lernrunde geschafft!',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      const Text(
                          'Alle Fragen dieser Lernrunde wurden mindestens dreimal richtig beantwortet. '
                          'Wiederhole die Fragen regelmäßig, um dein Wissen zu festigen.'),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Zur Kursübersicht'),
                      ),
                    ] else ...[
                      Text(
                          'Lektion ${session.lessonIndex + 1} von ${widget.lessons.length}'),
                      const SizedBox(height: 8),
                      Text(lesson.chapterTitle,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      Text(lesson.title,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 16),
                      const Text(
                          'Lies zuerst die Inhalte dieser Lektion auf 50ohm.de. '
                          'So verstehst du die Zusammenhänge, bevor du die Fragen beantwortest.'),
                      const SizedBox(height: 12),
                      const Text(
                          'Neue Fragen wechseln sich mit Wiederholungen aus früheren Lektionen ab. '
                          'Eine Frage gilt nach drei richtigen Antworten als gelernt.'),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => launchExternalURL(lesson.materialUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Inhalte auf 50ohm.de lesen'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                          '${lesson.questionCount} ${lesson.questionCount == 1 ? 'Frage' : 'Fragen'}'),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _openingLesson
                            ? null
                            : () => _startLesson(courseContext),
                        child: const Text('Fragen starten'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
      widget.data,
      -1,
    );
  }
}
