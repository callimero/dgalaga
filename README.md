# Pico Deluxe (PICO-8)

Ein Shooter im Stil von **Galaga** / **Galaga Deluxe** für die Fantasy-Konsole
[PICO-8](https://www.lexaloffle.com/pico-8.php) – noch ganz am Anfang.

Diesmal schreibe ich den Code selbst, um mein eingerostetes Lua und PICO-8
aufzufrischen. Claude hilft mit Antworten auf konkrete Fragen.

**[▶ Im Browser spielen](https://callimero.github.io/dgalaga/)**

![Pico Deluxe](dgalaga.p8.png)

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

Fan-Projekt ohne kommerzielle Absichten. Galaga ist eine Marke der
Rechteinhaber.
