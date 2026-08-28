# 50Ohm pocket

Egal, ob du schon eine Lizenz hast oder gerade erst mit dem Lernen beginnst, mit unseren umfangreichen Ausbildungsangeboten auf Youtube, 50ohm.de und der App bereiten wir dich optimal auf die Amateurfunkprüfung vor. Die App ergänzt nahtlos die Ausbildungsinhalte von 50Ohm und erleichtert das Lernen unterwegs durch kurze Lektionen und schnelles Feedback. Die App wird ehrenamtlich entwickelt, hast du Lust deine Ideen einzubringen und die App noch besser zu machen? Dann melde dich unter app@darc.de.

# Mithelfen
Das Projekt wird derzeit von einem kleinen Entwicklerteam ehrenamtlich entwickelt. Wenn du Verbesserungsvorschläge hast oder einen Fehler gefunden hast, schreibe gerne ein Issue.  Wenn du die App aktiv mitgestalten möchtest, klon das Repository und bring 50Ohm voran. Wir freuen uns über Pull Requests. 

## Entwicklungsumgebung einrichten

Vorausgesetzt werden [VS Code](https://code.visualstudio.com/) mit der
Flutter-Erweiterung, [FVM](https://fvm.app/) sowie Xcode für Apple- oder Android
Studio für Android-Builds.

```bash
git clone https://github.com/DARC-e-V/50ohm-pocket.git
cd 50ohm-pocket
fvm install
fvm flutter pub get
code .
```

Falls VS Code das SDK nicht automatisch erkennt: `Flutter: Change SDK` öffnen
und `.fvm/flutter_sdk` auswählen. Danach ein Gerät starten oder anschließen und
die App aus VS Code oder mit `fvm flutter run` ausführen. Die Umgebung lässt sich
mit `fvm flutter doctor` prüfen.

Builds erzeugt man beispielsweise mit `fvm flutter build appbundle` für Android
oder `fvm flutter build ios` für iOS.

## Entwicklungsdokumentation

- [Fragen- und Kursdaten aktualisieren](docs/question-assets.md) (Das ist wichtig bei neuen Releases!)
- [Lernstand: Ereignisprotokoll und Migration](docs/learning-state.md)

## Update der Lizenzhinweise für verwendete Pakete

Die in der App unter „Über diese App“ angezeigten Paketlizenzen werden automatisch
aus den aktuellen Abhängigkeiten erzeugt:

`fvm dart run dart_pubspec_licenses:generate`

Die generierte Datei `lib/oss_licenses.dart` muss anschließend in den Commit
aufgenommen werden. Die Lizenztexte werden nicht von Hand gepflegt.

![portal](https://github.com/Konradrundfunk/50ohm-pocket/assets/33392939/7ddb8cbc-5c60-4c5d-8e59-6541ce410919)
