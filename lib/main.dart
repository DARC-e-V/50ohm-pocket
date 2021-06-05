import 'package:flutter/material.dart';
import 'constants.dart';
import 'futurebuilder.dart';
import 'navbar.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Afutrainer',
      home: Afutrainer(),
    ),
  );
}
class Afutrainer extends StatefulWidget {

  @override
  _AfutrainerState createState() => _AfutrainerState();
}

class _AfutrainerState extends State<Afutrainer> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Afutrainer'), backgroundColor: main_col),//Color(0xff253478),),
      body: Container(
        child: futurebuilder()
      ),
      bottomNavigationBar: bottomnavbar()
    );
  }
}





