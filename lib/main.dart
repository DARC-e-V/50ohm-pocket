import 'package:amateurfunktrainer/screens/formelsammlung.dart';
import 'package:amateurfunktrainer/screens/settings.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'widgets/loadcontent.dart';
import 'widgets/navbar.dart';


void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColorLight: Color(0xFFE1E6FF),
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        textTheme: TextTheme(
          headline5: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,)
        )
      ),
      darkTheme: ThemeData(
        primaryColorDark: Color(0xFF1C1F44),
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        cardColor: main_col,
      ),
      themeMode: ThemeMode.dark,
      title: 'Afutrainer',
      initialRoute: "/",
      routes: {
        "/" : (context) => Learningmodule(),
        "/examsimulator" : (context) => Scaffold(body: Text("Prüfungsimulation"),),
        "/profile" : (context) => Scaffold(body: Text("Profil"),),
      },
    ),
  );
}

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
      body: Container(
        child: futurebuilder(context)
      ),
      bottomNavigationBar: Bottomnavbar()
    );
  }

  SelectedItem(BuildContext context, Object item) {
    switch(item){
      case 0:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Settingspage()));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Formularypage()));
        break;
    }
  }
}
