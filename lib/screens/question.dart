import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../constants.dart';
import '../coustom_libs/json.dart';

// please let me know weather there is a bloat free variant of this

class Question extends StatefulWidget {
  var subchapter, chapter, questionnum;
  final BuildContext context;
  Question(this.context, this.subchapter,this.chapter,this.questionnum);
  @override
  createState() => _Questionstate(this.context, this.subchapter,this.chapter,this.questionnum);
}
class _Questionstate extends State<Question>{
  var questionradio, _json,  question, answerorder;
  var currquestion, tries = 0;
  final context, subchapter, chapter;

  bool correct = false;


  _Questionstate(this.context,this.subchapter,this.chapter,this.question);

  @override
  initState() {
    super.initState();
    print("hi");
    currquestion = 0;
    setState(() {
      answerorder = _answerorder(4,true);
      _json = Json(JsonWidget.of(context).json);
    });
  }
  @override
  Widget build(BuildContext context) {
    print("$answerorder");
    //print("${question[currquestion]}");
    //!!change to false for non random answers
    return Scaffold(
      appBar: AppBar(
        title: Text("Afutrainer"),
      ),
      body: ListView(
        children: [
          LinearProgressIndicator(value: _json.procentofchapter(answerorder, currquestion),),
          Padding(
            padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding),
            child: HtmlWidget("${_json.questionname(chapter,subchapter,question[currquestion])}",
              textStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20
              ),
            ),
          ),
          Divider(height: std_padding * 2,),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              addAutomaticKeepAlives: true,
              shrinkWrap: true,
              itemCount: answerorder.length,
              itemBuilder: (context, i){
                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RadioListTile(
                        groupValue: questionradio,
                        value: i,
                        onChanged: (var value) {setState(() {questionradio = i;});},
                        title: HtmlWidget("${_json.answer(chapter,subchapter,question[currquestion],answerorder[i])[0]}"),
                      ),
                    ]
                );
              }
          ),
          SizedBox(height: std_padding * 1.5,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 23,
              ),
              visualDensity: VisualDensity(vertical: 3,horizontal: 0,),
              shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            ),
            onPressed: () => _questionhandler(),
            child: Text("Überprüfen"),
          ),
        ],
    ),
  );

  }

  _answerorder(var elements, bool random){
    int i = 0; List<int> orderlist = List.generate((elements),(generator) {i++; return i - 1;});

    if(!random) return orderlist;
    else orderlist.shuffle(); return orderlist;
  }

  _questionhandler( ){
    var correct = (_json.answer(this.chapter,this.subchapter,this.question[this.currquestion],this.answerorder[this.questionradio]))[1];
    if(correct){
      try{
        question[currquestion + 1];
        setState(() {
          this.currquestion += 1;
          answerorder = _answerorder(4,true);
        });
      }catch(e){
        Navigator.of(context).pop();
      }
    }
  }
}

