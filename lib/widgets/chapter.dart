import 'dart:ui';

import 'package:amateurfunktrainer/coustom_libs/json.dart';
import 'package:amateurfunktrainer/widgets/singlechapter.dart';
import 'package:flutter/material.dart';

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
                      onPressed: (){},
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
