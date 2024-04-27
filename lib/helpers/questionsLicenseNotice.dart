import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:settings_ui/settings_ui.dart';

class QuestionsLicensePage extends StatelessWidget {
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lizenzhinweise'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text(''),
            tiles: [
              SettingsTile(
                title: Text('Bundesnetzagentur,\n 2. Auflage, Dezember 2023 \n'),
                description: GestureDetector(
                  onTap: () => _launchURL('https://www.bundesnetzagentur.de/amateurfunk'),
                  child: Text('www.bundesnetzagentur.de/amateurfunk \n \n Prüfungsfragen zum Erwerb von Amateurfunkprüfungsbescheinigungen \n \n Änderungen: HTML Tags wurden aus den Fragen entfernt', style: TextStyle(fontStyle: FontStyle.italic)),
                ),
              ),
              SettingsTile(
                title: Text(""),
                description: GestureDetector(
                  onTap: () => _launchURL('https://www.govdata.de/dl-de/by-2-0'),
                  child: Text('Datenlizenz Deutschland – Namensnennung – Version 2.0 \n www.govdata.de/dl-de/by-2-0'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
