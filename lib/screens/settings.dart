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
  void initState() {
    super.initState();
  }

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
            title: Text('Einstellungen zu Fragen'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: Text("Zu trainierende Fragen"),
                description: Text("Wähle hier die Fragen aus die du lernen möchtest. Wenn du bereits eine Prüfung abgelegt hast kannst du hier einzelne Teile abwählen."),
                trailing: Icon(Icons.keyboard_arrow_right), 
                onPressed: (BuildContext context){
                  DatabaseWidget.of(context).settings_database.delete("welcomePage");
                  Navigator.of(context).popAndPushNamed("/welcome");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

}
