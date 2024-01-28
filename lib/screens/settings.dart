import 'package:fuenfzigohm/coustom_libs/database.dart';
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
    bool courseOrdering = DatabaseWidget.of(context).settings_database.get("courseOrdering") ?? true;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: (){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/learn");
          },
        ), 
        title: Text("Einstellungen"),

      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            margin: EdgeInsetsDirectional.all(8.0),
            title: Text('Einstellungen zu Fragen'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: Text("Zu trainierende Fragen"),
                description: Text("Wähle hier die Fragen aus die du lernen möchtest. Wenn du bereits eine Prüfung abgelegt hast, kannst du hier einzelne Teile abwählen."),
                trailing: Icon(Icons.keyboard_arrow_right), 
                onPressed: (BuildContext context){
                  DatabaseWidget.of(context).settings_database.delete("welcomePage");
                  Navigator.of(context).popAndPushNamed("/welcome");
                },
              ),
              SettingsTile.switchTile(
                initialValue: courseOrdering,
                onToggle: (bool value){
                  setState(() {
                    courseOrdering = value;
                  });
                  DatabaseWidget.of(context).settings_database.put("courseOrdering", value);
                },
                title: Text("Ausbildungsmaterial nach 50Ohm.de")
                ),
            ],
          ),
          SettingsSection(
              margin: EdgeInsetsDirectional.all(8.0),
              title: Text("Lizenzinformationen zur App und ihrer Inhalte"),
              tiles: <SettingsTile>[

                SettingsTile(
                  title: Text("Lizenzen der verwendeten Bibliotheken"),
                  description: Text("Dies ist eine automatisch generierte Auflistung aller verwendeter externer Komponenten zur Bereitstellung dieser App."),
                  leading: Icon(Icons.library_books),
                  onPressed: (BuildContext context){
                    Navigator.of(context).pushNamed("/appPackages");
                  },
                ),
                SettingsTile(
                  title: Text("Lizenzhinweis zu den Prüfungsfragen"),
                  description: Text("Die Prüfungsfragen wurden vom DARC im Auftrag der Bundesnetzagentur erstellt."),
                  leading: Icon(Icons.library_books),
                  onPressed: (BuildContext context){
                    Navigator.of(context).pushNamed("/questionsLicenseNotice");
                  },
                ),
              ]
          ),
        ],
      ),
    );
  }

}
