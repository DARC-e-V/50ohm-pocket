import 'package:flutter/material.dart';
import 'constants.dart';
import 'futurebuilder.dart';
import 'navbar.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Afutrainer',
      home: FlutterDemo(),
    ),
  );
}
class FlutterDemo extends StatefulWidget {

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Afutrainer')),
      body: Container(
        padding: EdgeInsets.only(left: std_padding,right: std_padding),
        child: futurebuilder()
      ),
      bottomNavigationBar: bottomnavbar()
    );
  }
}





