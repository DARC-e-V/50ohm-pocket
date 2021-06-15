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
  var questionradio, _json;
  var tries = 0;
  final context, question, subchapter, chapter;
  bool correct = false;


  _Questionstate(this.context,this.subchapter,this.chapter,this.question);

  @override
  initState() {
    super.initState();
    setState(() {
      _json = Json(JsonWidget.of(context).json);
    });
  }
  @override
  Widget build(BuildContext context) {

    var questionchecked;
    if(questionradio != null){
      questionchecked = true;
    }else{
      questionchecked = false;
    }
    var questionlist = _json.question(chapter,subchapter,question)[0];

  return Scaffold(
    appBar: AppBar(
      title: Text("Afutrainer"),
    ),
    body: ListView(
      children: [
        //LinearProgressIndicator(value: menuq.questionprocent(chapter,subchapter, questionnum),),
        Padding(
          padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding),
          child: HtmlWidget("${_json.questionname(chapter,subchapter,question)}",
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
            itemCount: 2,//qdata["textanswer"].length,
            itemBuilder: (context, i){
              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Text("$correct"),
                    //TextButton(onPressed: () => setState(() {), child: child),
                    RadioListTile(
                      groupValue: questionradio,
                      value: i,
                      onChanged: (var value) {setState(() {questionradio = i;});},
                      title: HtmlWidget(""),//questionlist[i][1],),
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
          onPressed: (){},//questionchecked ? () =>  _checkquestion() : null,
          child: Text("Überprüfen"),//_textdisplay(),
        ),
      ],
    ),
  );
      }/*
  _questiondiable(){
    print("$question");
    if(question != null){
          return _checkquestion();
        }else{
          print("deactivated");
          return null;
        }
  }

  displaysnackbar(var text){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$text'),));

  }

  _checkquestion() {
    //print(questionlist[this.question][0]);
    bool b = questionlist[this.question][0].toLowerCase() == "true";
    print("$b");
    if(correct || tries > 1){
      /*if(question > menuq.questioncount(chapter,subchapter, questionnum)){
        print("ALARM");
      }else{*/
        setState(() {correct = false; tries = 0;question = null;questionnum += 1;});
        menuq = Chaptermenu(data);
        qdata = menuq.question(chapter,subchapter,questionnum);
        questionlist = _questionlist(qdata);
      //}
    } else if(b && tries < 2){
      print("richtig");
      displaysnackbar("Richtig");
      setState(() {correct = true; });
    }else if(tries > 0){
      displaysnackbar("Zu oft Falsch");
      setState(() {
        question = 1;
        tries += 1;
      });
    }else if(!b){
      print("falsch");
      displaysnackbar("Falsch");
      setState(() { tries += 1;question = null;});
    }
  }
    _textdisplay() {
      //print("\n");
      //print(correct);
      //print(tries);
      if(correct || tries > 1){
        return Text("Weiter");//return Question(subchapter,chapter,data,questionnum + 1);
      }
      else{
        return Text("Überprüfen");
      }
    }

     _questionlist(var qdata) {
      //print(qdata["textanswer"]);//[0]["@correct"]);
      var questionlist = [];
      var x = 0;
      for(var y in qdata["textanswer"]){
        x += 1;
        if(x == 1){
          questionlist.add(["true", y["text"].toString()]);
        }else{
          questionlist.add(["false", y]);
       }
      }
      questionlist.shuffle();
      return questionlist;
  }
*/
}

