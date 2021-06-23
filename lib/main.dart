import 'package:amateurfunktrainer/screens/formelsammlung.dart';
import 'package:amateurfunktrainer/screens/settings.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'widgets/futurebuilder.dart';
import 'widgets/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
      home: Afutrainer(),
    ),
  );
}
//Todo: implement a start screen to guide the user
/*
startapp(){
  // Afutrainer();
  return FutureBuilder(
      future: welcome(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
        if(snapshot.hasData){
          print("sucsess");
        }else if(snapshot.hasError){
          print("error");
        }
        print("error");
      }
  );
}
*/


welcome() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if((prefs.getInt('welcome') ?? false) == false){
    print("Hallo");
  }else{
    print("hallo schon wieder");
  }
}


class Afutrainer extends StatefulWidget {
  @override
  createState() => _AfutrainerState();
}

class _AfutrainerState extends State<Afutrainer> {

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
      bottomNavigationBar: bottomnavbar()
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
