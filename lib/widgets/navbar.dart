import 'dart:html';

import 'package:flutter/material.dart';

class Bottomnavbar extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _BottomnavbarState();

}
class _BottomnavbarState extends State<Bottomnavbar>{

  @override
  int _currindex = 0;
  _onpress(int index){
    setState(() {
      _currindex = index;
    });
  }
  Widget build(BuildContext context) => BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: "Lernen"),
      BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: "Prüfungssimulation"),
      BottomNavigationBarItem(icon: Icon(Icons.switch_account_outlined), label: "Lernstand"),
    ],
    currentIndex: _currindex,
    onTap: _onpress(_currindex),
  );
}