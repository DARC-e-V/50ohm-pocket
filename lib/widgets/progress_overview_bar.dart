import 'package:flutter/material.dart';

/// A widget that displays a horizontal bar where each vertical stripe
/// represents a question, color-coded by learning progress score.
class ProgressOverviewBar extends StatelessWidget {
  /// List of scores for each question.
  /// Score meaning: 0 = not answered/wrong, 1 = 1x correct, 2 = 2x correct, 3+ = learned
  final List<int> questionScores;
  
  /// Height of the progress bar
  final double height;
  
  const ProgressOverviewBar({
    Key? key,
    required this.questionScores,
    this.height = 24.0,
  }) : super(key: key);

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
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final List<int> scores;
  final bool isDarkMode;

  _ProgressBarPainter({
    required this.scores,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final double stripeWidth = size.width / scores.length;
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < scores.length; i++) {
      paint.color = _getColorForScore(scores[i]);
      
      final Rect rect = Rect.fromLTWH(
        i * stripeWidth,
        0,
        stripeWidth + 0.5, // Slight overlap to prevent gaps
        size.height,
      );
      
      canvas.drawRect(rect, paint);
    }
  }

  Color _getColorForScore(int score) {
    if (score <= 0) {
      // Not answered or wrong - gray/red
      return isDarkMode 
          ? Colors.grey.shade700 
          : Colors.grey.shade400;
    } else if (score == 1) {
      // 1x correct - orange
      return isDarkMode 
          ? Colors.orange.shade700 
          : Colors.orange.shade400;
    } else if (score == 2) {
      // 2x correct - yellow
      return isDarkMode 
          ? Colors.yellow.shade700 
          : Colors.yellow.shade600;
    } else {
      // 3+ correct - green (learned)
      return isDarkMode 
          ? Colors.green.shade600 
          : Colors.green.shade500;
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressBarPainter oldDelegate) {
    return oldDelegate.scores != scores || oldDelegate.isDarkMode != isDarkMode;
  }
}

/// A more detailed progress overview with legend
class ProgressOverviewCard extends StatelessWidget {
  final List<int> questionScores;
  
  const ProgressOverviewCard({
    Key? key,
    required this.questionScores,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final int total = questionScores.length;
    final int learned = questionScores.where((s) => s >= 3).length;
    final int inProgress = questionScores.where((s) => s > 0 && s < 3).length;
    final int notStarted = questionScores.where((s) => s <= 0).length;
    final double percentage = total > 0 ? (learned / total) * 100 : 0;
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lernstand',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
