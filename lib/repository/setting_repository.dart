import 'package:fuenfzigohm/repository/service/setting_service.dart';

// Intermediate Layer UI <> State <> Service
class SettingRepository {
  SettingRepository({
    required this.service,
  });

  final SettingService service;

  bool get showWelcomeScreen => service.showWelcomeScreen;
  setShowWelcomeScreen(bool value) {
    service.setShowWelcomeScreen(value);
    return service.flush();
  }

  Set<int> get courseClass => service.courseClass;
  setCourseClass(Set<int> value) {
    service.setCourseClass(value);
    return service.flush();
  }
}
