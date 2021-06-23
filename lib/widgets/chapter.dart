import 'dart:ui';

import 'package:amateurfunktrainer/coustom_libs/json.dart';
import 'package:amateurfunktrainer/widgets/singlechapter.dart';
import 'package:flutter/material.dart';
import 'package:amateurfunktrainer/screens/question.dart';

import '../constants.dart';

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
