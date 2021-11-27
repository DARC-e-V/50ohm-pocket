import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:amateurfunktrainer/screens/learning/learningmodule.dart';
import 'package:amateurfunktrainer/style/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'learnprog/learnprog.dart';


void main() {
  runApp(
    FutureBuilder(
        future: Database().load(),
        builder: (context, snapshot){
          if(snapshot.hasData)
            return DatabaseWidget(
              MaterialApp(
                //todo no touch scroll on desktop
                scrollBehavior: ScrollBehavior(),
                theme: lightmode(),
                darkTheme: darkmode(),
                themeMode: ThemeMode.system,
                title: 'Afutrainer',
                initialRoute: "/",
                routes: {
                  "/" : (context) => Learningmodule(),
                  "/examsim" : (context) => Learnprog(),
                  "/profile" : (context) => Learnprog(),
                },
              ),
              snapshot.data
            );
          if(snapshot.hasError) return Text("Error");
          return Center(child: CircularProgressIndicator());
        }
    )
  );
}

