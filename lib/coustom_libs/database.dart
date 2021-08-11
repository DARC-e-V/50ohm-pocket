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

class Databaseobj{
  BuildContext context;
  
  Databaseobj(this.context,);

  write(mainchapter, chapter, subchapter, result){
    result = result.map((x) => x ? 1 : 0).toList();
    // List list = DatabaseWidget.of(context).database.get("[$mainchapter][$chapter][${subchapter[0]}]");
    //print("liste :: $list");
    try{  
      List list = DatabaseWidget.of(context).database.get("[$mainchapter][$chapter][${subchapter[0]}]");
      int x = 0;
      List<dynamic> updatedres = list.map((item){x++; return  item + result[x - 1];}).toList();
      DatabaseWidget.of(context).database.put(
          "[$mainchapter][$chapter][${subchapter[0]}]",
          updatedres
        );
    }catch(e){
      DatabaseWidget.of(context).database.put(
        // Todo generate the list at the first time 
      "[$mainchapter][$chapter][${subchapter[0]}]", (result as List<dynamic>)
      );
    }
  }

  read(mainchapter, chapter, subchapter){
    try{

      print("subchapter $subchapter");
      List<dynamic> list = DatabaseWidget.of(context).database.get("[$mainchapter][$chapter][$subchapter]");
      print("liste $list");
      return (list.fold(0, (var x, element) => element + x) / (list.length * 5));
    }catch(e){
      return 0.0;
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