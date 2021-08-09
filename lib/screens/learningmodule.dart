import 'package:amateurfunktrainer/screens/settings.dart';
import 'package:amateurfunktrainer/widgets/loadcontent.dart';
import 'package:amateurfunktrainer/widgets/navbar.dart';
import 'package:flutter/material.dart';

import 'formelsammlung.dart';


class Learningmodule extends StatefulWidget {
  @override
  createState() => _LearningmoduleState();
}

class _LearningmoduleState extends State<Learningmodule> {

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
                futurebuilder(context, 'assets/questions/DL_Technik_Klasse_E_2007.json', 0),
                futurebuilder(context, 'assets/questions/DL_Betriebstechnik_2007.json', 1),
                futurebuilder(context, 'assets/questions/DL_Vorschriften_2007.json', 2)
              ],
            ),
            appBar: AppBar(
              title: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.settings_input_antenna), text: "Technik",),
                  Tab(icon: Icon(Icons.radio), text: "Betrieb",),
                  Tab(icon: Icon(Icons.book), text: "Vorschriften",)
                ],
              ),
            ),
          ),
        )

    );
  }

  SelectedItem(BuildContext context, Object item) {
    switch(item){
      case 0:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Settingspage()));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Formularpage()));
        break;
    }
  }
}
