import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:fuenfzigohm/helpers/app_bloc_observer.dart';
import 'package:fuenfzigohm/repository/service/setting_service.dart';
import 'package:fuenfzigohm/repository/setting_repository.dart';
import 'package:fuenfzigohm/screens/aboutApp.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/helpers/packagesListing.dart';
import 'package:fuenfzigohm/helpers/questionsLicenseNotice.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:fuenfzigohm/ui/welcome/pages/welcome.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  runApp(
    FutureBuilder(
      future: Database().load(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return DatabaseWidget(
            prog_database: (snapshot.data as List)[0],
            settings_database: (snapshot.data as List)[1],
            child: MultiRepositoryProvider(
              providers: [
                RepositoryProvider(
                  create: (context) => SettingRepository(
                    service: SettingService(
                      // TODO: Rework database loading and integrate into provider/bloc
                      settings_database: (snapshot.data as List)[1],
                    ),
                  ),
                ),
              ],
              child: MaterialApp(
                theme: lightmode(),
                darkTheme: darkmode(),
                themeMode: ThemeMode.system,
                title: '50ohm-pocket',
                home: Welcome(),
                routes: {
                  '/learn': (context) => Learningmodule(),
                  '/welcome': (context) => Welcome(),
                  '/appPackages': (context) => OssLicensesPage(),
                  '/questionsLicenseNotice': (context) =>
                      QuestionsLicensePage(),
                  '/aboutApp': (context) => AboutAppPage(),
                },
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        if (snapshot.hasError) return Text("Error");
        return Center(child: CircularProgressIndicator());
      },
    ),
  );
}
