
import 'package:amateurfunktrainer/coustom_libs/icons.dart';
import 'package:amateurfunktrainer/coustom_libs/json.dart';
import 'package:amateurfunktrainer/screens/question.dart';
import 'package:flutter/material.dart';


Widget chapterleassons(var menu, var chapter, var json) => ListView.builder(
    physics: NeverScrollableScrollPhysics(),
    addAutomaticKeepAlives: true,
    shrinkWrap: true,
    itemCount: menu.results['chapterinfo'][chapter].length,
    itemBuilder: (context, i) {
      return Card(
        margin: EdgeInsets.only(top: 24),
        child: Column(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (BuildContext materialcontext) => Question(context, i, chapter, _buildquestionlist(chapter, i, json, true))),
              ),
              child: ListTile(
                leading: Icon(starticon(menu.results['chapterinfo'][chapter][i][1])),
                title: Text(
                  menu.results['chapterinfo'][chapter][i][0],
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

_buildquestionlist(var chapter, var subchapter, Json json, bool random){

  int i = 0; List<int> orderlist = List.generate((json.chaptersize(chapter,subchapter)),(generator) {i++; return i - 1;});

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
