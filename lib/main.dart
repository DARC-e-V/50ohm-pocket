import 'package:fuenfzigohm/custom_libs/database.dart';
import 'package:fuenfzigohm/helpers/app_bloc_observer.dart';
import 'package:fuenfzigohm/repository/service/setting_service.dart';
import 'package:fuenfzigohm/repository/setting_repository.dart';
import 'package:fuenfzigohm/screens/aboutApp.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/helpers/packagesListing.dart';
import 'package:fuenfzigohm/helpers/questionsLicenseNotice.dart';
import 'package:fuenfzigohm/learning_state/learning_state_repository.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:fuenfzigohm/ui/welcome/pages/welcome.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  runApp(
    FutureBuilder(
      future: Database().load(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data as List;
          final progressDatabase = data[0] as Box;
          final settingsDatabase = data[1] as Box;
          final learningStateRepository = data[2] as LearningStateRepository;
          final bookmarksDatabase = data[3] as Box;
          final initialFontScale =
              (settingsDatabase.get("fontScale") as num?)?.toDouble() ?? 1.0;

          return PocketApp(
            progDatabase: progressDatabase,
            settingsDatabase: settingsDatabase,
            learningStateRepository: learningStateRepository,
            initialFontScale: initialFontScale,
            bookmarksDatabase: bookmarksDatabase,
          );
        }
        if (snapshot.hasError) {
          debugPrint('App startup failed: ${snapshot.error}');
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text("Die App konnte nicht gestartet werden."),
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    ),
  );
}

class PocketApp extends StatefulWidget {
  final Box progDatabase;
  final Box settingsDatabase;
  final double initialFontScale;
  final LearningStateRepository learningStateRepository;
  final Box bookmarksDatabase;

  const PocketApp({
    super.key,
    required this.progDatabase,
    required this.settingsDatabase,
    required this.initialFontScale,
    required this.learningStateRepository,
    required this.bookmarksDatabase,
  });

  @override
  State<PocketApp> createState() => _PocketAppState();
}

class _PocketAppState extends State<PocketApp> {
  late final ValueNotifier<double> _fontScaleNotifier;
  late final ValueNotifier<ThemeMode> _themeModeNotifier;

  @override
  void initState() {
    super.initState();
    _fontScaleNotifier = ValueNotifier<double>(widget.initialFontScale);
    final savedThemeMode = widget.settingsDatabase.get("themeMode") as String? ?? "system";
    _themeModeNotifier = ValueNotifier<ThemeMode>(_stringToThemeMode(savedThemeMode));
  }

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "light";
      case ThemeMode.dark:
        return "dark";
      case ThemeMode.system:
        return "system";
    }
  }

  @override
  void dispose() {
    _fontScaleNotifier.dispose();
    _themeModeNotifier.dispose();
    super.dispose();
  }

  void _updateFontScale(double scale) {
    if (_fontScaleNotifier.value == scale) {
      return;
    }

    _fontScaleNotifier.value = scale;
    widget.settingsDatabase.put("fontScale", scale);
  }

  void _updateThemeMode(ThemeMode mode) {
    if (_themeModeNotifier.value == mode) {
      return;
    }

    _themeModeNotifier.value = mode;
    widget.settingsDatabase.put("themeMode", _themeModeToString(mode));
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      fontScaleNotifier: _fontScaleNotifier,
      onFontScaleChanged: _updateFontScale,
      themeModeNotifier: _themeModeNotifier,
      onThemeModeChanged: _updateThemeMode,
      child: DatabaseWidget(
        prog_database: widget.progDatabase,
        settings_database: widget.settingsDatabase,
        learningStateRepository: widget.learningStateRepository,
        bookmarks_database: widget.bookmarksDatabase,
        child: RepositoryProvider(
          create: (_) => SettingRepository(
            service: SettingService(
              settings_database: widget.settingsDatabase,
            ),
          ),
          child: ValueListenableBuilder<double>(
            valueListenable: _fontScaleNotifier,
            builder: (context, fontScale, _) {
              return ValueListenableBuilder<ThemeMode>(
                valueListenable: _themeModeNotifier,
                builder: (context, themeMode, _) {
                  return MaterialApp(
                    theme: lightmode(),
                    darkTheme: darkmode(),
                    themeMode: themeMode,
                    title: '50ohm-pocket',
                    locale: const Locale('de', 'DE'),
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('de', 'DE'),
                    ],
                    home: Welcome(),
                    routes: {
                      '/learn': (context) => Learningmodule(),
                      '/welcome': (context) => Welcome(),
                      '/appPackages': (context) => OssLicensesPage(),
                      '/questionsLicenseNotice': (context) =>
                          QuestionsLicensePage(),
                      '/aboutApp': (context) => AboutAppPage(),
                    },
                    builder: (context, child) {
                      final mediaQuery = MediaQuery.of(context);
                      return MediaQuery(
                        data: mediaQuery.copyWith(
                          textScaler: TextScaler.linear(fontScale),
                        ),
                        child: child ?? const SizedBox.shrink(),
                      );
                    },
                    debugShowCheckedModeBanner: false,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class AppSettingsScope extends InheritedWidget {
  final ValueNotifier<double> fontScaleNotifier;
  final void Function(double scale) onFontScaleChanged;
  final ValueNotifier<ThemeMode> themeModeNotifier;
  final void Function(ThemeMode mode) onThemeModeChanged;

  const AppSettingsScope({
    super.key,
    required this.fontScaleNotifier,
    required this.onFontScaleChanged,
    required this.themeModeNotifier,
    required this.onThemeModeChanged,
    required super.child,
  });

  static AppSettingsScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettingsScope>()!;

  double get fontScale => fontScaleNotifier.value;
  ThemeMode get themeMode => themeModeNotifier.value;

  @override
  bool updateShouldNotify(AppSettingsScope oldWidget) {
    return fontScaleNotifier != oldWidget.fontScaleNotifier ||
        themeModeNotifier != oldWidget.themeModeNotifier;
  }
}
