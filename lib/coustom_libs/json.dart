import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Json{
  Map<String, dynamic>? data;
  Json(this.data);

  Future load(final questionpath) async {
    var rawdata = await rootBundle.loadString(questionpath);
    this.data = jsonDecode(rawdata);
    return this.data;
  }

  main_chapter_name() =>
      this.data!["exam"]["name"];

  chapter_names(var chapter) =>
      this.data!["chapter"]["chapter"][chapter]["name"];
  chaptericon(int chapter, int subchapter) =>
      this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["icon"];

  subchapter_name(int chapter, int subchapter) =>
      this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["name"];

  questionname(var chapter, var subchapter, var question){
    try{
      return this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter!]["question"][question]["textquestion"];
    }catch(e){
      return this.data!["chapter"]["chapter"][chapter]["chapter"]["question"][question]["textquestion"];
    }
  }

  questonlylistleng(var chapter) => this.data!["chapter"]["chapter"][chapter]["question"].length;


  answer(int chapter, int subchapter, int question, int answer){
    try{
      try{
        return [(this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"][question]["textanswer"][answer]["text"]), true ];
      }catch(e){
        return [(this.data!["chapter"]["chapter"][chapter]["chapter"]["question"][question]["textanswer"][answer]["text"]), true ];
      }
    }catch(e){
      try{
        return [(this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"][question]["textanswer"][answer]) , false];
      }catch(e){
        return [(this.data!["chapter"]["chapter"][chapter]["chapter"]["question"][question]["textanswer"][answer]) , false];
      }

    }
  }
  correctanswer(int chapter, int subchapter, int question){
    try{
      return this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"][question]["textanswer"][0]["text"];
    }catch(e){
      return this.data!["chapter"]["chapter"][chapter]["chapter"]["question"][question]["textanswer"][0]["text"];
    }
  }

  answercount(int chapter, int subchapter, int question) =>
      this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"][question].length;
  subchaptersize(int chapter, int subchapter) =>
      this.data!["chapter"]["chapter"][chapter]["chapter"][subchapter]["question"].length;

  // can be that there are none subchapters just the list of questions
  chaptersize(int chapter) {
    try{
      return this.data!["chapter"]["chapter"][chapter]["chapter"].length;
    }catch(e){
      return 0;
    }
  }

  mainchaptersize() =>
      this.data!["chapter"]["chapter"].length;
  // Todo fix
  procentofchapter(List questionlist, int currentprog) =>
      (questionlist.length * currentprog) * 0.1 ;

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