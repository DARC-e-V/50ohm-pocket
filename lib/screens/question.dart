import 'dart:math';

import 'package:amateurfunktrainer/coustom_libs/shake.dart';
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
class _Questionstate extends State<Question> with SingleTickerProviderStateMixin{

  var _json, answerorder, chapterorder, _shakeController, wrong;
  var questionkey, subchapterkey = 0;
  final context, chapter;
  List subchapter, question;
  var questionradio = null;
  bool correct = false;


  _Questionstate(this.context,this.subchapter,this.chapter,this.question);
  @override
  initState() {
    _shakeController = (ShakeController(vsync: this) as ShakeController);
    questionkey = 0;
    subchapterkey = 0;
    print("subchapterlistlenghth " + "${subchapter.length}" + "${subchapter}");
    setState(() {
      // To do: dynamic not 4 lol
      chapterorder = subchapter.length == 1 ? subchapter : orderlist(subchapter.length ,true);
      answerorder = orderlist(4,true);
      _json = Json(JsonWidget.of(context).json);
    });
    print("chapterorder" + "$chapterorder");
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    //!!change to false for non random answers
    return Scaffold(
      appBar: AppBar(
        title: Text("Afutrainer"),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              LinearProgressIndicator(value: _json.procentofchapter(answerorder, questionkey),),
              Padding(
                padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding),
                child: HtmlWidget("${_json.questionname(chapter,chapterorder[subchapterkey],question[questionkey])}",
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
                            title: HtmlWidget("${_json.answer(chapter,chapterorder[subchapterkey],question[questionkey],answerorder[i])[0]}"),
                          ),
                        ]
                    );
                  }
              ),
              SizedBox(height: 60),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ShakeView(
              controller: _shakeController,
              child: ElevatedButton(
                autofocus: false,
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 23,
                  ),
                  fixedSize: Size(MediaQuery.of(context).size.width, 60),
                  //visualDensity: VisualDensity(vertical: 3,horizontal: 4,),
                  shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
                ),
                onPressed: questionradio == null ? null :  () =>  _questionhandler(),
                child: Text("Überprüfen"),
              ),
            ),
          )
        ],
      )
    );
  }

  _questionhandler( ){
    var correct = (_json.answer(this.chapter,this.subchapter[this.subchapterkey],this.question[this.questionkey],this.answerorder[this.questionradio]))[1];
    if(correct){
      try{
        question[questionkey + 1];
        setState(() {
          //questionradio = null;
          this.questionkey += 1;
          // To do: dynamic not 4 lol
          answerorder = orderlist(4,true);
        });
        ///Code that's executed when answer is correct
        questionradio = null;
        wrong = false;
      }catch(e){
        try{
          this.subchapterkey += 1;
        }catch(e){
          Navigator.of(context).pop();
        }
        Navigator.of(context).pop();
      }
    }else{
      if(!wrong){
        _shakeController.shake();
        wrong = true;
      }else{

      }

    }
  }
}

orderlist(var elements, bool random){
  int i = 0; List<int> orderlist = List.generate((elements),(generator) {i++; return i - 1;});

  if(!random) return orderlist;
  else orderlist.shuffle(); return orderlist;
}
