
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../constants.dart';
import '../json.dart';

void pushquestion(final title, BuildContext context, var data, var chapter, var subchapter) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (BuildContext context){
      return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Question(subchapter,chapter,data,0));
      }
    ),
  );
}

class Question extends StatefulWidget {
  var subchapter, chapter, data, questionnum;
  Question(this.subchapter,this.chapter,this.data,this.questionnum);

  @override
  createState() => _Questionstate(subchapter,chapter,data,questionnum);
}

class _Questionstate extends State<Question>{
  //, var data, var chapter, var subchapter
  var questionnum = 0;
  var question ;
  var subchapter, chapter, data;
  var menuq, qdata, questionlist;
  var tries = 0 ;
  bool correct = false;

  _Questionstate(this.subchapter,this.chapter,this.data,this.questionnum);

  @override
  initState() {
    super.initState();
    menuq = Chaptermenu(data);
    qdata = menuq.question(chapter,subchapter,questionnum);
    questionlist = _questionlist(qdata);
    print(questionlist);
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: [
          Padding(padding: EdgeInsets.only(top: std_padding, left: std_padding, right: std_padding), child: HtmlWidget(qdata["textquestion"],textStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20
          ),),),
          Divider(height: std_padding * 2,),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              addAutomaticKeepAlives: true,
              shrinkWrap: true,
              itemCount: qdata["textanswer"].length,
              itemBuilder: (context, i){
                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //Text("$correct"),
                      //TextButton(onPressed: () => setState(() {), child: child),
                      ListTile(

                      //title: HtmlWidget(i == 0 ? qdata["textanswer"][i]["text"] : qdata["textanswer"][i]),
                      title: HtmlWidget(questionlist[i][1]),
                      leading : Radio(
                        groupValue: question,
                        value: i,
                        onChanged: (var value) {
                          setState(() {
                            question = i;
                          });
                      },
                      ),
                    )]);
              }),
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
            onPressed: () => _checkquestion(),
            child: _textdisplay(),
          )
        ],
      );
    }

displaysnackbar(var text){
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$text'),));

}

  _checkquestion() {
    print(questionlist[this.question][0]);
    bool b = questionlist[this.question][0].toLowerCase() == "true";
    print("$b");
    if(tries > 1){
      displaysnackbar("Zu oft Falsch");
    }
    if(correct || tries > 2){
      questionnum += 1;
      menuq = Chaptermenu(data);
      qdata = menuq.question(chapter,subchapter,questionnum);
      questionlist = _questionlist(qdata);
      setState(() {correct = false; tries = 0;question = null;});
      //initState();
    }

    else if(b && tries < 1){
      displaysnackbar("Richtig");
      setState(() {correct = true; });
    }else{
      displaysnackbar("Falsch");
      setState(() {correct = false; tries += 1;});
    }
  }
  _textdisplay() {
    print("\n");
    print(correct);
    print(tries);
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



}