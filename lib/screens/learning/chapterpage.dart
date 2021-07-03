
import 'package:amateurfunktrainer/screens/learning/question.dart';
import 'package:amateurfunktrainer/screens/learning/singlechapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../coustom_libs/json.dart';

Widget selectlesson(var data, var context) {
  var menu = Chaptermenu(data);
  menu.learn_module_name();
  menu.chapter_names();
  menu.subchapter_info();
  menu.main_chapter_names();
  return Padding(
      padding: EdgeInsets.only(left: 5,right: 5),
      child: ListView.builder(
            itemCount: menu.results["chapternames"].length ,
            itemBuilder: (context, i) {
              if(i < 1){
                return Padding(
                    padding: EdgeInsets.only(top:20, right: std_padding, left: std_padding),
                    child:
                    Column(children: [
                      Text(
                        "${Json(JsonWidget.of(context).json).main_chapter_name()}",//menu.results["learnmodulename"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          ),
                        ),
                      Divider()
                    ],)
                );
              }
                return chapterwidget(menu, i, context);
            }
    )
  );

}


Widget chapterwidget(var menu, var s, var context){
  Json json = Json(JsonWidget.of(context).json);
  var currentchapter = s - 1;
  return Container(
      margin: EdgeInsets.only(top: std_padding),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
          padding: EdgeInsets.all(std_padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chaptername displayed in every Chapter
              Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        padding: EdgeInsets.all(18),
                        onPressed: ()=> Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (BuildContext materialcontext) => Question(context, orderlist(json.chaptersize(currentchapter), true), currentchapter, buildquestionlist(currentchapter, 1, json, true))),
                        ),
                        child: Text(
                          json.chapter_names(currentchapter),
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    )
                  ]
              ),
              chapterleassons(menu,currentchapter, json),
            ],
          )
      )
  );
}
buildquestionlist(var chapter, var subchapter, Json json, bool random){

  int i = 0; List<int> orderlist = List.generate((json.subchaptersize(chapter,subchapter)),(generator) {i++; return i - 1;});

  if(!random) return orderlist;
  else orderlist.shuffle(); return orderlist;

}
