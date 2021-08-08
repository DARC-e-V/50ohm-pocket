
import 'package:amateurfunktrainer/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Learnprog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _learnprog();
}

class _learnprog extends State<Learnprog>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lernstand"),
      ),
      bottomNavigationBar: Bottomnavbar(),
      body: Row(
        children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                "Klasse E",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider()
        ],
      ),
    );
  }
  
}