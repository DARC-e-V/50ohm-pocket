import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Database{

  var database;
  Map<String,dynamic> progess = {
    "Technische Kentnisse Klasse E" : {
      "Allgemeine mathematische Grundkenntnisse und Größen" : {
        "Allgemeine mathematische Grundkenntnisse" : [
          [3, 1],
          [1, 2],
          [1, 2]
        ]
      }
    }
  };


  load() async{
    await Hive.initFlutter();
    database = await Hive.openBox('testBox');
    print("${database.runtimeType}");
    return database;
  }

}


class DatabaseWidget extends InheritedWidget{



  const DatabaseWidget(Widget child) : super(child:child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
  false;

  static DatabaseWidget of(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<DatabaseWidget>()!;

}