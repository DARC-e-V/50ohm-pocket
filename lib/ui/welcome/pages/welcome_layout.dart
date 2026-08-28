import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fuenfzigohm/ui/welcome/bloc/welcome_bloc.dart';
import 'package:fuenfzigohm/repository/models/course_class.dart';

class WelcomeLayout extends StatelessWidget {
  const WelcomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<WelcomeBloc, WelcomeState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: Durations.short4,
            child: _getScreen(context, state.status),
          );
        },
      ),
    );
  }

  Widget _getScreen(BuildContext context, WelcomeStatus status) {
    if (status == WelcomeStatus.initial) {
      return WelcomeGreeting();
    } else if (status == WelcomeStatus.courseSelection) {
      return WelcomeCourseSelection();
    }
    return Container();
  }
}

class WelcomeGreeting extends StatelessWidget {
  const WelcomeGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SvgPicture.asset(
            "assets/welcome/Icons.svg",
            clipBehavior: Clip.none,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Theme.of(context).canvasColor.withOpacity(0.0),
              Theme.of(context).canvasColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.1],
          )),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Willkommen!",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                SizedBox(height: 8.0),
                Text(
                  "Wir freuen uns dich auf deinem Weg zur Amateurfunkzulassung begleiten zu dürfen.",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16.0),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    BlocProvider.of<WelcomeBloc>(context)
                        .add(WelcomeStartEvent());
                  },
                  child: Text("Start"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WelcomeCourseSelection extends StatelessWidget {
  const WelcomeCourseSelection({super.key});

  Future<void> _goBack(BuildContext context) async {
    final bloc = context.read<WelcomeBloc>();
    if (bloc.settingRepository.courseClass.isEmpty) {
      bloc.add(WelcomeBackEvent());
      return;
    }

    await bloc.settingRepository.setShowWelcomeScreen(true);
    if (!context.mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.09,
                child: SvgPicture.asset(
                  'assets/welcome/Icons.svg',
                  clipBehavior: Clip.none,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 32, bottom: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 72,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Lernen auf 50ohm.de. Üben, wo du willst.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Auf 50ohm.de erarbeitest du dir das Wissen '
                                  'für die Amateurfunkprüfung. Mit dieser App '
                                  'festigst du das Gelernte unterwegs – zum '
                                  'Beispiel in der Bahn oder in der '
                                  'Mittagspause.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _CourseSelectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _CourseSection(
                                  title: 'Gesamtkurse',
                                  description:
                                      'Diese Kurse richten sich an alle, die '
                                      'noch kein Amateurfunkzeugnis haben.',
                                  options: completeCourseOptions,
                                  showSubtitles: true,
                                ),
                                const SizedBox(height: 40),
                                _CourseSection(
                                  title: 'Aufbaukurse',
                                  description: 'Für alle, die schon über ein '
                                      'Amateurfunkzeugnis der Klasse N oder E '
                                      'verfügen, gibt es folgende Aufbaukurse:',
                                  options: upgradeCourseOptions,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: () async => _goBack(context),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Zurück'),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CourseSelectionCard extends StatelessWidget {
  final Widget child;

  const _CourseSelectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

class CourseSelectionOption {
  final String title;
  final String? subtitle;
  final Set<int> course;
  final Color color;

  const CourseSelectionOption({
    required this.title,
    required this.course,
    required this.color,
    this.subtitle,
  });
}

const completeCourseOptions = [
  CourseSelectionOption(
    title: 'N',
    subtitle: 'Neueinsteiger',
    course: CourseClass.COURSE_CLASS_N,
    color: CourseClass.CLASS_N_SURFACE_COLOR,
  ),
  CourseSelectionOption(
    title: 'N + E',
    subtitle: 'Erweitert',
    course: CourseClass.COURSE_CLASS_NE,
    color: CourseClass.CLASS_E_SURFACE_COLOR,
  ),
  CourseSelectionOption(
    title: 'N + E + A',
    subtitle: 'Alles',
    course: CourseClass.COURSE_CLASS_NEA,
    color: CourseClass.CLASS_A_SURFACE_COLOR,
  ),
];

const upgradeCourseOptions = [
  CourseSelectionOption(
    title: 'N → E',
    course: CourseClass.COURSE_CLASS_E,
    color: CourseClass.CLASS_E_SURFACE_COLOR,
  ),
  CourseSelectionOption(
    title: 'N → A',
    course: CourseClass.COURSE_CLASS_EA,
    color: CourseClass.CLASS_A_SURFACE_COLOR,
  ),
  CourseSelectionOption(
    title: 'E → A',
    course: CourseClass.COURSE_CLASS_A,
    color: CourseClass.CLASS_A_SURFACE_COLOR,
  ),
];

class _CourseSection extends StatelessWidget {
  final String title;
  final String description;
  final List<CourseSelectionOption> options;
  final bool showSubtitles;

  const _CourseSection({
    required this.title,
    required this.description,
    required this.options,
    this.showSubtitles = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < options.length; index++) ...[
                if (index > 0) const SizedBox(width: 12),
                Expanded(
                  child: _CourseButton(
                    option: options[index],
                    showSubtitle: showSubtitles,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CourseButton extends StatelessWidget {
  final CourseSelectionOption option;
  final bool showSubtitle;

  const _CourseButton({
    required this.option,
    required this.showSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: option.color,
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: showSubtitle ? 20 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () => BlocProvider.of<WelcomeBloc>(context).add(
        WelcomeCourseSelectEvent(course: option.course),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            option.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          if (showSubtitle && option.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              option.subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
