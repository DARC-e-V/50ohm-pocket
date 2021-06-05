
import 'dart:ui';

import 'package:amateurfunktrainer/coustom_libs/icons.dart';
import 'package:amateurfunktrainer/widgets/question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../constants.dart';
import '../json.dart';

chapterwidget(var menu, var s, var data){
  var currentchapter = s - 1;
  return Container(
    margin: EdgeInsets.only(top: std_padding, bottom: std_padding + 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          second_col,
          Color(0xFFEEEEEE)
        ],
      ),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Padding(
        padding: EdgeInsets.only(left: std_padding, top: std_padding, bottom: std_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                children: [
                  Expanded(child: Text(
                    menu.results['chapternames'][currentchapter],
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),)
                ]
            ),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                addAutomaticKeepAlives: true,
                shrinkWrap: true,
              itemCount: menu.results['chapterinfo'][currentchapter].length,
                itemBuilder: (context, i) {
                  return Card(
                        margin: EdgeInsets.only(top: 24,right: 30),
                        child: Column(
                          children: [
                            InkWell(
                            onTap: () => pushquestion(menu.results['chapternames'][currentchapter], context, data, currentchapter, i),
                            child: ListTile(
                              leading: Icon(strtoicon(menu.results['chapterinfo'][currentchapter][i][1])),//Icon(icon(i, subchapter)),
                              title: Text(
                                menu.results['chapterinfo'][currentchapter][i][0],
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
            )
          ],
        )
    )
  );
}

strtoicon(var string){
  if(string == null){
    return Icons.keyboard_arrow_right;
  }
  //print(string);
  var icon = getMaterialIcon( name: '$string');
  //print(icon);
  return icon;
}