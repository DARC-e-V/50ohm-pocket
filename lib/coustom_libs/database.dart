import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Database{

  var progress;
  var settings;

  load() async{
    await Hive.initFlutter();
    settings = await Hive.openBox('settings');
    progress = await Hive.openBox('progress');
    return [progress, settings ];
  }
}

class Databaseobj{
  BuildContext context;

  Databaseobj(this.context);

  write(mainchapter, chapter, subchapter, resultlist){
    int i = 0;
    for(var result in resultlist){

      result = result.map((x) => x ? 1 : 0).toList();

      // List list = DatabaseWidget.of(context).database.get("[$mainchapter][$chapter][${subchapter[0]}]");
      //print("liste :: $list");
      try{  
        List list = DatabaseWidget.of(context).prog_database.get(subchapter.length == 0  ? "[$mainchapter][$chapter]" : "[$mainchapter][$chapter][${subchapter[i]}]");
        int x = 0;
        List<dynamic> updatedres = list.map((item){x++; return  item + result[x - 1];}).toList();
        DatabaseWidget.of(context).prog_database.put(
            subchapter.length == 0  ? "[$mainchapter][$chapter]" : "[$mainchapter][$chapter][${subchapter[i]}]",
            updatedres
          );
      }catch(e){
        DatabaseWidget.of(context).prog_database.put(
        subchapter.length == 0  ? "[$mainchapter][$chapter]" :"[$mainchapter][$chapter][${subchapter[i]}]",
        (result as List<dynamic>)
        );
      }
      i++;
    }
  }

  read(mainchapter, chapter, subchapter){
    try{
      List<dynamic> list = DatabaseWidget.of(context).prog_database.get(subchapter == null ? "[$mainchapter][$chapter]" : "[$mainchapter][$chapter][$subchapter]");
      return (list.fold(0, (var x, element) => element + x) / (list.length * 3));
    }catch(e){
      return 0.0;
    }  
  }
  
  /// Returns the score for a single question at a specific index within a subchapter/chapter.
  /// Returns 0 if not found.
  int getQuestionScore(int mainchapter, int chapter, int? subchapter, int questionIndex) {
    try {
      String key = subchapter == null || subchapter == -1 
          ? "[$mainchapter][$chapter]" 
          : "[$mainchapter][$chapter][$subchapter]";
      List<dynamic>? scores = DatabaseWidget.of(context).prog_database.get(key);
      if (scores != null && questionIndex < scores.length) {
        return (scores[questionIndex] as int?) ?? 0;
      }
    } catch (e) {
      // Return 0 on error
    }
    return 0;
  }
  
  /// Returns a list of scores for ALL questions based on the provided question keys.
  /// Each key is [mainchapter, chapter, subchapter, questionIndex].
  /// Unanswered questions get score 0.
  List<int> getAllQuestionScoresFromKeys(List<List<int>> questionKeys) {
    List<int> allScores = [];
    
    for (var key in questionKeys) {
      int mainchapter = key[0];
      int chapter = key[1];
      int? subchapter = key[2] == -1 ? null : key[2];
      int questionIndex = key[3];
      
      int score = getQuestionScore(mainchapter, chapter, subchapter, questionIndex);
      allScores.add(score);
    }
    
    return allScores;
  }
  
  /// Returns a list of all question scores from all stored progress entries.
  /// Each score represents how many times a question was answered correctly.
  /// NOTE: This only returns answered questions. Use getAllQuestionScoresFromKeys for all questions.
  List<int> getAllQuestionScores() {
    List<int> allScores = [];
    Box progDb = DatabaseWidget.of(context).prog_database;
    
    for (var key in progDb.keys) {
      try {
        List<dynamic> scores = progDb.get(key);
        if (scores != null) {
          for (var score in scores) {
            allScores.add((score as int?) ?? 0);
          }
        }
      } catch (e) {
        // Skip invalid entries
      }
    }
    
    return allScores;
  }
  
  /// Returns a map with statistics about the learning progress.
  /// Keys: 'total', 'learned', 'inProgress', 'notStarted'
  Map<String, int> getProgressStats(List<int> scores) {
    int learned = scores.where((s) => s >= 3).length;
    int inProgress = scores.where((s) => s > 0 && s < 3).length;
    int notStarted = scores.where((s) => s <= 0).length;
    
    return {
      'total': scores.length,
      'learned': learned,
      'inProgress': inProgress,
      'notStarted': notStarted,
    };
  }
}


class DatabaseWidget extends InheritedWidget{

  final Box settings_database;
  final Box prog_database;

  const DatabaseWidget({
    required this.settings_database,
    required this.prog_database,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
  false;

  static DatabaseWidget of(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<DatabaseWidget>()!;

}