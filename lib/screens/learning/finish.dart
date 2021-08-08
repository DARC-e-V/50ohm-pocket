import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Finish extends StatefulWidget{
  var mainchapter, subchapter, chapter, result;
  Finish(this.mainchapter, this.chapter, this.subchapter, this.result);

  @override
  State<StatefulWidget> createState() =>
     _finishstate(mainchapter, subchapter, chapter, result);

}

class _finishstate extends State<Finish>{
  var mainchapter, subchapter, chapter, result;

  _finishstate(this.mainchapter, this.subchapter, this.chapter, this.result);
  
  @override
  Widget build(BuildContext context) {
    
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