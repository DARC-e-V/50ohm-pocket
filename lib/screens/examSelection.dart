import 'package:flutter/material.dart';
import 'package:fuenfzigohm/models/exam_config.dart';
import 'package:fuenfzigohm/screens/examSimulation.dart';

class ExamSelectionScreen extends StatelessWidget {
  const ExamSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prüfungssimulation'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Wähle eine Prüfung aus, um unter realistischen Bedingungen zu üben.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            _buildExamCard(
              context,
              config: ExamConfigs.klasseN,
              color: const Color(0xff47ABE8),
            ),
            _buildExamCard(
              context,
              config: ExamConfigs.klasseE,
              color: const Color(0xffFE756C),
            ),
            _buildExamCard(
              context,
              config: ExamConfigs.klasseA,
              color: const Color(0xff3BB583),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCard(
    BuildContext context, {
    required ExamConfig config,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _showExamOptions(context, config),
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      config.displayName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(Icons.quiz_outlined, size: 32),
                  ],
                ),
                const SizedBox(height: 8),
                ...config.parts.map((part) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${part.name}: ${part.questionCount} Fragen, ${part.timeMinutes} Min',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gesamt: ${config.totalQuestions} Fragen, ${config.totalTimeMinutes} Min',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExamOptions(BuildContext context, ExamConfig config) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ExamOptionsSheet(config: config),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

class ExamOptionsSheet extends StatelessWidget {
  final ExamConfig config;

  const ExamOptionsSheet({Key? key, required this.config}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${config.displayName} - Prüfung starten',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              icon: Icons.playlist_play,
              title: 'Komplette Prüfung',
              subtitle: '${config.totalQuestions} Fragen, ${config.totalTimeMinutes} Minuten',
              onTap: () => _startExam(context, config, null),
            ),
            const Divider(),
            if (config.parts.length > 1) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Oder einzelne Teile:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...config.parts.asMap().entries.map((entry) => _buildOption(
                context,
                icon: Icons.play_circle_outline,
                title: entry.value.name,
                subtitle: '${entry.value.questionCount} Fragen, ${entry.value.timeMinutes} Min',
                onTap: () => _startExam(context, config, entry.key),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _startExam(BuildContext context, ExamConfig config, int? partIndex) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamSimulationScreen(
          config: config,
          partIndex: partIndex,
        ),
      ),
    );
  }
}
