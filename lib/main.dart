import 'package:flutter/material.dart';
import 'constants.dart';
import 'futurebuilder.dart';
import 'navbar.dart';

void main() {
  runApp(
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
        cardColor: main_col,
      ),
      themeMode: ThemeMode.system,
      title: 'Afutrainer',
      home: Afutrainer(),
    ),
  );
}

class Afutrainer extends StatefulWidget {

  @override
  createState() => _AfutrainerState();
}

class _AfutrainerState extends State<Afutrainer> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Afutrainer')),//Color(0xff253478),),
      body: Container(
        child: futurebuilder(context)
      ),
      bottomNavigationBar: bottomnavbar()
    );
  }
}





