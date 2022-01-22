import 'package:amateurfunktrainer/coustom_libs/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class Settingspage extends StatefulWidget{
  @override
  _settingsstate createState() => _settingsstate();
}

class _settingsstate extends State<Settingspage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Row(
          children: [
            IconButton(
                onPressed: (){
                  Navigator.of(context).popAndPushNamed("/");
                },
                icon: const Icon(Icons.arrow_back_rounded)
            ),
            SizedBox(width: 5,),
            Text("Einstellungen"),
          ],
        ),

      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            margin: EdgeInsetsDirectional.all(8.0),
            title: Text('Lerneinstellungen'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {
                  print(value);
                  DatabaseWidget.of(context).settings_database.put("klasse_a", value);
                  setState(() {});
                },
                initialValue: DatabaseWidget.of(context).settings_database.get("klasse_a") as bool,
                leading: Icon(Icons.school_sharp),
                title: Text('Klasse A'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  print(value);
                  DatabaseWidget.of(context).settings_database.put("betrieb_vorschriften", value);
                  setState(() {});
                },
                initialValue: DatabaseWidget.of(context).settings_database.get("betrieb_vorschriften") as bool,
                leading: Icon(Icons.radio),
                title: Text('Betriebstechnik und Vorschriften verstecken'),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
