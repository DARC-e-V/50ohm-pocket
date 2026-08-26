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
    on<WelcomeBackEvent>(_mapWelcomeBackEventToState);
    on<WelcomeCourseSelectEvent>(_mapWelcomeCourseSelectEventToState);
  }

  final SettingRepository settingRepository;

  void _mapWelcomeFetchStatusEventToState(
    WelcomeFetchStatusEvent event,
    Emitter emit,
  ) async {
    final hasSelectedCourse = settingRepository.courseClass.isNotEmpty;
    emit(this.state.copyWith(
          status: settingRepository.showWelcomeScreen
              ? WelcomeStatus.courseSelected
              : hasSelectedCourse
                  ? WelcomeStatus.courseSelection
                  : WelcomeStatus.initial,
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

  void _mapWelcomeBackEventToState(
    WelcomeBackEvent event,
    Emitter emit,
  ) async {
    emit(state.copyWith(status: WelcomeStatus.initial));
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
