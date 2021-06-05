import 'package:flutter/material.dart';

bottomnavbar() => BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), title: Text("Lernen")),
    BottomNavigationBarItem(icon: Icon(Icons.school_outlined), title: Text("Prüfungssimulation")),
    BottomNavigationBarItem(icon: Icon(Icons.switch_account_outlined), title: Text("Lernstand")),
  ],
);