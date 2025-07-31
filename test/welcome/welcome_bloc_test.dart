import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:fuenfzigohm/repository/setting_repository.dart';
import 'package:fuenfzigohm/ui/welcome/bloc/welcome_bloc.dart';

class MockSettingRepository extends Mock implements SettingRepository {}

void main() {
  group(WelcomeBloc, () {
    SettingRepository settingRepository;
    late WelcomeBloc welcomeBloc;

    setUp(() {
      settingRepository = MockSettingRepository();
      when(() => settingRepository.showWelcomeScreen).thenReturn(true);
      when(() => settingRepository.courseClass).thenReturn({});

      welcomeBloc = WelcomeBloc(
        settingRepository: settingRepository,
      );
    });

    test('initial state is correct', () {
      expect(welcomeBloc.state.status, equals(WelcomeStatus.initial));
    });

    blocTest<WelcomeBloc, WelcomeState>(
      'emits initial when WelcomeFetchStatusEvent is added',
      build: () => welcomeBloc,
      act: (bloc) => bloc.add(WelcomeFetchStatusEvent()),
      expect: () => [
        WelcomeState(status: WelcomeStatus.initial),
      ],
    );

    blocTest<WelcomeBloc, WelcomeState>(
      'emits courseSelection when WelcomeStartEvent is added',
      build: () => welcomeBloc,
      act: (bloc) => bloc.add(WelcomeStartEvent()),
      expect: () => [
        WelcomeState(status: WelcomeStatus.courseSelection),
      ],
    );

    blocTest<WelcomeBloc, WelcomeState>(
      'emits courseUpgradeSelection when WelcomeCourseUpgradeToggleEvent is added',
      build: () => welcomeBloc,
      act: (bloc) => bloc.add(WelcomeCourseUpgradeToggleEvent()),
      expect: () => [
        WelcomeState(status: WelcomeStatus.updateCourseSelection),
      ],
    );

    blocTest<WelcomeBloc, WelcomeState>(
      'emits courseSelection when WelcomeCourseUpgradeToggleEvent is added',
      build: () => welcomeBloc,
      seed: () => WelcomeState(status: WelcomeStatus.updateCourseSelection),
      act: (bloc) => bloc.add(WelcomeCourseUpgradeToggleEvent()),
      expect: () => [
        WelcomeState(status: WelcomeStatus.courseSelection),
      ],
    );

    blocTest<WelcomeBloc, WelcomeState>(
      'emits course when WelcomeCourseSelectEvent is added',
      build: () => welcomeBloc,
      act: (bloc) => bloc.add(WelcomeCourseSelectEvent(course: {1})),
      expect: () => [
        WelcomeState(status: WelcomeStatus.courseSelected),
      ],
    );
  });
}
