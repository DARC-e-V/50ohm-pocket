import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:fuenfzigohm/repository/setting_repository.dart';
import 'package:fuenfzigohm/ui/welcome/bloc/welcome_bloc.dart';

class MockSettingRepository extends Mock implements SettingRepository {}

void main() {
  group(WelcomeBloc, () {
    late SettingRepository settingRepository;
    late WelcomeBloc welcomeBloc;

    setUp(() {
      settingRepository = MockSettingRepository();
      when(() => settingRepository.showWelcomeScreen).thenReturn(true);
      when(() => settingRepository.courseClass).thenReturn({1});
      when(() => settingRepository.setCourseClass(any()))
          .thenAnswer((_) async {});
      when(() => settingRepository.setShowWelcomeScreen(any()))
          .thenAnswer((_) async {});

      welcomeBloc = WelcomeBloc(
        settingRepository: settingRepository,
      );
    });

    test('initial state is correct', () {
      expect(welcomeBloc.state.status, equals(WelcomeStatus.initial));
    });

    blocTest<WelcomeBloc, WelcomeState>(
      'opens the learning module when onboarding is already complete',
      build: () => welcomeBloc,
      act: (bloc) => bloc.add(WelcomeFetchStatusEvent()),
      expect: () => [
        WelcomeState(status: WelcomeStatus.courseSelected),
      ],
    );

    blocTest<WelcomeBloc, WelcomeState>(
      'opens course selection when an existing course is changed in settings',
      setUp: () {
        when(() => settingRepository.showWelcomeScreen).thenReturn(false);
      },
      build: () => welcomeBloc,
      act: (bloc) => bloc.add(WelcomeFetchStatusEvent()),
      expect: () => [
        WelcomeState(status: WelcomeStatus.courseSelection),
      ],
    );

    blocTest<WelcomeBloc, WelcomeState>(
      'shows the greeting on a fresh installation',
      setUp: () {
        when(() => settingRepository.showWelcomeScreen).thenReturn(false);
        when(() => settingRepository.courseClass).thenReturn({});
      },
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
      'returns from course selection to the greeting during onboarding',
      seed: () => WelcomeState(status: WelcomeStatus.courseSelection),
      build: () => welcomeBloc,
      act: (bloc) => bloc.add(WelcomeBackEvent()),
      expect: () => [
        WelcomeState(status: WelcomeStatus.initial),
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
