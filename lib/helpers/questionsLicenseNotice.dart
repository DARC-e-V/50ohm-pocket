import 'package:flutter/material.dart';
import 'package:fuenfzigohm/custom_libs/url_launcher.dart';
import 'package:settings_ui/settings_ui.dart';

class QuestionsLicensePage extends StatelessWidget {

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
                title: Text('Bundesnetzagentur,\n3. Auflage, März 2024\n'),
                description: Semantics(
                  link: true,
                  label: "Bundesnetzagentur-Website zum Amateurfunk öffnen",
                  child: GestureDetector(
                    onTap: () => launchURL('https://www.bundesnetzagentur.de/amateurfunk'),
                    child: Text('www.bundesnetzagentur.de/amateurfunk\n\nPrüfungsfragen zum Erwerb von Amateurfunkprüfungsbescheinigungen\n\nÄnderungen: HTML Tags wurden aus den Fragen entfernt, kleine Fehler korrigiert', style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ),
              ),
              SettingsTile(
                title: Text(""),
                description: Semantics(
                  link: true,
                  label: "Datenlizenz Deutschland – Namensnennung – Version 2.0 öffnen",
                  child: GestureDetector(
                    onTap: () => launchURL('https://www.govdata.de/dl-de/by-2-0'),
                    child: Text('Datenlizenz Deutschland – Namensnennung – Version 2.0 \n www.govdata.de/dl-de/by-2-0'),
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
