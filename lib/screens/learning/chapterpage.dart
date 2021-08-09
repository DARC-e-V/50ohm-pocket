
import 'dart:math';

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
            itemCount:json.mainchaptersize() + 1 ,
            itemBuilder: (context, i) {
              if(i == 0){
                return Padding(
                    padding: EdgeInsets.only(top:20, right: std_padding + 6, left: std_padding + 6),
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
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.indigoAccent[100]),
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (BuildContext materialcontext) => Question(context, json, orderlist(json.chaptersize(currentmainchapter), true), currentmainchapter)),// buildquestionlist(currentchapter, 1, json, true) //buildquestionlist(chapter, subchapter, json, true)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Text(
                              json.chapter_names(currentmainchapter),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                        ),
                      )
                    ]
                ),
                chapterleassons(currentmainchapter, json),
              ],
            )
        )
    ),
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
            LinearProgressIndicator(value: 0.1 * Random().nextInt(10) ,),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (BuildContext materialcontext) => Question(context, json, [subchapter], chapter)),
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
  print("chapter : $chapter , subchapter $subchapter");
  print("${json.subchaptersize(chapter,subchapter)}");
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