import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settingspage extends StatefulWidget{
  @override
  _settingsstate createState() => _settingsstate();
}

class _settingsstate extends State<Settingspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: ListView(
        children: [
          Text("hello World"),
        ],
        
      ),
    );
  }

}
