import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class Finish extends StatefulWidget{
  var mainchapter, subchapter, chapter, question;
  Finish(this.mainchapter, this.subchapter, this.chapter, this.question);

  @override
  State<StatefulWidget> createState() =>
     _finishstate(mainchapter, subchapter, chapter, question);

}

class _finishstate extends State<Finish>{
  var mainchapter, subchapter, chapter, question;

  _finishstate(this.mainchapter, this.subchapter, this.chapter, this.question);
  
  @override
  Widget build(BuildContext context) {
    Databaseobj(context, 0, 0, 0, 0).write();
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