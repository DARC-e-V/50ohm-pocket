import 'package:flutter/material.dart';
import 'package:fuenfzigohm/coustom_libs/questionState.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Database{

  late Box progress;
  late Box settings;
  late Box progress2;

  load() async{
    await Hive.initFlutter();
    settings = await Hive.openBox('settings');
    progress = await Hive.openBox('progress');
    progress2 = await Hive.openBox('progress2');
    return [progress, settings, progress2];
  }
}

class EventData {
  final String event;
  final String value;
  final String context;

  EventData({required this.event, required this.value, required this.context});

  Map<String, dynamic> toJson() {
    return {
      'event': event,
      'value': value,
      'context': context,
    };
  }
  String toJsonString() {
    return toJson().toString();
  }
}

class DatabaseFunctions{

  static void write(BuildContext context, QuestionEvaluation questionEvaluation){

    String isoTimeString = _getisoUTCString();
    EventData correctEvent =
      EventData(event: 'correct', value: questionEvaluation.question.questionID, context: 'none');
    // push event after correct answer
    DatabaseWidget
        .of(context)
        .prog_database2
        .put(isoTimeString, correctEvent.toJsonString());

    if(questionEvaluation.correct){
      // Todo: get and update progress
      // push updated chapter progress
      EventData chapterUpdateEvent =
      EventData(event: 'chapter_update', value: "10", context: questionEvaluation.question.questionID);

      DatabaseWidget
          .of(context)
          .prog_database2
          .put(isoTimeString, chapterUpdateEvent.toJsonString());
    }

  }

  static double read(BuildContext context, mainchapter, chapter, subchapter){
    try{
      List<dynamic> list = DatabaseWidget.of(context).prog_database.get(subchapter == null ? "[$mainchapter][$chapter]" : "[$mainchapter][$chapter][$subchapter]");
      return (list.fold(0, (var x, element) => element + x) / (list.length * 3));
    }catch(e){
      return 0.0;
    }  
  }
  static void checkMigrate(Box prog_database, Box prog_database2){
    if(prog_database.get("migrated") == null){
      migrate(prog_database, prog_database2);
    }
  }
  static void migrate(Box prog_database, Box prog_database2){
    List<dynamic> keys = prog_database.keys.toList();
    String isoTimeString = _getisoUTCString();

    for(var key in keys){
      if(key is String){
        EventData event = EventData(
          event: 'chapter_update',
          value: prog_database.get(key),
          context: key,
        );
        prog_database2.put(isoTimeString, event.toJsonString());
      }
    }
  }

  static String _getisoUTCString(){
    DateTime now = DateTime.now().toUtc();
    String isoTimeString = now.toIso8601String();
    return isoTimeString;
  }
}


class DatabaseWidget extends InheritedWidget{

  final Box settings_database;
  final Box prog_database;
  final Box prog_database2;

  const DatabaseWidget({
    required this.settings_database,
    required this.prog_database,
    required this.prog_database2,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
  false;

  static DatabaseWidget of(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<DatabaseWidget>()!;
}