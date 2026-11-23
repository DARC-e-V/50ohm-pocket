import 'package:hive_ce/hive.dart';

enum LearningMode {
  course('50ohm', 'Lektionen einzeln in der Reihenfolge von 50ohm.de lernen.'),
  continuous('Fortlaufend',
      'Neue Lektionen auf 50ohm.de kennenlernen und frühere Fragen gemischt wiederholen.'),
  catalog('Fragenkatalog', 'Fragen nach dem amtlichen Fragenkatalog lernen.');

  const LearningMode(this.label, this.description);

  final String label;
  final String description;

  static LearningMode read(Box settings) {
    final stored = settings.get('learningMode');
    for (final mode in values) {
      if (mode.name == stored) return mode;
    }
    return settings.get('courseOrdering', defaultValue: true) == false
        ? catalog
        : course;
  }

  Future<void> save(Box settings) async {
    await settings.put('learningMode', name);
    await settings.put('courseOrdering', this != catalog);
  }
}
