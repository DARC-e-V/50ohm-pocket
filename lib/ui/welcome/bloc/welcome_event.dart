part of 'welcome_bloc.dart';

class WelcomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WelcomeFetchStatusEvent extends WelcomeEvent {}

class WelcomeStartEvent extends WelcomeEvent {}

class WelcomeCourseUpgradeToggleEvent extends WelcomeEvent {}

class WelcomeCourseSelectEvent extends WelcomeEvent {
  final Set<int> course;

  WelcomeCourseSelectEvent({
    required this.course,
  });

  @override
  List<Object?> get props => [course];
}
