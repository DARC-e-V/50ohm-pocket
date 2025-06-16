import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fuenfzigohm/repository/setting_repository.dart';

part 'welcome_event.dart';
part 'welcome_state.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc({
    required this.settingRepository,
  }) : super(const WelcomeState()) {
    on<WelcomeFetchStatusEvent>(_mapWelcomeFetchStatusEventToState);
    on<WelcomeStartEvent>(_mapWelcomeStartEventToState);
    on<WelcomeCourseUpgradeToggleEvent>(
        _mapWelcomeCourseUpgradeToggleEventToState);
    on<WelcomeCourseSelectEvent>(_mapWelcomeCourseSelectEventToState);
  }

  final SettingRepository settingRepository;

  void _mapWelcomeFetchStatusEventToState(
    WelcomeFetchStatusEvent event,
    Emitter emit,
  ) async {
    emit(this.state.copyWith(
          status: settingRepository.showWelcomeScreen
              ? WelcomeStatus.initial
              : WelcomeStatus.courseSelection,
        ));
  }

  void _mapWelcomeStartEventToState(
    WelcomeStartEvent event,
    Emitter emit,
  ) async {
    emit(this.state.copyWith(
          status: WelcomeStatus.courseSelection,
        ));
  }

  void _mapWelcomeCourseUpgradeToggleEventToState(
    WelcomeCourseUpgradeToggleEvent event,
    Emitter emit,
  ) async {
    emit(this.state.copyWith(
          status: state.status == WelcomeStatus.updateCourseSelection
              ? WelcomeStatus.courseSelection
              : WelcomeStatus.updateCourseSelection,
        ));
  }

  void _mapWelcomeCourseSelectEventToState(
    WelcomeCourseSelectEvent event,
    Emitter emit,
  ) async {
    await settingRepository.setCourseClass(event.course);
    await settingRepository.setShowWelcomeScreen(true);
    emit(state.copyWith(
      status: WelcomeStatus.courseSelected,
    ));
  }
}
