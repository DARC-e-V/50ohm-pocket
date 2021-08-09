import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:amateurfunktrainer/coustom_libs/json.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Finish extends StatefulWidget{
  var subchapter, chapter, result;
  Finish( this.chapter, this.subchapter, this.result);

  @override
  State<StatefulWidget> createState() =>
     _finishstate(subchapter, chapter, result);

}

class _finishstate extends State<Finish>{
  var subchapter, chapter, result;

  _finishstate( this.subchapter, this.chapter, this.result);
  
  @override
  Widget build(BuildContext context) {
    int mainchapter = 0;//JsonWidget.of(context).mainchapter;
    print("$mainchapter");
    Databaseobj(context, mainchapter, chapter, subchapter, result).write();
    return Scaffold(
      body: Column(
        children: [
          Text("Du hast die Lektion geschafft"),
          TextButton(child: Text("Okay"), onPressed: (){Navigator.of(context).pop();},)
        ],
        )
    );
  }

}