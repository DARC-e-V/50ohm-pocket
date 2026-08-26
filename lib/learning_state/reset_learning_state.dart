import 'package:hive/hive.dart';

import 'learning_state_repository.dart';

/// Deletes all answer history without touching course or app settings.
///
/// The legacy box is cleared as well, while the completed migration marker in
/// the settings box remains. This prevents deleted legacy scores from being
/// imported again on the next app start.
Future<void> resetLearningState({
  required LearningStateRepository repository,
  required Box<dynamic> legacyProgressBox,
}) async {
  await legacyProgressBox.clear();
  await repository.clearAnswers();
}
