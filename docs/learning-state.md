# Lernstand: Ereignisprotokoll und Migration

Die einmalige Migration des alten positionsbasierten Lernstands verwendet
`assets/questions/legacy_v1.json`. Dieser eingefrorene Schnappschuss entkoppelt
die Migration von späteren Änderungen an Kapiteln und Abschnitten. Erst nach
dem Start und der Migration lädt die Oberfläche die aktuellen Kursdateien.

## Ziel

Der Lernstand wird anhand der stabilen Fragenummer gespeichert, zum Beispiel
`NA102`. Kapitel-, Unterkapitel- und Listenpositionen gehören nicht mehr zum
Schlüssel. Dadurch bleibt der Stand erhalten, wenn Fragen umsortiert werden
oder dieselbe Frage in einem anderen Kurs beziehungsweise im Gesamtkatalog
angezeigt wird.

Upgrade-Kurse zeigen sowohl im geführten Kurs als auch in der Ansicht „Lernen
nach Katalog“ ausschließlich den neu zu lernenden Anteil. Da die zusätzlichen
E- und A-Fragen im aktuellen Katalog nur technische Kenntnisse betreffen,
entfällt dort die Navigation zu leeren Vorschrifts- und Betriebsseiten.

Jede beantwortete Frage erzeugt in der Hive-Box `learning_events_v1` ein
unveränderliches Ereignis mit:

- einer eindeutigen Ereignis-ID,
- der stabilen Fragenummer,
- Antwort- und Speicherzeitpunkt in UTC,
- richtig/falsch und der gewählten Antwort,
- Katalogversion, Geräte-ID und Herkunft.

Der aktuell sichtbare Lernstand ist eine Projektion dieses Protokolls. Wie
bisher zählt jede richtige Antwort einen Punkt. Ab drei Punkten gilt eine
Frage als gelernt. Eine noch nie beantwortete Frage ist „Offen“. Nach der
ersten richtigen oder falschen Antwort gilt sie bis zum Erreichen von drei
Punkten als „In Arbeit“. Falsche Antworten werden protokolliert, verändern die
Punktzahl aber nicht.

Dieses Modell erlaubt später andere Lernalgorithmen, Statistiken und das
Zusammenführen mehrerer Geräte, ohne die Rohhistorie zu verlieren.

## Üben

Die offene Übungsrunde verwendet ausschließlich Fragen des ausgewählten
Lernwegs, die bereits mindestens einmal beantwortet wurden. Dazu zählen auch
Fragen, die bisher nur falsch beantwortet wurden und deshalb noch null Punkte
haben. Solange Fragen mit weniger als drei Punkten vorhanden sind, stammen vier
von fünf Auswahlen aus diesem Bereich „In Arbeit“. Jede fünfte Auswahl
wiederholt eine bereits gelernte Frage.

Sind alle gesehenen Fragen gelernt, läuft die Runde ausschließlich mit
Wiederholungen weiter. Sie hat keine feste Länge und kann jederzeit beendet
werden. Jede Antwort wird wie im normalen Kurs unmittelbar als Ereignis
gespeichert.

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
- den Wechsel N → E → N und die Darstellung im Gesamtkatalog,
- die Auswahl von Fragen für eine offene Übungsrunde.
