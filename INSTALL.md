# Die Buildumgebung installieren und die App selbst bauen.

Unsere Anwendung wird mit `flutter` gebaut. Wenn du die Anwendung
bauen willst, kannst du das tun, nachdem du `flutter` installiert
hast. Wie das geht, liest du in der `flutter`
[Installationsanleitung](https://docs.flutter.dev/get-started/install).

Übrigens wird dort eine Vierkernmaschine verlangt. Meine hat nur zwei
Kerne und kann die Anwendung auch bauen - ist dann halt nur etwas
langsamer.

Dort wird weiter verlangt, Android Studio zu installieren.

Auf Linux benötigt die Installation von Android Studio einige 32-bit
Libraries, die auch installiert werden müssen. Um die auf einem
üblichen 64-bit System installieren zu können, werden unter
Debian-basierten Linuxsystemen zuerst diese beiden Befehle gebraucht:

```
dpkg --add-architecture i386
apt-get update
```

Es genügt nicht, Android Studio einfach nur zu installieren. Es muss
auch einmal aufgerufen werden, was dann zu einer weiteren
Installationsorgie führt.

Es muss weiter ein Signaturschlüssel generiert werden, mit dem die App
später unterschrieben wird. Ohne Unterschrift kann sie nicht gebaut
werden. Die Signaturschlüsselerstellung geht mit Android Studio. Wie?
Steht
https://developer.android.com/studio/publish/app-signing.html#generate-key
, gebraucht wird nur der Abschnitt "generate and upload key and
keystore". In allen vier Passwortfeldern dasselbe Passwort
eingetragen.

Anschließend stellst du dem Build diesen Key zur Verfügung, damit der
Build mit diesem Schlüssel unterschreiben kann.  Dazu erzeugst du eine
Datei `android/key.properties` hier im Projektverzeichnis, _die du
niemals in `git` eincheckst_ und die so ungefähr folgenden Inhalt hat:

```
keyAlias=mein-doller-key
storeFile=/home/ich/.android/mein-app-signing-keystore.jks
keyPassword=geheim
storePassword=geheim
```

* Die erste Zeile hat den Alias, den du in Android Studio für Deinen
Schlüssel vergeben hast.
* Die zweite Zeile hat den vollständigen Pfad der keystore-Datei.
* Die dritte und vierte Zeile haben das Password, das du in Android
Studio vergeben hast.

Wenn soweit alles erledigt ist, rufst du auf

```
flutter doctor
```

Da erfährst du, dass immer noch nicht genug installiert
ist. Namentlich wird der `sdkmanager` empfohlen.  Siehe [seine
Beschreibung](https://developer.android.com/tools/sdkmanager), wo auch
steht, wie der nun wieder installiert werden kann. Aber: Anders als
diese Beschreibung suggeriert, scheint es nicht egal zu sein, wo der
installiert wird. Der Ort, an dem Flutter ihn sucht, ist zu erfahren
durch

```
flutter doctor --verbose
```

Auf Debian-Linux-Systemen scheint das richtige Verzeichnis zu sein:

`$HOME/Android/Sdk/cmdline-tools/latest`

Ich habe das so gemacht:

* ZIP auspacken, es entsteht ein Verzeichnis `cmdline-tools`,
* das umbenennen in `latest`,
* ein neues, leeres Verzeichnis `cmdline-tools` erstellen und
* das `latest`-Verzeichnis dort hinein verschíeben.

Dann nochmal `flutter doctor` und etwaige Instruktionen ausführen, bis
alles so weit passt.

Wenn das endlich so weit ist, kannst du nun aufrufen

```
flutter build apk
```

Wenn du schon mal für andere Zwecke `gradle` benutzt hast, gibt es ein
Verzeichnis `$HOME/.gradle`, in dem eine Kotlin-Version vielleicht
Spuren hinterlassen. Wenn das eine andere Kotlin-Version ist als die,
die hier benutzt werden soll, zeigt sich das an Fehlermeldungen dieser
Art:

> .../.gradle/caches/...: Module was compiled with an incompatible
> version of Kotlin. The binary version of its metadata is 1.8.0,
> expected version is 1.6.0.

Wenn das auftritt, einfach beherzt das gesamte Verzeichnis
`$HOME/.gradle` löschen und es nochmal versuchen.

Wenn nun eine Datei `build/app/outputs/flutter-apk/app-release.apk`
entstanden ist, ist der Build erfolgreich durchgelaufen.

Um diese Datei tatsächlich zu installieren, zunächst auf dem Rechner
die `adb`-Software installieren.  Auf Linux-Systemen, die von Debian
abstammen:

```
sudo apt install adb android-sdk-platform-tools-common
```

Außerdem überprüfen, ob der eigene User in der Gruppe `plugdev`
vorhanden ist. Das überprüfst du mit dem Befehl `id`, in dessen Output
`plugdev` auftauchen sollte, dann ist das in Ordnung. Wenn nicht,
hilft

```
sudo gpasswd --add USER plugdev
```

wobei du statt `USER` Deinen Linux-Usernamen einsetzt.

Nach der Installation von `android-sdk-platform-tools-common` und
ggf. der Gruppenänderung **den Rechner neu booten.** Sorry.

Anschließend

* auf dem Handy die [Entwickleroptionen freischalten](https://www.heise.de/tipps-tricks/Android-Entwickleroptionen-aktivieren-deaktivieren-4041510.html),
* das Handy über USB mit dem Rechner verbinden,
* mit `adb shell` schauen, ob die Verbindung funktioniert, dazu muss
auf dem Handy der Zugriff vom Rechner aus genehmigt werden
* dann mit `adb install build/app/outputs/flutter-apk/app-release.apk`
die App installieren.

Wenn die "offizielle" Version der App aus dem Playstore vorher
installiert war, kann es sein, dass das nicht funktioniert. Denn das
Smartphone könnte misstrauisch werden, wenn die App jetzt von einem
anderen Schlüssel unterschrieben ist als vorher. Wenn das auftritt,
die App über die Einstellungen zuerst de-installieren.
