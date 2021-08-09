import 'package:amateurfunktrainer/coustom_libs/json.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Database{

  var database;

  load() async{
    await Hive.initFlutter();
    database = await Hive.openBox('progress');
    return database;
  }
 
}

class Databaseobj extends Database{
  BuildContext context;
  var mainchapter, subchapter, chapter, result;
  
  Databaseobj(
    this.context,
    this.mainchapter,
    this.chapter,
    this.subchapter,
    this.result,
  );



  write(){
    print("result  $result");
    result = result.map((x) => x ? 1 : 0).toList();
    // List list = DatabaseWidget.of(context).database.get("[$mainchapter][$chapter][${subchapter[0]}]");
    //print("liste :: $list");
    try{  
      List list = DatabaseWidget.of(context).database.get("[$mainchapter][$chapter][${subchapter[0]}]");

      DatabaseWidget.of(context).database.put(
          "[$mainchapter][$chapter][${subchapter[0]}]",
          list.map((x) => x + 1).toList()
        );
    
    }catch(e){
      DatabaseWidget.of(context).database.put(
        // Todo generate the list at the first time 
      "[$mainchapter][$chapter][${subchapter[0]}]", (result as List<dynamic>)
      );
    }
  }


}


class DatabaseWidget extends InheritedWidget{

  final database;

  const DatabaseWidget(Widget child, this.database) : super(child:child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
  false;

  static DatabaseWidget of(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<DatabaseWidget>()!;

}