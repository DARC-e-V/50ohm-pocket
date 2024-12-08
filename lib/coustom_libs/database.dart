import 'package:flutter/material.dart';
import 'package:fuenfzigohm/coustom_libs/questionState.dart';
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

  static void write(BuildContext context, QuestionEvaluation questionEvaluation){
    DateTime now = DateTime.now().toUtc();
    String isoTimeString = now.toIso8601String();

    // push event after correct answer
    DatabaseWidget
        .of(context)
        .prog_database
        .put(isoTimeString, """{
          \"event\" : \"correct\",
          \"value\" : \"${questionEvaluation.question.questionID}\"
          }""");

    // push updated chapter progress
    DatabaseWidget
        .of(context)
        .prog_database
        .put(isoTimeString, """{
          \"event\" : \"chapter_update\",
          \"value\" : \"${questionEvaluation.question.questionID}\"
          }""");

  }

  static double read(BuildContext context, mainchapter, chapter, subchapter){
    try{
      List<dynamic> list = DatabaseWidget.of(context).prog_database.get(subchapter == null ? "[$mainchapter][$chapter]" : "[$mainchapter][$chapter][$subchapter]");
      return (list.fold(0, (var x, element) => element + x) / (list.length * 3));
    }catch(e){
      return 0.0;
    }  
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