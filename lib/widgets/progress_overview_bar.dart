import 'package:flutter/material.dart';

const learningProgressExplanation =
    'Gelernt: mindestens dreimal richtig beantwortet.\n'
    'In Arbeit: bereits beantwortet, aber noch nicht dreimal richtig.\n'
    'Offen: noch nie beantwortet.\n\n'
    'Die Balken der einzelnen Abschnitte wachsen mit jeder richtigen Antwort. '
    'Pro Frage zählen bis zu drei richtige Antworten. Vollständig ist ein '
    'Balken, wenn jede Frage des Abschnitts dreimal richtig beantwortet wurde. '
    'Falsche Antworten verringern den Fortschritt nicht.';

/// A widget that displays a horizontal bar where each vertical stripe
/// represents a question, color-coded by learning progress score.
class ProgressOverviewBar extends StatelessWidget {
  /// List of scores for each question.
  /// Score meaning: 0 = no correct answer, 1 = 1x correct,
  /// 2 = 2x correct, 3+ = learned.
  final List<int> questionScores;

  /// Whether each question has been answered at least once. This separates
  /// unseen questions from seen questions that currently have zero points.
  final List<bool> answeredQuestions;

  /// Height of the progress bar
  final double height;

  const ProgressOverviewBar({
    Key? key,
    required this.questionScores,
    required this.answeredQuestions,
    this.height = 24.0,
  })  : assert(questionScores.length == answeredQuestions.length),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (questionScores.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _ProgressBarPainter(
          scores: questionScores,
          answered: answeredQuestions,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final List<int> scores;
  final List<bool> answered;
  final bool isDarkMode;

  _ProgressBarPainter({
    required this.scores,
    required this.answered,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final double stripeWidth = size.width / scores.length;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < scores.length; i++) {
      paint.color = _getColorForScore(scores[i], answered[i]);

      final Rect rect = Rect.fromLTWH(
        i * stripeWidth,
        0,
        stripeWidth + 0.5, // Slight overlap to prevent gaps
        size.height,
      );

      canvas.drawRect(rect, paint);
    }
  }

  Color _getColorForScore(int score, bool hasBeenAnswered) {
    if (score <= 0) {
      return hasBeenAnswered
          ? (isDarkMode ? Colors.deepOrange.shade400 : Colors.deepOrange)
          : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400);
    } else if (score == 1) {
      // 1x correct - vibrant orange
      return isDarkMode ? Colors.deepOrange.shade400 : Colors.deepOrange;
    } else if (score == 2) {
      // 2x correct - yellow
      return isDarkMode ? Colors.yellow.shade700 : Colors.yellow.shade600;
    } else {
      // 3+ correct - green (learned)
      return isDarkMode ? Colors.green.shade600 : Colors.green.shade500;
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressBarPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.answered != answered ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}

/// A more detailed progress overview with legend
class ProgressOverviewCard extends StatelessWidget {
  final List<int> questionScores;
  final List<bool> answeredQuestions;

  const ProgressOverviewCard({
    Key? key,
    required this.questionScores,
    required this.answeredQuestions,
  })  : assert(questionScores.length == answeredQuestions.length),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final int total = questionScores.length;
    final int learned = questionScores.where((s) => s >= 3).length;
    final int inProgress = List.generate(
      total,
      (index) => answeredQuestions[index] && questionScores[index] < 3,
    ).where((isInProgress) => isInProgress).length;
    final int notStarted =
        answeredQuestions.where((answered) => !answered).length;
    final double percentage = total > 0 ? (learned / total) * 100 : 0;

    return Tooltip(
      message: learningProgressExplanation,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: Duration(seconds: 8),
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Lernstand',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.info_outline, size: 16),
                    ],
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}% gelernt',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ProgressOverviewBar(
                questionScores: questionScores,
                answeredQuestions: answeredQuestions,
                height: 20,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendItem(
                    color: Colors.green,
                    label: 'Gelernt',
                    count: learned,
                  ),
                  _LegendItem(
                    color: Colors.orange,
                    label: 'In Arbeit',
                    count: inProgress,
                  ),
                  _LegendItem(
                    color: Colors.grey,
                    label: 'Offen',
                    count: notStarted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
