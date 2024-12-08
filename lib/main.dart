import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:fuenfzigohm/coustom_libs/questionState.dart';
import 'package:fuenfzigohm/screens/aboutApp.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/screens/error.dart';
import 'package:fuenfzigohm/screens/intro.dart';
import 'package:fuenfzigohm/helpers/packagesListing.dart';
import 'package:fuenfzigohm/helpers/questionsLicenseNotice.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionManager()),
      ],
      child: FiftyOhm(),
    ),
  );
}

class FiftyOhm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
          future: Database().load(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              Box prog_database = (snapshot.data as List)[0];
              Box settings_database = (snapshot.data as List)[1];
              Box prog_database2 = (snapshot.data as List)[2];

              DatabaseFunctions.checkMigrate(prog_database, prog_database2);
              return DatabaseWidget(
                prog_database: prog_database,
                settings_database: settings_database,
                prog_database2: prog_database2,
                child: MaterialApp(
                  theme: lightmode(),
                  darkTheme: darkmode(),
                  themeMode: ThemeMode.system,
                  title: '50ohm-pocket',
                  home: Welcome(),
                  routes:{
                    '/learn': (context) => Learningmodule(),
                    '/welcome': (context) => Welcome(),
                    '/appPackages': (context) => OssLicensesPage(),
                    '/questionsLicenseNotice': (context) => QuestionsLicensePage(),
                    '/aboutApp' : (context) => AboutAppPage(),
                  },
                  debugShowCheckedModeBanner: false,
                ),
              );
            }
            if(snapshot.error != null) return Directionality(
              textDirection: TextDirection.ltr,
              child: ErrorPage(snapshot.error.toString(), snapshot.stackTrace.toString()),
            );
            return Center(child: CircularProgressIndicator());
          }
    );
    }

}

