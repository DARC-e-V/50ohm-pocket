
import 'package:amateurfunktrainer/coustom_libs/icons.dart';
import 'package:amateurfunktrainer/screens/learning/question.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../coustom_libs/json.dart';

Widget selectlesson(var data, var context) {
  Json json = Json(data);
  return Padding(
      padding: EdgeInsets.only(left: 5,right: 5),
      child: ListView.builder(
            itemCount:json.mainchaptersize(),
            itemBuilder: (context, i) {
              if(i < 1){
                return Padding(
                    padding: EdgeInsets.only(top:20, right: std_padding, left: std_padding),
                    child:
                    Column(children: [
                      Text(
                        "${json.main_chapter_name()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          ),
                        ),
                      Divider()
                    ],)
                );
              }
                return chapterwidget(json, i, context);
            }
    )
  );

}


Widget chapterwidget(var json, var s, var context){
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
              chapterleassons(currentchapter, json),
            ],
          )
      )
  );
}

Widget chapterleassons(var chapter, var json) => ListView.builder(
    physics: NeverScrollableScrollPhysics(),
    addAutomaticKeepAlives: true,
    shrinkWrap: true,
    itemCount: json.chaptersize(chapter),
    itemBuilder: (context, subchapter) {
      return Card(
        margin: EdgeInsets.only(top: 24),
        child: Column(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (BuildContext materialcontext) => Question(context, [subchapter], chapter, buildquestionlist(chapter, subchapter, json, true))),
              ),
              child: ListTile(
                leading: Icon(starticon(json.chaptericon(chapter, subchapter))),
                title: Text(
                  json.subchapter_name(chapter, subchapter),
                  style: TextStyle(
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
);

//coustom libs

buildquestionlist(var chapter, var subchapter, Json json, bool random){

  int i = 0; List<int> orderlist = List.generate((json.subchaptersize(chapter,subchapter)),(generator) {i++; return i - 1;});

  if(!random) return orderlist;
  else orderlist.shuffle(); return orderlist;

}

starticon(var string){
  if(string == null){
    return Icons.keyboard_arrow_right;
  }
  //print(string);
  var icon = getMaterialIcon( name: '$string');
  //print(icon);
  return icon;
}