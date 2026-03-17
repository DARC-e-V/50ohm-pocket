import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:fuenfzigohm/screens/aboutApp.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/screens/intro.dart';
import 'package:fuenfzigohm/helpers/packagesListing.dart';
import 'package:fuenfzigohm/helpers/questionsLicenseNotice.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  runApp(
    FutureBuilder(
      future: Database().load(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data as List;
          final progressDatabase = data[0] as Box;
          final settingsDatabase = data[1] as Box;
          final initialFontScale =
              (settingsDatabase.get("fontScale") as num?)?.toDouble() ?? 1.0;

          return PocketApp(
            progDatabase: progressDatabase,
            settingsDatabase: settingsDatabase,
            initialFontScale: initialFontScale,
          );
        }
        if (snapshot.hasError) return Text("Error");
        return Center(child: CircularProgressIndicator());
      },
    ),
  );
}

class PocketApp extends StatefulWidget {
  final Box progDatabase;
  final Box settingsDatabase;
  final double initialFontScale;

  const PocketApp({
    super.key,
    required this.progDatabase,
    required this.settingsDatabase,
    required this.initialFontScale,
  });

  @override
  State<PocketApp> createState() => _PocketAppState();
}

class _PocketAppState extends State<PocketApp> {
  late final ValueNotifier<double> _fontScaleNotifier;

  @override
  void initState() {
    super.initState();
    _fontScaleNotifier = ValueNotifier<double>(widget.initialFontScale);
  }

  @override
  void dispose() {
    _fontScaleNotifier.dispose();
    super.dispose();
  }

  void _updateFontScale(double scale) {
    if (_fontScaleNotifier.value == scale) {
      return;
    }

    _fontScaleNotifier.value = scale;
    widget.settingsDatabase.put("fontScale", scale);
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      fontScaleNotifier: _fontScaleNotifier,
      onFontScaleChanged: _updateFontScale,
      child: DatabaseWidget(
        prog_database: widget.progDatabase,
        settings_database: widget.settingsDatabase,
        child: ValueListenableBuilder<double>(
          valueListenable: _fontScaleNotifier,
          builder: (context, fontScale, _) {
            return MaterialApp(
              theme: lightmode(),
              darkTheme: darkmode(),
              themeMode: ThemeMode.system,
              title: '50ohm-pocket',
              home: Welcome(),
              routes: {
                '/learn': (context) => Learningmodule(),
                '/welcome': (context) => Welcome(),
                '/appPackages': (context) => OssLicensesPage(),
                '/questionsLicenseNotice': (context) => QuestionsLicensePage(),
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
        ),
      ),
    );
  }
}

class AppSettingsScope extends InheritedNotifier<ValueNotifier<double>> {
  final void Function(double scale) onFontScaleChanged;

  const AppSettingsScope({
    super.key,
    required ValueNotifier<double> fontScaleNotifier,
    required this.onFontScaleChanged,
    required super.child,
  }) : super(notifier: fontScaleNotifier);

  static AppSettingsScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettingsScope>()!;

  double get fontScale => notifier?.value ?? 1.0;
}
