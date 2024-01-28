import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  launch("https://github.com/DARC-e-V/50ohm-pocket");
                },
              ),
              SettingsTile(
                title: Text("Ehrenamtliches Team des DARC e.V. \n \n Mit besonderen Dank an \n Konrad Gralher, DK7ON \n Felix Pfannkuch, DO6FP"),
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
                  launch("mailto:app@darc.de?subject=App%20DARC&body=Hallo%20ehrenamtliches%20App-Team,%0D%0A%0D%0A");
                },
              ),
              SettingsTile(
                title: Text("app.darc.de"),
                leading: Icon(Icons.web),
                onPressed: (BuildContext context){
                  launch("https://app.darc.de");
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
                    launch("https://app.darc.de/privacy_50ohm.html");
                  },
                ),
                SettingsTile(
                  title: Text("Impressum"),
                  leading: Icon(Icons.menu_book),
                  onPressed: (BuildContext context){
                    launch("https://www.darc.de/impressum/");
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