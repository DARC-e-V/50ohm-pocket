
import 'package:amateurfunktrainer/coustom_libs/database.dart';
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
            itemCount: json.mainchaptersize(),
            itemBuilder: (context, i) {
              if(i == 0){
                return Padding(
                    padding: EdgeInsets.only(top:8, right: std_padding, left: std_padding),
                    child:
                    Column(children: [
                      Text(
                        "${json.main_chapter_name()}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 35,
                          ),
                        ),
                      Divider(height: 20,)
                    ],)
                );
              }
                return chapterwidget(json, i - 2, context);
            }
    )
  );

}


Widget chapterwidget(var json, var s, var context){
  var currentmainchapter = s + 1;
  return SizedBox(
    width: 100,
    child: Container(
        margin: json.chaptersize(currentmainchapter) == 0 ? EdgeInsets.all(0) : EdgeInsets.only(top: std_padding),
        decoration: BoxDecoration(
          color: json.chaptersize(currentmainchapter) == 0 ? Colors.indigoAccent.withOpacity(0) : Colors.indigoAccent.withOpacity(0.2),
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
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent[100],
                            shape: RoundedRectangleBorder(borderRadius: json.chaptersize(currentmainchapter) == 0 ? BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)) :BorderRadius.all(Radius.circular(5))),                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (BuildContext materialcontext) => Question(context, orderlist(json.chaptersize(currentmainchapter), true), currentmainchapter)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              json.chapter_names(currentmainchapter),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                        ),
                      )
                    ]
                ),
                  json.chaptersize(currentmainchapter) == 0 
                    ? LinearProgressIndicator(value: Databaseobj(context).read(JsonWidget.of(context).mainchapter, currentmainchapter, null))
                    : Text(""),

                chapterLesson(currentmainchapter, json),
              ],
            )
        )
    ),
  );
}

Widget chapterLesson(var chapter, var json) => ListView.builder(
    physics: NeverScrollableScrollPhysics(),
    addAutomaticKeepAlives: true,
    shrinkWrap: true,
    itemCount: json.chaptersize(chapter),
    itemBuilder: (context, subchapter) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)), // Adjust the radius as needed
        ),
        margin: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            LinearProgressIndicator(value: Databaseobj(context).read(JsonWidget.of(context).mainchapter, chapter, subchapter)),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (BuildContext materialcontext) => Question(context, [subchapter], chapter)),
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