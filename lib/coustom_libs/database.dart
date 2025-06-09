import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Database {
  late Box<dynamic> progress;
  late Box<dynamic> settings;

  load() async {
    await Hive.initFlutter();
    settings = await Hive.openBox('settings');
    progress = await Hive.openBox('progress');
    return [progress, settings];
  }
}

// TODO: Clarify difference between "Database", "Databaseobj" and actual provider.
// Furthermore, discuss locator approach
class Databaseobj {
  BuildContext context;

  Databaseobj(this.context);

  write(mainchapter, chapter, subchapter, resultlist) {
    int i = 0;
    for (var result in resultlist) {
      result = result.map((x) => x ? 1 : 0).toList();

      // List list = DatabaseWidget.of(context).database.get("[$mainchapter][$chapter][${subchapter[0]}]");
      //print("liste :: $list");
      try {
        List list = DatabaseWidget.of(context).prog_database.get(
            subchapter.length == 0
                ? "[$mainchapter][$chapter]"
                : "[$mainchapter][$chapter][${subchapter[i]}]");
        int x = 0;
        List<dynamic> updatedres = list.map((item) {
          x++;
          return item + result[x - 1];
        }).toList();
        DatabaseWidget.of(context).prog_database.put(
            subchapter.length == 0
                ? "[$mainchapter][$chapter]"
                : "[$mainchapter][$chapter][${subchapter[i]}]",
            updatedres);
      } catch (e) {
        DatabaseWidget.of(context).prog_database.put(
            subchapter.length == 0
                ? "[$mainchapter][$chapter]"
                : "[$mainchapter][$chapter][${subchapter[i]}]",
            (result as List<dynamic>));
      }
      i++;
    }
  }

  read(mainchapter, chapter, subchapter) {
    try {
      List<dynamic> list = DatabaseWidget.of(context).prog_database.get(
          subchapter == null
              ? "[$mainchapter][$chapter]"
              : "[$mainchapter][$chapter][$subchapter]");
      return (list.fold(0, (var x, element) => element + x) /
          (list.length * 3));
    } catch (e) {
      return 0.0;
    }
  }
}

// TODO: Refactor Database to be provided by locator
class DatabaseWidget extends InheritedWidget {
  static const String SETTINGS_WELCOME_PAGE_KEY = 'welcomePage';
  static const String SETTINGS_CLASS_KEY = 'Klasse';
  static const String SETTINGS_COURSE_ORDER_KEY = 'courseOrdering';

  final Box settings_database;
  final Box prog_database;

  const DatabaseWidget({
    required this.settings_database,
    required this.prog_database,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static DatabaseWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DatabaseWidget>()!;
}
