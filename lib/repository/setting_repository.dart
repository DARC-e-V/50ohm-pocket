import 'package:fuenfzigohm/repository/service/setting_service.dart';

// Intermediate Layer UI <> State <> Service
class SettingRepository {
  SettingRepository({
    required this.service,
  });

  final SettingService service;

  bool get showWelcomeScreen => service.showWelcomeScreen;
  Future<void> setShowWelcomeScreen(bool value) async {
    await service.setShowWelcomeScreen(value);
    await service.flush();
  }

  Set<int> get courseClass => service.courseClass;
  Future<void> setCourseClass(Set<int> value) async {
    await service.setCourseClass(value);
    await service.flush();
  }
}
