

import 'package:amateurfunktrainer/widgets/chapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'json.dart';

Widget selectlesson(var data) {
  var menu = Chaptermenu(data);
  menu.learn_module_name();
  menu.chapter_names();
  menu.subchapter_info();
  menu.main_chapter_names();
  //print(menu.results['chapterinfo'][1].length);
  //print(menu.results['chapterinfo'].length);
  return ListView.builder(
            itemCount: menu.results["chapternames"].length ,
            itemBuilder: (context, i) {
              if(i < 1){
                return Padding(padding: EdgeInsets.only(top:20, right: std_padding, left: std_padding), child:
                  Column(children: [
                    Text(
                      menu.results["learnmodulename"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                        ),
                      ),
                    Divider()
                  ],)
                );
              }
                return chapterwidget(menu, i, data);
            }
  );
}

