import 'package:fuenfzigohm/custom_libs/database.dart';
import 'package:fuenfzigohm/learning_state/reset_learning_state.dart';
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

  Future<void> _confirmLearningStateReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Lernstand wirklich zurücksetzen?"),
        content: const Text(
          "Alle beantworteten Fragen und der gesamte Lernfortschritt werden "
          "dauerhaft gelöscht. Deine Kursauswahl und die übrigen "
          "Einstellungen bleiben erhalten.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Abbrechen"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("Lernstand löschen"),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await resetLearningState(
      repository: DatabaseWidget.of(context).learningStateRepository,
      legacyProgressBox: DatabaseWidget.of(context).prog_database,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Der Lernstand wurde zurückgesetzt.")),
    );
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
                  Navigator.of(context).pushNamed("/welcome");
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
          SettingsSection(
            margin: EdgeInsetsDirectional.all(8.0),
            title: Text(
              'Danger Zone',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            tiles: <SettingsTile>[
              SettingsTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  "Lernstand zurücksetzen",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                description: Text(
                  "Löscht alle beantworteten Fragen und den gesamten "
                  "Lernfortschritt.",
                ),
                onPressed: _confirmLearningStateReset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
