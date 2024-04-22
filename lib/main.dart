import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:fuenfzigohm/helpers/question_controller.dart';
import 'package:fuenfzigohm/screens/legal/aboutApp.dart';
import 'package:fuenfzigohm/screens/practise/chapterSelection.dart';
import 'package:fuenfzigohm/screens/intro/intro.dart';
import 'package:fuenfzigohm/helpers/packagesListing.dart';
import 'package:fuenfzigohm/helpers/questionsLicenseNotice.dart';
import 'package:fuenfzigohm/style/style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    FutureBuilder(
        future: Database().load(),
        builder: (context, snapshot){
          if(snapshot.hasData)
            return DatabaseWidget(
              prog_database: (snapshot.data as List )[0],
              settings_database: (snapshot.data as List )[1],
              child: MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (var context) {
                  return QuestionController();
                }) 
                ],
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
              ),
            );
          if(snapshot.hasError) return Text("Error");
          return Center(child: CircularProgressIndicator());
        }
    )
  );
}

