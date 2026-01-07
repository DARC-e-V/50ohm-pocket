import 'dart:convert';

import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class Json{
  Map<String, dynamic>? data;
  Json(this.data);

  Future<Map<String, dynamic>?> load(final String questionpath, int mainchapter, BuildContext context) async {
    var rawdata = await rootBundle.loadString(questionpath);
    Map<String, dynamic>? importedData  = jsonDecode(rawdata);
    List<int> klassen = DatabaseWidget.of(context).settings_database.get("Klasse");
    if(importedData != Null){

      if(mainchapter == -1){
        this.data = importedData!;

        for(var i in this.data!["sections"]){
          for(var y in i["sections"]){
            (y["questions"] as List).removeWhere(
              (z){
                for(int klasse in klassen){
                  if(z["class"] == klasse.toString()){
                    return false;
                  }
                }
                return true;
              }
            );
          }
        }
        for(int i = 0; i < (this.data!["sections"] as List).length; i++){
          this.data!["sections"][i]["sections"].removeWhere((element) {
            if((element["questions"] as List).isEmpty){
              //print(element["title"]);
              return true;
            }
            return false;
          });
          if((this.data!["sections"][i]["sections"] as List).isEmpty){
            (this.data!["sections"] as List).removeAt(i);
            i--;
          }
        }
        return this.data;
      } else {
          this.data = importedData!["sections"][mainchapter];
          if(mainchapter == 0){
            for(var i in this.data!["sections"]){
              for(var y in i["sections"]){
                (y["questions"] as List).removeWhere(
                  (z){
                    for(int klasse in klassen){
                      if(z["class"] == klasse.toString()){
                        return false;
                      }
                    }
                    return true;
                  }
                );
              }
            }
            (this.data!["sections"] as List).removeWhere(
              (element){
                for(var y in element["sections"]){
                  if((y["questions"] as List).isEmpty){
                    return true;
                  }
                }
                return false;
              }
            );
          }
          return this.data;
        }
    }
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
    }on NoSuchMethodError catch(_){
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

  bool imageQuestion(int chapter, var subchapter, int question){
    try{
      if(this.data!["sections"][chapter]["sections"][subchapter]["questions"][question]["picture_a"] != null){
        return true;
      }
      return false;
    }catch(_){
      if(this.data!["sections"][chapter]["questions"][question]["picture_a"] != null){
        return true;
      }
      return false;
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

  List<String> imageList(int chapter, var subchapter, int question){
    try{
      Map answerSection = this.data!["sections"][chapter]["sections"][subchapter]["questions"][question];
      return [answerSection["picture_a"], answerSection["picture_b"], answerSection["picture_c"], answerSection["picture_d"]];
    }catch(e){
      Map answerSection = this.data!["sections"][chapter]["questions"][question];
      return [answerSection["picture_a"], answerSection["picture_b"], answerSection["picture_c"], answerSection["picture_d"]];
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

  // Get total question count for a chapter (including all subchapters)
  int getTotalQuestionCount(int chapter) {
    try {
      int totalCount = 0;
      var sections = this.data!["sections"][chapter]["sections"];
      
      // If this chapter has subsections
      if (sections is List) {
        for (var subsection in sections) {
          if (subsection["questions"] != null) {
            totalCount += (subsection["questions"] as List).length;
          }
        }
      }
      return totalCount;
    } catch (e) {
      // If there's an error, try to get direct questions
      try {
        return (this.data!["sections"][chapter]["questions"] as List).length;
      } catch (e) {
        return 0;
      }
    }
  }

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