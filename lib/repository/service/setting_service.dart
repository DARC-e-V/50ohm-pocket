import 'package:hive_ce_flutter/hive_flutter.dart';

class SettingService {
  static const String SETTINGS_WELCOME_PAGE_KEY = 'welcomePage';
  static const String SETTINGS_CLASS_KEY = 'Klasse';
  static const String SETTINGS_COURSE_ORDER_KEY = 'courseOrdering';

  final Box<dynamic> settings_database;

  SettingService({
    required this.settings_database,
  });

  bool get showWelcomeScreen =>
      settings_database.containsKey(SETTINGS_WELCOME_PAGE_KEY);

  Future<void> setShowWelcomeScreen(bool value) =>
      settings_database.put(SETTINGS_WELCOME_PAGE_KEY, value);

  Set<int> get courseClass {
    final storedCourse = settings_database.get(SETTINGS_CLASS_KEY);
    if (storedCourse is! Iterable) {
      return {};
    }
    return storedCourse.whereType<int>().toSet();
  }

  Future<void> setCourseClass(Set<int> course) async =>
      settings_database.put(SETTINGS_CLASS_KEY, [...course]);

  Future<void> flush() async => settings_database.flush();
}
