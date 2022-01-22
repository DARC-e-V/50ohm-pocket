import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:amateurfunktrainer/screens/settings.dart';
import 'package:amateurfunktrainer/widgets/loadcontent.dart';
import 'package:flutter/material.dart';

import 'formelsammlung.dart';


class Learningmodule extends StatefulWidget {
  @override
  createState() => _LearningmoduleState();
}

class _LearningmoduleState extends State<Learningmodule> {
  late List<Tab> tabs;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Afutrainer'),
          actions: [
            PopupMenuButton(itemBuilder: (context) => [
              PopupMenuItem(value: 1, child: Text("Formelsammlung")),
              PopupMenuItem(value: 0, child: Text("Einstellungen")),
            ],
              onSelected: (item) => SelectedItem(context, item!),
            ),
          ],
        ),//Color(0xff253478),),
        floatingActionButton: FloatingActionButton(
          onPressed: (){},
          child: const Icon(Icons.shuffle_rounded, size: 30,),
          backgroundColor: Colors.amber,
        ),
        body: DefaultTabController(
          length: 3,
          child: Scaffold(
            body: TabBarView(
              children: [
                DatabaseWidget.of(context).settings_database.get("klasse_a") != null
                    ? chapterbuilder(context, 'assets/questions/DL_Technik_Klasse_A_2007.json', 0)
                    : chapterbuilder(context, 'assets/questions/DL_Technik_Klasse_E_2007.json', 0),
                chapterbuilder(context, 'assets/questions/DL_Betriebstechnik_2007.json', 1),
                chapterbuilder(context, 'assets/questions/DL_Vorschriften_2007.json', 2)
              ],
            ),
            appBar:
            (DatabaseWidget.of(context).settings_database.get("betrieb_vorschriften") == null
            ? AppBar(
              title: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.settings_input_antenna), text: "Technik",),
                  Tab(icon: Icon(Icons.radio), text: "Betrieb",),
                  Tab(icon: Icon(Icons.book), text: "Vorschriften",)
                ],
              ),
            ): null
            ),
          ),
        )

    );
  }

  SelectedItem(BuildContext context, Object item) {
    switch(item){
      case 0:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Settingspage()));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Formularpage(1)));
        break;
    }
  }
}
