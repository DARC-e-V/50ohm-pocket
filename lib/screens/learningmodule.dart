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
            body: PageView.builder(
              itemBuilder: (content, index){
                if(index == 0){
                  return chapterbuilder(context, 'assets/questions/Questions.json', 0);
                }else if(index == 1){
                  return chapterbuilder(context, 'assets/questions/Questions.json', 1);
                }else{
                  return chapterbuilder(context, 'assets/questions/Questions.json', 2);
                }
              },
              itemCount: 3,
              )
            ),
          ),
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
