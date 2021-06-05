
import 'dart:math';

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
          body: _questionwidget(data, chapter, subchapter));
      }
    ),
  );
}

_questionwidget(var data, var chapter, var subchapter) {
  var menuq = Chaptermenu(data);
  var qdata = menuq.question(chapter,subchapter);
  var questionlist = _questionlist(qdata);
  print(questionlist);
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
                children: [ListTile(

                  //title: HtmlWidget(i == 0 ? qdata["textanswer"][i]["text"] : qdata["textanswer"][i]),
                  title: HtmlWidget(questionlist[i][1]),
                  leading : Radio(
                    value: "GDEZ", onChanged: (String? value) {  }, groupValue: '',
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

        onPressed: () {}, child: Text("Überprüfen"),
      )
    ],
  );

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