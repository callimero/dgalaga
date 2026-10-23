# Pico Deluxe (PICO-8)

Ein Shooter nach dem Vorbild von **[Deluxe Galaga](https://deluxegalaga.com/index.html)**
von Edgar M. Vigdal (1958–2015), für die Fantasy-Konsole
[PICO-8](https://www.lexaloffle.com/pico-8.php) – noch ganz am Anfang.

Diesmal schreibe ich den Code selbst, um mein eingerostetes Lua und PICO-8
aufzufrischen. Claude hilft mit Antworten auf konkrete Fragen.

**[▶ Im Browser spielen](https://callimero.github.io/dgalaga/)**

![Pico Deluxe](dgalaga.p8.png)

## Woher – Deluxe Galaga

*Deluxe Galaga* ist ein Shareware-Shoot'em-up für den **Commodore Amiga** aus
den 1990er-Jahren, geschrieben von dem Norweger **Edgar M. Vigdal**. Es nimmt
die Idee des Arcade-Klassikers *Galaga* (Namco, 1981) – Feinde fliegen in
Formation ein und stürzen sich einzeln drehend herab – und macht daraus
deutlich mehr: Extras und Waffen zum Kaufen, viele Level, Bosse,
Meteoritenstürme. Verbreitet wurde es unter anderem über die Cover-Disks
von Zeitschriften; in der Liste „Top 100 Amiga Games of All Time“ steht es
auf Platz 19.

Um 1999 wandte sich Vigdal anderen Projekten zu, etwa *Warblade* für PC und
später iOS, einer Weiterentwicklung derselben Idee. Edgar M. Vigdal starb 2015.

## Legacy

Sein Spiel lebt weiter: Shane R. Monroe betreut seit 1999 als offizieller
„Custodian“ die Seite [deluxegalaga.com](https://deluxegalaga.com/index.html)
und hält das Spiel verfügbar. Dort gibt es inzwischen auch *Deluxe Galaga
Enhanced*, eine Neuübersetzung des originalen Assembler-Codes nach C für
Windows, Mac, Linux und den Browser – mit einem Modus, der exakt dem Original
entspricht, und einem mit Erweiterungen wie Breitbild.

**Pico Deluxe** ist eine kleine Verbeugung davor: kein Nachbau, sondern der
Versuch, das Gefühl von Formation, Sturzflug und Sternfeld in die engen
Grenzen von PICO-8 (128 × 128 Pixel, 16 Farben, 6 Tasten) zu bringen – und
dabei Lua wieder zu lernen. Wer das echte Spiel erleben will: auf
[deluxegalaga.com](https://deluxegalaga.com/index.html) gibt es es.

## Stand

- Titel, Spiel als Zustände über `_update60=funktion`
- Sternfeld mit 100 Sternen in verschiedenen Tiefen (Tempo und Helligkeit),
  dunkles Grau aus der geheimen Palette
- Schiff mit Neigung beim Lenken, Schüsse
- Feinde als Platzhalter (Formation folgt)

## Geplant

- Feind-Formation, Einflug, Sturzflug-Angriffe mit Drehung
- Level und Übergänge
- Meteoritensturm

## Steuerung

| Taste | Funktion |
|---|---|
| ⬅️ ➡️ | fliegen |
| ❎ | schießen |
| 🅾️ | zurück zum Titel |

Im Browser: Pfeiltasten, **X** schießt, **Z** = 🅾️.

## Dateien

| Datei | Inhalt |
|---|---|
| `index.html`, `index.js` | Web-Player (GitHub Pages) |
| `dgalaga.p8` | die Cart (in PICO-8: `load dgalaga`) |
| `dgalaga.p8.png` | dieselbe Cart als Bild-Datei |
| `dgalaga.lua` | der Quellcode zum Lesen |

## Hinweis

Fan-Projekt ohne kommerzielle Absichten, nicht verbunden mit den Rechteinhabern
von *Deluxe Galaga* oder *Galaga* (Bandai Namco). Grafik und Code sind eigen,
nichts ist aus dem Original übernommen.
