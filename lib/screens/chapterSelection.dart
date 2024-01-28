import 'package:fuenfzigohm/constants.dart';
import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:fuenfzigohm/coustom_libs/icons.dart';
import 'package:fuenfzigohm/coustom_libs/json.dart';
import 'package:fuenfzigohm/screens/question.dart';
import 'package:fuenfzigohm/screens/settings.dart';
import 'package:fuenfzigohm/screens/aboutApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'formelsammlung.dart';


class Learningmodule extends StatefulWidget {
  @override
  createState() => _LearningmoduleState();
}

class _LearningmoduleState extends State<Learningmodule> {
  late List<Tab> tabs;
  bool reload = false;


  @override
  Widget build(BuildContext context) {
    bool courseOrdering = DatabaseWidget.of(context).settings_database.get("courseOrdering") ?? true;
    return Scaffold(
        appBar: AppBar(
          title: SvgPicture.asset("assets/svgs/ohm2.svg"),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 2,
                  child: ListTile(
                    leading: Icon(Icons.functions), // Icon for Formelsammlung
                    title: Text("Formelsammlung"),
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.settings), // Icon for Einstellungen
                    title: Text("Einstellungen"),
                  ),
                ),
                PopupMenuItem(
                  value: 0,
                  child: ListTile(
                    leading: Icon(Icons.privacy_tip), // Icon for Datenschutzerklärung
                    title: Text("Über diese App"),
                  ),
                ),
              ],
              onSelected: (item) => _selectItem(context, item),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 3,
          child: Scaffold(
            body: courseOrdering
            ? chapterbuilder(context, 'assets/questions/ausbildungsmaterial.json', -1)
            : PageView.builder(
                itemBuilder: (content, index){
                  if(index == 0){
                    return chapterbuilder(context, 'assets/questions/Questions.json', 0);
                  }else if(index == 1){
                    return chapterbuilder(context, 'assets/questions/Questions.json', 1);
                  }else{
                    return chapterbuilder(context, 'assets/questions/Questions.json', 2);
                  }
                },
                itemCount: 3,
                )
            ),
          ),
    );
  }

  _selectItem(BuildContext context, Object item) {
    switch(item){
      case 2:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Formularpage(1)));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Settingspage()));
        break;
      case 0:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutAppPage()));
        break;
    }
  }

  Widget chapterbuilder(var context, var path, var mainchapter) {    
    return FutureBuilder(
        future: Json(null).load(path, mainchapter, context),
        builder: (context, snapshot){
          if (snapshot.hasData) {
            return JsonWidget(selectlesson(snapshot.data, context),(snapshot.data as Map<String, dynamic>), mainchapter);
          } else if (snapshot.hasError){
            print(snapshot.error);
            return Text("Konnte die Fragen nicht laden");
          } else {
            return Padding(
              padding: EdgeInsets.all(std_padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("Inhalte werden geladen ..."),
                  ],
              ),
            );
          }
        },
    );
  }
  Widget selectlesson(var data, var context) {
    Json json = Json(data);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 800, minWidth: 0),
    
      child: Padding(
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
      ),
    );
  }


  Widget chapterwidget(var json, var s, var context){
    var currentmainchapter = s + 1;
    return SizedBox(
      width: 100,
      child: Container(
          margin: json.chaptersize(currentmainchapter) == 0 ? EdgeInsets.all(0) : EdgeInsets.only(top: std_padding),
          decoration: BoxDecoration(
            color: json.chaptersize(currentmainchapter) == 0 ? main_col.withOpacity(0.4) : main_col.withOpacity(0.4),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
              padding: EdgeInsets.all(std_padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.fromHeight(100),
                      backgroundColor: main_col.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: json.chaptersize(currentmainchapter) == 0 
                          ? BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)) 
                          : BorderRadius.all(Radius.circular(5))
                      ),
                    ),
                    // onPressed: () async {
                    //   Navigator.of(context).push(
                    //     MaterialPageRoute(builder: (BuildContext context) => Question(context, orderlist(json.chaptersize(currentmainchapter), true), currentmainchapter)),
                    //   ).then((value){
                    //     if(value ?? false){
                    //       setState(() {});
                    //     }
                    //   });
                    // },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        json.chapter_names(currentmainchapter),
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  ),
                    json.chaptersize(currentmainchapter) == 0 
                      ? LinearProgressIndicator(value: Databaseobj(context).read(JsonWidget.of(context).mainchapter, currentmainchapter, null))
                      : SizedBox(height: 8,),

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
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
        ),
        margin: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            LinearProgressIndicator(value: Databaseobj(context).read(JsonWidget.of(context).mainchapter, chapter, subchapter), color: main_col,),
            InkWell(
              onTap:() async {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (BuildContext materialcontext) => Question(context, [subchapter], chapter)),
                    ).then((value){
                      if(value ?? false){
                        setState(() {});
                      }
                    });
                },
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

}


buildquestionlist(var chapter, var subchapter, Json json, bool random){
  int i = 0; List<int> orderlist = List.generate((json.subchaptersize(chapter,subchapter)),(generator) {i++; return i - 1;});

  if(!random) return orderlist;
  else orderlist.shuffle(); return orderlist;

}

starticon(var string){
  if(string == null){
    return Icons.keyboard_arrow_right;
  }
  var icon = getMaterialIcon( name: '$string');
  return icon;
}