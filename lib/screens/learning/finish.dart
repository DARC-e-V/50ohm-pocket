import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:amateurfunktrainer/coustom_libs/json.dart';
import 'package:amateurfunktrainer/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Finish extends StatefulWidget{
  var subchapter, chapter, result, context;
  Finish( this.chapter, this.subchapter, this.result, this.context);

  @override
  State<StatefulWidget> createState() =>
     _finishstate(subchapter, chapter, result, context);

}

class _finishstate extends State<Finish>{
  var subchapter, chapter, result, context;

  _finishstate( this.subchapter, this.chapter, this.result, this.context);
  
  @override
  Widget build(BuildContext buildcontext) {
    Databaseobj(context).write(JsonWidget.of(context).mainchapter, chapter, subchapter, result);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text("Du hast die Lektion geschafft", style: TextStyle(fontSize: 30),),
          ),
          Padding(
            padding: EdgeInsets.only(left: 8, right: 8, bottom: 10),
            child: ElevatedButton(
              style: buttonstyle(Colors.lightGreenAccent),
              child: Text("Abschließen"),
              onPressed: (){Navigator.of(context).pop();},
              ),
          )
        ],
        )
    );
  }

}