import 'package:fuenfzigohm/coustom_libs/database.dart';
import 'package:fuenfzigohm/main.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class Settingspage extends StatefulWidget {
  @override
  _settingsstate createState() => _settingsstate();
}

class _settingsstate extends State<Settingspage> {
  final List<MapEntry<String, double>> _fontScaleOptions = const [
    MapEntry("Sehr klein", 0.8),
    MapEntry("Klein", 0.9),
    MapEntry("Standard", 1.0),
    MapEntry("Groß", 1.15),
    MapEntry("Sehr groß", 1.3),
  ];

  @override
  void initState() {
    super.initState();
  }

  String _fontScaleLabel(double fontScale) {
    for (final option in _fontScaleOptions) {
      if (option.value == fontScale) {
        return option.key;
      }
    }

    return "Standard";
  }

  Future<void> _showFontSizeDialog(
    BuildContext context,
    AppSettingsScope appSettings,
  ) async {
    double selectedFontScale = appSettings.fontScale;

    final newFontScale = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Schriftgröße"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _fontScaleOptions.map((option) {
                  return RadioListTile<double>(
                    title: Text(option.key),
                    value: option.value,
                    groupValue: selectedFontScale,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setDialogState(() {
                        selectedFontScale = value;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Abbrechen"),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(selectedFontScale),
                  child: const Text("Speichern"),
                ),
              ],
            );
          },
        );
      },
    );

    if (newFontScale != null) {
      appSettings.onFontScaleChanged(newFontScale);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool courseOrdering =
        DatabaseWidget.of(context).settings_database.get("courseOrdering") ??
            true;
    final appSettings = AppSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
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
                title: Text("Schriftgröße"),
                value: Text(_fontScaleLabel(appSettings.fontScale)),
                description: Text("Passe die Schriftgröße der App an."),
                trailing: Icon(Icons.keyboard_arrow_right),
                onPressed: (BuildContext context) {
                  _showFontSizeDialog(context, appSettings);
                },
              ),
              SettingsTile.navigation(
                title: Text("Zu trainierende Fragen"),
                description: Text(
                  "Wähle hier die Fragen aus die du lernen möchtest. Wenn du bereits eine Prüfung abgelegt hast, kannst du hier einzelne Teile abwählen.",
                ),
                trailing: Icon(Icons.keyboard_arrow_right),
                onPressed: (BuildContext context) {
                  DatabaseWidget.of(
                    context,
                  ).settings_database.delete("welcomePage");
                  Navigator.of(context).popAndPushNamed("/welcome");
                },
              ),
              SettingsTile.switchTile(
                initialValue: courseOrdering,
                onToggle: (bool value) {
                  setState(() {
                    courseOrdering = value;
                  });
                  DatabaseWidget.of(
                    context,
                  ).settings_database.put("courseOrdering", value);
                },
                title: Text("Ausbildungsmaterial nach 50Ohm.de"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
