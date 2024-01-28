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
        title: Text('Amateurfunkprüfungsbescheinigungen'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Prüfungsfragen zum Erwerb von Amateurfunkprüfungsbescheinigungen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            tiles: [
              SettingsTile(
                title: Text('Bundesnetzagentur, 2. Auflage, Dezember 2023', style: TextStyle(fontSize: 16)),
                description: GestureDetector(
                  onTap: () => _launchURL('https://www.bundesnetzagentur.de/amateurfunk'),
                  child: Text(
                    'www.bundesnetzagentur.de/amateurfunk',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Datenlizenz Deutschland – Namensnennung – Version 2.0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            tiles: [
              SettingsTile(
                title: Text(""),
                description: GestureDetector(
                  onTap: () => _launchURL('https://www.govdata.de/dl-de/by-2-0'),
                  child: Text(
                    'www.govdata.de/dl-de/by-2-0',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
