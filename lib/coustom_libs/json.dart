import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Json{
  Map<String, dynamic>? data;
  Json(this.data);

  Future load(final questionpath, mainchapter) async {
    var rawdata = await rootBundle.loadString(questionpath);
    this.data = jsonDecode(rawdata);
    return this.data!["sections"][mainchapter];
  }

  main_chapter_name() =>
      this.data!["title"];

  chapter_names(var chapter) =>
      this.data!["sections"][chapter]["title"];

  chaptericon(int chapter, int subchapter) => null;

  subchapter_name(int chapter, int subchapter) {
    try{
        return this.data!["sections"][chapter]["sections"][subchapter]["title"];
    }catch(e){
        return this.data!["sections"][chapter]["title"];
    }
  }

  questionname(var chapter, var subchapter, var question){
    try{
      return this.data!["sections"][chapter]["sections"][subchapter]["questions"][question]["question"];
    }catch(e){
      return this.data!["sections"][chapter]["questions"][question]["question"];
    }
  }

  String? questionimage(int chapter, var subchapter, int question){
    try{
      return this.data!["sections"][chapter]["sections"][subchapter]["questions"][question]["picture_question"];
    }catch(e){
      return this.data!["sections"][chapter]["questions"][question]["picture_question"];

    }
  }

  questionid(var chapter, var subchapter, var question){
    try{
      return this.data!["sections"][chapter]["sections"][subchapter]["questions"][question]["number"];
    }catch(e){
      return this.data!["sections"][chapter]["questions"][question]["number"];
    }
  }

  List<String> answerList(int chapter, var subchapter, int question){
    try{
      Map answerSection = this.data!["sections"][chapter]["sections"][subchapter]["questions"][question];
      return [answerSection["answer_a"], answerSection["answer_b"], answerSection["answer_c"], answerSection["answer_d"]];
    }catch(e){
      Map answerSection = this.data!["sections"][chapter]["questions"][question];
      return [answerSection["answer_a"], answerSection["answer_b"], answerSection["answer_c"], answerSection["answer_d"]];
    }
  }
  
  subchaptersize(int chapter, int subchapter){
    try{
      return this.data!["sections"][chapter]["sections"][subchapter]["questions"].length;
    }catch(e){
      return this.data!["sections"][chapter]["questions"].length;
    }
  }
    

  chaptersize(int chapter) {
    try{
      return this.data!["sections"][chapter]["sections"].length;
    }catch(e){
      return this.data!["sections"][chapter].length;
    }
      
  }

  mainchaptersize() =>
      this.data!["sections"].length + 1;
  // Todo fix
  percentOfChapter(List questionlist, int currentprog) =>
      (questionlist.length * currentprog) * 0.1 ;

}

class JsonWidget extends InheritedWidget{
  final Map<String, dynamic>? json;
  final int mainchapter;

  const JsonWidget(Widget child, this.json, this.mainchapter) : super(child:child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      false;

  static JsonWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<JsonWidget>()!;

}