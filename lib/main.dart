import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:fuenfzigohm/screens/aboutApp.dart';
import 'package:fuenfzigohm/screens/chapterSelection.dart';
import 'package:fuenfzigohm/screens/intro.dart';
import 'package:fuenfzigohm/screens/examSelection.dart';
import 'package:fuenfzigohm/helpers/packagesListing.dart';
import 'package:fuenfzigohm/helpers/questionsLicenseNotice.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    FutureBuilder(
        future: Database().load(),
        builder: (context, snapshot){
          if(snapshot.hasData)
            return DatabaseWidget(
              prog_database: (snapshot.data as List )[0],
              settings_database: (snapshot.data as List )[1],
              child: MaterialApp(
                theme: lightmode(),
                darkTheme: darkmode(),
                themeMode: ThemeMode.system,
                title: '50ohm-pocket',
                home: Welcome(),
                routes:{
                  '/learn': (context) => Learningmodule(),
                  '/welcome': (context) => Welcome(),
                  '/exam': (context) => const ExamSelectionScreen(),
                  '/appPackages': (context) => OssLicensesPage(),
                  '/questionsLicenseNotice': (context) => QuestionsLicensePage(),
                  '/aboutApp' : (context) => AboutAppPage(),
                },
                debugShowCheckedModeBanner: false,
              ),
            );
          if(snapshot.hasError) return Text("Error");
          return Center(child: CircularProgressIndicator());
        }
    )
  );
}

