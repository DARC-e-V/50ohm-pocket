import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class AboutAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Über die App'),
        leading: BackButton(
          onPressed: (){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/learn");
          },
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            margin: EdgeInsetsDirectional.all(8.0),
            title: Text('Entwickelt mit ❤'),
            tiles: [
              SettingsTile(
                title: Text("Version: #TODO"),
                leading: Icon(Icons.info),
              ),
              SettingsTile(
                title: Text("Quellcode"),
                leading: Icon(Icons.code),
                onPressed: (BuildContext context){
                  Navigator.of(context).pushNamed("/sourceCode");
                },
              ),
              SettingsTile(
                title: Text("Ehrenamtliches Team des DARC e.V. \n \n Mit besonderen Dank an \n Konrad Gralher, DK7ON"),
                leading: Icon(Icons.flutter_dash),
              ),
            ],
          ),
          SettingsSection(
            margin: EdgeInsetsDirectional.all(8.0),
            title: Text("Kontakt"),
            tiles: [
              SettingsTile(
                title: Text("app@darc.de"),
                leading: Icon(Icons.email),
                onPressed: (BuildContext context){
                  Navigator.of(context).pushNamed("/mail");
                },
              ),
              SettingsTile(
                title: Text("app.darc.de"),
                leading: Icon(Icons.web),
                onPressed: (BuildContext context){
                  Navigator.of(context).pushNamed("/website");
                },
              ),
            ],
          ),
          SettingsSection(
              margin: EdgeInsetsDirectional.all(8.0),
              title: Text("Rechtliches"),
              tiles: <SettingsTile>[
                SettingsTile(
                  title: Text("Datenschutzerklärung"),
                  leading: Icon(Icons.policy),
                  onPressed: (BuildContext context){
                    Navigator.of(context).pushNamed("/privacyPolicy");
                  },
                ),
                SettingsTile(
                  title: Text("Impressum"),
                  leading: Icon(Icons.menu_book),
                  onPressed: (BuildContext context){
                    Navigator.of(context).pushNamed("/imprint");
                  },
                ),
              ]
          ),
          SettingsSection(
              margin: EdgeInsetsDirectional.all(8.0),
              title: Text("Lizenzhinweise"),
              tiles: <SettingsTile>[
                SettingsTile(
                  title: Text("Lizenzen der verwendeten Bibliotheken"),
                  leading: Icon(Icons.attribution),
                  onPressed: (BuildContext context){
                    Navigator.of(context).pushNamed("/appPackages");
                  },
                ),
                SettingsTile(
                  title: Text("Lizenzhinweis zu den Prüfungsfragen"),
                  description: Text("Die Prüfungsfragen wurden vom DARC im Auftrag der Bundesnetzagentur erstellt."),
                  leading: Icon(Icons.assignment),
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