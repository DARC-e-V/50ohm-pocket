import 'dart:ui';

import 'package:amateurfunktrainer/coustom_libs/icons.dart';
import 'package:amateurfunktrainer/screens/question.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

chapterwidget(var menu, var s, var data, var context){
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
                        menu.results['chapternames'][currentchapter],
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  )
                ]
            ),
            // List View displays the subsections
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                addAutomaticKeepAlives: true,
                shrinkWrap: true,
              itemCount: menu.results['chapterinfo'][currentchapter].length,
                itemBuilder: (context, i) {
                  return Card(
                        margin: EdgeInsets.only(top: 24),
                        child: Column(
                          children: [
                            InkWell(
                            onTap: () => pushquestion(menu.results['chapternames'][currentchapter], context, data, currentchapter, i),
                            child: ListTile(
                              leading: Icon(starticon(menu.results['chapterinfo'][currentchapter][i][1])),//Icon(icon(i, subchapter)),
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

starticon(var string){
  if(string == null){
    return Icons.keyboard_arrow_right;
  }
  //print(string);
  var icon = getMaterialIcon( name: '$string');
  //print(icon);
  return icon;
}