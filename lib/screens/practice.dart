import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fuenfzigohm/custom_libs/database.dart';
import 'package:fuenfzigohm/custom_libs/json.dart';
import 'package:fuenfzigohm/repository/models/course_class.dart';
import 'package:fuenfzigohm/screens/question.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  bool _isStarting = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Üben')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school, size: 64),
                      const SizedBox(height: 20),
                      Text(
                        'Übungsrunde',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Hier übst du Fragen, die du bereits beantwortet '
                        'hast. Fragen, die noch in Arbeit sind, erscheinen '
                        'besonders häufig. Bereits gelernte Fragen werden '
                        'gelegentlich wiederholt.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Deine Antworten werden sofort gespeichert. Du '
                        'kannst die Übung jederzeit beenden.',
                        textAlign: TextAlign.center,
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            disabledBackgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                          onPressed: _isStarting ? null : _startPractice,
                          child: _isStarting
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : const Text('Übung starten'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startPractice() async {
    setState(() {
      _isStarting = true;
      _message = null;
    });

    try {
      final settingsBox = DatabaseWidget.of(context).settings_database;
      final storedClasses = settingsBox.get('Klasse');
      final selectedClasses = storedClasses is Iterable
          ? storedClasses.whereType<num>().map((value) => value.toInt()).toSet()
          : <int>{1};
      final assetPath = CourseClass.getCourseResourcePath(
        selectedClasses.isEmpty ? <int>{1} : selectedClasses,
      );
      final data = jsonDecode(await rootBundle.loadString(assetPath))
          as Map<String, dynamic>;
      final references = Json(data).getQuestionReferences(-1);
      final answeredIds = DatabaseWidget.of(context)
          .learningStateRepository
          .answeredQuestionIds;
      final available = references
          .where((reference) => answeredIds.contains(reference.questionId))
          .toList();

      if (!mounted) return;
      if (available.isEmpty) {
        setState(() {
          _message = 'Du hast noch keine Fragen zum Üben. Beantworte '
              'zunächst einige Fragen im Kurs oder im Fragenkatalog.';
        });
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Question.practice(context, data, available),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = 'Die Übungsfragen konnten nicht geladen werden.';
      });
      debugPrint('Could not start practice: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }
}
