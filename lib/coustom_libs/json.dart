import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Json{
  Map<String, dynamic>? data;
  Json(this.data);

  Future load() async {
    var rawdata = await rootBundle.loadString('/DL_Technik_Klasse_E_2007/questions.json');
    this.data = jsonDecode(rawdata);
    return this.data;
  }

  main_chapter_name() => this.data!["exam"]["name"];

  chapter_names(var chapter) => this.data!["chapter"]["chapter"][chapter]["name"];


  questionname(var chapter, var subchapter, var question) =>
      this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"][question]["textquestion"];

  answer(int chapter, int subchapter, int question, int answer){
    try{
      return [(this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"][question]["textanswer"][answer]["text"]), true ];
    }catch(e){
      return [(this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"][question]["textanswer"][answer]) , false];
    }
  }
  correctanswer(int chapter, int subchapter, int question) => this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"][question]["textanswer"][0]["text"];

  subchaptersize(int chapter, int subchapter) => this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"].length;
  chaptersize(int chapter) => this.data!["chapter"]["chapter"][chapter]["chapter"].length;


  procentofchapter(List questionlist, int currentprog) => (questionlist.length * currentprog) * 0.1 ;


}

class JsonWidget extends InheritedWidget{
  final Map<String, dynamic>? json;

  const JsonWidget(Widget child, this.json) : super(child:child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      false;

  static JsonWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<JsonWidget>()!;

}


class Chaptermenu{
  var data;
  List chapter = [];
  List chapternames = [];
  List subchapterlist = [];
  var results = Map();

  Chaptermenu(final this.data);

  main_chapter_names(){
    this.results["chaptername"] = this.data["chapter"]["name"];
  }

  learn_module_name(){
    this.results["learnmodulename"] = this.data["exam"]["name"];
  }

  chapter_names(){
    var chaptername = data["chapter"]["chapter"];
    for(var i in chaptername){
      var _chapname = i["name"];
      this.chapternames.add(_chapname);
    }
    this.results["chapternames"] = chapternames;
  }

  subchapter_info(){
    var chaptername = data["chapter"]["chapter"];
    var rootsubchapterlist = [];
    var subchapterlist = [];
    for(var i in chaptername){
        for(var subchapter in i["chapter"]){
          var name = subchapter["name"];
          var icon = subchapter["icon"];
          subchapterlist.add([name, icon]);
          //print(rootsubchapterlist);
        }
        rootsubchapterlist.add(subchapterlist);
        subchapterlist = [];
        //print(rootsubchapterlist);
    }
    this.results["chapterinfo"] = rootsubchapterlist;

  }
  question(final int chapter,final int subchapter, final int question){
    var chaptername = this.data["chapter"]["chapter"];
    var result = chaptername[chapter]["chapter"][subchapter]["question"][question];
    return result;
  }
  questionprocent(final int chapter,final int subchapter, final int question){
    var chaptername = this.data["chapter"]["chapter"];
    var returnvalue = ((100 / (chaptername[chapter]["chapter"][subchapter]["question"].length)) / 100) * question;
    return returnvalue;
  }
  questioncount(final int chapter,final int subchapter, final int question){
    var chaptername = this.data["chapter"]["chapter"];
    return chaptername[chapter]["chapter"][subchapter]["question"].length;
  }
}

/*
[
  "subchapter" = [[[name,icon], [name,icon]], [[name,icon]]]
]
*/
