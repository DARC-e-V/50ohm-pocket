import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fuenfzigohm/ui/welcome/bloc/welcome_bloc.dart';
import 'package:fuenfzigohm/ui/welcome/widgets/class_list_tile.dart';
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
    } else if (status == WelcomeStatus.updateCourseSelection) {
      return WelcomeUpdateCourseSelection();
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Womit möchtest du beginnen?",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<WelcomeBloc>(context)
                  .add(WelcomeCourseUpgradeToggleEvent());
            },
            child: Text(
              "Ich habe schon eine Prüfung abgelegt.",
            ),
          ),
          ClassListTile(
            onTap: () => BlocProvider.of<WelcomeBloc>(context).add(
              WelcomeCourseSelectEvent(
                course: CourseClass.COURSE_CLASS_N,
              ),
            ),
            icon: Icons.signal_cellular_alt_1_bar_rounded,
            surfaceColor: CourseClass.CLASS_N_SURFACE_COLOR,
            classTitle: "Klasse N",
            classDescription:
                "Baue deine eigene Funkstation auf, experimentiere mit neuester Technik und knüpfte Kontakte weltweit. Erlebe grenzenlose Kommunikation und werde Teil einer aktiven Gemeinschaft, die die Zukunft des Amateurfunks gestaltet.",
          ),
          ClassListTile(
            onTap: () => BlocProvider.of<WelcomeBloc>(context).add(
              WelcomeCourseSelectEvent(
                course: CourseClass.COURSE_CLASS_NE,
              ),
            ),
            icon: Icons.signal_cellular_alt_2_bar_rounded,
            surfaceColor: CourseClass.CLASS_E_SURFACE_COLOR,
            classTitle: "Klasse E",
            classDescription:
                "Vertiefe deine Kenntnisse in Technik und Funkbetrieb, nimm an Amateurfunk-Wettbewerben teil und engagiere dich in der Ausbildung von neuen Funkamateuren.",
          ),
          ClassListTile(
            onTap: () => BlocProvider.of<WelcomeBloc>(context).add(
              WelcomeCourseSelectEvent(
                course: CourseClass.COURSE_CLASS_NEA,
              ),
            ),
            icon: Icons.signal_cellular_alt_rounded,
            surfaceColor: CourseClass.CLASS_A_SURFACE_COLOR,
            classTitle: "Klasse A",
            classDescription:
                "Errichte deine eigene Amateurfunkstation mit hoher Sendeleistung, leite Funkkurse und bilde neue Funkamateure aus. Engagiere dich in der Forschung und Entwicklung neuer Funktechnologien und gestalte die Zukunft des Amateurfunks aktiv mit.",
          ),
        ],
      ),
    );
  }
}

class WelcomeUpdateCourseSelection extends StatelessWidget {
  const WelcomeUpdateCourseSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Wie möchtest Du weitermachen?",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<WelcomeBloc>(context)
                  .add(WelcomeCourseUpgradeToggleEvent());
            },
            child: Text(
              "Ich habe noch keine Prüfung abgelegt.",
            ),
          ),
          ClassListTile(
            onTap: () => BlocProvider.of<WelcomeBloc>(context).add(
              WelcomeCourseSelectEvent(
                course: CourseClass.COURSE_CLASS_E,
              ),
            ),
            icon: Icons.signal_cellular_alt_1_bar_rounded,
            surfaceColor: CourseClass.CLASS_N_SURFACE_COLOR,
            classTitle: "Upgrade von N auf E",
            classDescription:
                "Du hast schon deine N Zulassung? Super! Starte heute mit deinen Vorbereitungen auf die Klasse E.",
            type: ClassListTileType.UPGRADE,
          ),
          ClassListTile(
            onTap: () => BlocProvider.of<WelcomeBloc>(context).add(
              WelcomeCourseSelectEvent(
                course: CourseClass.COURSE_CLASS_A,
              ),
            ),
            icon: Icons.signal_cellular_alt_2_bar_rounded,
            surfaceColor: CourseClass.CLASS_E_SURFACE_COLOR,
            classTitle: "Upgrade von E auf A",
            classDescription:
                "Du hast deine E Zulassung? Super! Starte heute mit deinen Vorbereitungen auf die Klasse A.",
            type: ClassListTileType.UPGRADE,
          ),
          ClassListTile(
            onTap: () => BlocProvider.of<WelcomeBloc>(context).add(
              WelcomeCourseSelectEvent(
                course: CourseClass.COURSE_CLASS_EA,
              ),
            ),
            icon: Icons.signal_cellular_alt_rounded,
            surfaceColor: CourseClass.CLASS_A_SURFACE_COLOR,
            classTitle: "Upgrade von N auf A",
            classDescription:
                "Du hast deine N Zulassung? Super! Starte heute mit deinen Vorbereitungen auf die Klasse A.",
            type: ClassListTileType.UPGRADE,
          ),
        ],
      ),
    );
  }
}
