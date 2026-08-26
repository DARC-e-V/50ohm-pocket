# Lernstand: Ereignisprotokoll und Migration

## Ziel

Der Lernstand wird anhand der stabilen Fragenummer gespeichert, zum Beispiel
`NA102`. Kapitel-, Unterkapitel- und Listenpositionen gehören nicht mehr zum
Schlüssel. Dadurch bleibt der Stand erhalten, wenn Fragen umsortiert werden
oder dieselbe Frage in einem anderen Kurs beziehungsweise im Gesamtkatalog
angezeigt wird.

Upgrade-Kurse zeigen im geführten Kurs nur den neu zu lernenden Anteil. Die
Ansicht „Lernen nach Katalog“ zeigt dagegen den vollständigen Katalog der
Zielklasse: N→E wird dort als N+E und jedes Upgrade auf A als N+E+A gefiltert.

Jede beantwortete Frage erzeugt in der Hive-Box `learning_events_v1` ein
unveränderliches Ereignis mit:

- einer eindeutigen Ereignis-ID,
- der stabilen Fragenummer,
- Antwort- und Speicherzeitpunkt in UTC,
- richtig/falsch und der gewählten Antwort,
- Katalogversion, Geräte-ID und Herkunft.

Der aktuell sichtbare Lernstand ist eine Projektion dieses Protokolls. Wie
bisher zählt jede richtige Antwort einen Punkt. Ab drei Punkten gilt eine
Frage als gelernt; falsche Antworten werden protokolliert, verändern diese
bisherige Wertungsregel aber noch nicht.

Dieses Modell erlaubt später andere Lernalgorithmen, Statistiken und das
Zusammenführen mehrerer Geräte, ohne die Rohhistorie zu verlieren.

## Einmalige Migration

Beim ersten App-Start mit diesem Stand wird die alte, positionsbasierte
Hive-Box `progress` gelesen. Die damals aktiven Klassen aus der Einstellung
`Klasse` bestimmen, mit welchem Kurskatalog die Positionen interpretiert
werden. Das ist nötig, weil die alten Schlüssel den Kurs selbst nicht
enthalten und deshalb mehrdeutig sein können.

Jeder alte richtige Punkt wird in ein deterministisches
`legacyMigration`-Ereignis für die ermittelte Fragenummer übersetzt. Für diese
synthetischen Ereignisse ist der ursprüngliche Antwortzeitpunkt unbekannt und
daher `null`. Nicht eindeutig auflösbare Positionen werden gezählt, aber nicht
geraten.

Die Migration ist wiederholbar:

- Ein Marker `learningStateMigrationV1` verhindert einen zweiten Lauf.
- Deterministische Ereignis-IDs verhindern Duplikate auch nach einem
  unterbrochenen Lauf.
- Die alte `progress`-Box wird nicht gelöscht und bleibt als Rückfall- und
  Diagnosequelle erhalten.

Über „Einstellungen → Danger Zone → Lernstand zurücksetzen“ können das neue
Ereignisprotokoll und die alte `progress`-Box nach einer zusätzlichen
Bestätigung vollständig gelöscht werden. Kursauswahl, Geräte-ID und
Migrationsmarker bleiben bestehen; dadurch werden gelöschte Altdaten nicht
erneut importiert.

## Abgedeckte Szenarien

Automatisierte Tests prüfen:

- richtige und falsche Antwortereignisse sowie den daraus berechneten Stand,
- die Schwelle von drei richtigen Antworten,
- die Migration für N, N→E, N→E→A, E, A und E→A,
- den vom Nutzer bestätigten Rückschluss über den aktuell gewählten Kurs,
- die Idempotenz der Migration,
- den Wechsel N → E → N und die Darstellung im Gesamtkatalog.

## Spätere Erweiterungen

Noch nicht Teil dieser Änderung sind:

1. das Aktualisieren von Reihenfolge und Kapiteln aus den 50ohm.de-Konfigs,
2. eine Probeprüfung nach dem Algorithmus von 50ohm.de,
3. ein Menü „Lernen“ mit 25 Fragen, überwiegend aus „In Arbeit“ und mit
   gelegentlichen Wiederholungen gelernter Fragen.

Das Ereignisprotokoll liefert dafür eine stabile Grundlage. Vor einer echten
Gerätesynchronisation müssen noch Konfliktregeln, Katalogversionierung,
Datenschutz und Log-Kompaktierung festgelegt werden.
