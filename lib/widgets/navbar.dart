import 'package:amateurfunktrainer/lerningprog/learningprog.dart';
import 'package:amateurfunktrainer/screens/learningmodule.dart';
import 'package:flutter/material.dart';

class Bottomnavbar extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar>{
  var currentindex = 0 ;
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: currentindex,
    onTap: (currentindex){
      switch(currentindex){
        case 0:
          print("0");
          Learningmodule();
          break;
        case 1:
          print("1");
          Lerningprog();
          break;
        case 2:
          print("2");
          break;

      }
    },
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: "Lernen"),
      BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: "Prüfungssimulation"),
      BottomNavigationBarItem(icon: Icon(Icons.switch_account_outlined), label: "Lernstand"),
    ],
  );
}