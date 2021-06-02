
import 'package:amateurfunktrainer/widgets/chapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'json.dart';

Widget selectlesson(var data) {
  var menu = Menu();
  menu.data = data;
  var test = menu.chapter_names();
  print("$test");
  return ListView(
    children: [
      Padding(padding: EdgeInsets.only(top:20, right: std_padding, left: std_padding), child: Text(
          menu.learn_module_name(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 35,
        ),
      ),),
      Divider(),
      chapterwidget(menu.chapter_names(), Color(0x86c7f7) ),
      chapterwidget(menu.chapter_names(), Color(0x86f7df)),
      chapterwidget(menu.chapter_names(), Color(0xf786f5)),
      chapterwidget(menu.chapter_names(), Color(0xffffff)),
    ],
  );
}

