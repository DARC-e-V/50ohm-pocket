import 'package:fuenfzigohm/constants.dart';
import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:fuenfzigohm/coustom_libs/icons.dart';
import 'package:fuenfzigohm/coustom_libs/json.dart';
import 'package:fuenfzigohm/screens/question.dart';
import 'package:fuenfzigohm/screens/settings.dart';
import 'package:fuenfzigohm/screens/aboutApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pdfViewer.dart';


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
        title: SvgPicture.asset("assets/icons/ohm2.svg"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.open_in_browser), // Hilfsmittel
                  title: Text("Hilfsmittel"),
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
                ? getUserClass(context)
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
    switch (item) {
      case 2:
        _launchURL("https://50ohm.de/hm");
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Settingspage()));
        break;
      case 0:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AboutAppPage()));
        break;
    }
  }

  _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch');
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
    return Center( child: ConstrainedBox(
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
    ));
  }


  Widget chapterwidget(var json, var s, var context){
    var currentmainchapter = s + 1;
    int totalQuestions = json.getTotalQuestionCount(currentmainchapter);
    
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            json.chapter_names(currentmainchapter),
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          if (totalQuestions > 0) ...[
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$totalQuestions ${totalQuestions == 1 ? 'Frage' : 'Fragen'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
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
        int questionCount = json.subchaptersize(chapter, subchapter);
        
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
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: main_col.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: main_col.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$questionCount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: main_col,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
  );

  getUserClass(BuildContext context) {
    print(DatabaseWidget.of(context).settings_database.get("Klasse"));
    switch(DatabaseWidget.of(context).settings_database.get("Klasse")){
      case [1]:
        return chapterbuilder(context, 'assets/questions/N.json', -1);
      case [1, 2]:
        return chapterbuilder(context, 'assets/questions/NE.json', -1);
      case [1, 2, 3]:
        return chapterbuilder(context, 'assets/questions/NEA.json', -1);
      case [2]:
        return chapterbuilder(context, 'assets/questions/E.json', -1);
      case [3]:
        return chapterbuilder(context, 'assets/questions/A.json', -1);
      case [2, 3]:
        return chapterbuilder(context, 'assets/questions/EA.json', -1);

    }
  }

}

Future<void> launchURL(url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
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