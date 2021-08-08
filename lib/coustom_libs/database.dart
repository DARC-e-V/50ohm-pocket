import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Database{

  var database;

  load() async{
    await Hive.initFlutter();
    database = await Hive.openBox('testBox');
    return database;
  }
 

}

class Databaseobj extends Database{
  BuildContext context;
  var mainchapter, subchapter, chapter, question;
  
  Databaseobj(
    this.context,
    this.mainchapter,
    this.subchapter,
    this.chapter,
    this.question
  );

  write(){
    try{
      List list = DatabaseWidget.of(context).database.get("[$mainchapter][$subchapter][$chapter]");
      list.every((element) => element + 1);
      DatabaseWidget.of(context).database.delete("[$mainchapter][$subchapter][$chapter]");
      DatabaseWidget.of(context).database.put("[$mainchapter][$subchapter][$chapter]", list);
    }catch(e){
      DatabaseWidget.of(context).database.put(
        // Todo generate the list at the first time 
      "[$mainchapter][$subchapter][$chapter]", [0, 1, 2, 0, 2, 3, 1, 0]
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