import 'package:amateurfunktrainer/learnprog/learnprog.dart';
import 'package:amateurfunktrainer/screens/learningmodule.dart';
import 'package:flutter/material.dart';

class Bottomnavbar extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _BottomnavbarState();
}

class _BottomnavbarState extends State<Bottomnavbar>{
  var currentindex = 0;
  

  @override
  Widget build(BuildContext context){
    print("$currentindex");
  return BottomNavigationBar(
    currentIndex: currentindex,

    onTap: (index){
      setState(() {
        currentindex = index;
      });

      switch(index){
        case 0:
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/');
          Learningmodule();
          break;
        case 1:
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/examsim');
          break;
        case 2:
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/profile');
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
}