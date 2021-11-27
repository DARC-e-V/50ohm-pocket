import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class Settingspage extends StatefulWidget{
  @override
  _settingsstate createState() => _settingsstate();
}

class _settingsstate extends State<Settingspage> {
  var a_boolean = false;
  var tec_only_boolean = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Allgemeine Einstellungen',
            tiles: [
              SettingsTile.switchTile(
                title: 'Nur Technik',
                leading: Icon(Icons.four_g_mobiledata),
                switchValue: tec_only_boolean,
                onToggle: (bool value) {setState(() {
                  tec_only_boolean = value;
                });},
              ),
              SettingsTile.switchTile(
                title: 'Klasse A',
                leading: Icon(Icons.assistant_photo),
                switchValue: a_boolean,
                onToggle: (bool value) {setState(() {
                  a_boolean = value;
                });},
              ),
            ],
          ),
        ],
      )
      ,
    );
  }
}
