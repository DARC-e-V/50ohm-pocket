

import 'package:amateurfunktrainer/widgets/chapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../coustom_libs/json.dart';

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

