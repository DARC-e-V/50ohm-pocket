# Fragen- und Kursdaten aktualisieren

Die geführten Kurse werden ab sofort aus drei Quellen erzeugt:

- `https://50ohm.de/assets/question_index.json` liefert Editions- und
  Section-Zuordnung sowie vorhandene Lösungswege.
- `https://50ohm.de/assets/toc/*.json` legt Kapitel- und Section-Reihenfolge
  fest und liefert die Links zu den Lernvideos von DL2YMR.
- Die mit der App ausgelieferte `assets/questions/Questions.json` liefert
  Fragetexte, Antworten und Bilder.

## Bedeutung der Editionen

Editionen sind konkrete Lernwege und dürfen nicht allein aus Prüfungsklassen
abgeleitet werden:

| Edition | Enthaltene Fragen |
| --- | --- |
| `N` | Betrieb, Vorschriften und Technik N |
| `NE` | Betrieb, Vorschriften sowie Technik N und E |
| `NEA` | Betrieb, Vorschriften sowie Technik N, E und A |
| `E` | nur Technik E |
| `EA` | nur Technik E und A |
| `A` | nur Technik A |
Die Liste `editions` im Fragenindex ist die maßgebliche Information, in welchen
Lernwegen eine Frage vorkommt.

Die SWL-Edition ist derzeit ausdrücklich nicht Bestandteil der App. Für die
sechs regulären Lernwege verwenden gemeinsame Fragen dieselbe Section. Außerdem
wird der Index nach Frage-ID sortiert und enthält daher keine Kapitel- oder
Section-Reihenfolge.  Dafür werden die veröffentlichten TOCs verwendet. Der
Index bleibt die maßgebliche Quelle für die Zuordnung einer Frage. Die
Video-URL einer Section verweist bereits auf den passenden Zeitstempel im
zugehörigen Lernvideo. Fehlt sie, verwendet der Generator ersatzweise die
Video-URL des übergeordneten Kapitels.

Vom Repository-Wurzelverzeichnis aus aktualisieren:

```sh
.fvm/flutter_sdk/bin/dart tool/update_question_assets.dart
```

Das Skript benötigt keine lokalen Nachbar-Repositories und zieht sich den
aktuellen Index von 50ohm.de. Es schreibt erst dann Dateien, wenn Index,
sämtliche TOCs und alle sechs Lernwege vollständig geprüft wurden. Fehlende,
unbekannte oder doppelte Frage-IDs sowie ungültige oder widersprüchliche
Video-Zuordnungen führen zum Abbruch. Es aktualisiert die sechs Kursdateien,
`assets/questions/solutions.json` und `assets/questions/videos.json`.

Die App lädt diese Daten nicht selbstständig. Aktualisierungen werden geprüft,
gemeinsam mit einem App-Release ausgeliefert und funktionieren anschließend
vollständig offline.

## Alte Lernstände

`assets/questions/legacy_v1.json` ist ein unveränderlicher Schnappschuss der
alten positionsbasierten Struktur. Die Migration liest ausschließlich diesen
Schnappschuss und schreibt Ereignisse mit stabilen Frage-IDs. Deshalb darf die
Datei beim späteren Aktualisieren der Kapitel nicht neu erzeugt oder ersetzt
werden.
