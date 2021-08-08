import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:amateurfunktrainer/screens/learningmodule.dart';
import 'package:amateurfunktrainer/widgets/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'learnprog/learnprog.dart';


void main() {
  runApp(
    FutureBuilder(
        future: Database().load(),
        builder: (context, snapshot){
          if(snapshot.hasData)
            return DatabaseWidget(
              MaterialApp(
                theme: ThemeData(
                    primaryColorLight: Color(0xFFE1E6FF),
                    brightness: Brightness.light,
                    primarySwatch: Colors.indigo,
                    textTheme: TextTheme(
                        headline5: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,)
                    )
                ),
                darkTheme: ThemeData(
                  primaryColorDark: Color(0xFF1C1F44),
                  brightness: Brightness.dark,
                  primarySwatch: Colors.indigo,
                  cardColor: main_col,
                ),
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

