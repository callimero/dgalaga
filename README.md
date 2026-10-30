# Pico8 Deluxe Galaga

Ein Shooter nach dem Vorbild von **[Deluxe Galaga](https://deluxegalaga.com/index.html)**
von Edgar M. Vigdal (1958–2015), für die Fantasy-Konsole
[PICO-8](https://www.lexaloffle.com/pico-8.php).

In Verehrung für den Entwickler Edgar M. Vigdal! YOU ARE LEGEND! Ich hatte die Ehre ein paar Mails
mit ihm zu wechseln und mich auszutauschen kurz vor seinem Tod.

Viele viele Stunden wurde es gespielt, noch in der "normalen" (nicht AGA) Version, der Zweispielermode von Deluxe Galaga ist garantiert 
das Game das ich am längsten mit Freunden zusammen gespielt habe.

Viel Grafiken sind zu machen: nicht einfach den Stil der Aliens zu treffen bei der geringen Auflösung. Letzlich sollte man es 
vielleicht ein "Demake" nennen.

**[▶ Im Browser spielen](https://callimero.github.io/dgalaga/)**

![Pico8 Deluxe Galaga](dgalaga.p8.png)

## Woher – Deluxe Galaga

*Deluxe Galaga* ist ein Shareware-Shoot'em-up für den **Commodore Amiga** aus
den 1990er-Jahren, geschrieben von dem Norweger **Edgar M. Vigdal**. Es nimmt
die Idee des Arcade-Klassikers *Galaga* (Namco, 1981) – Feinde fliegen in
Formation ein und stürzen sich einzeln drehend herab – und macht daraus
deutlich mehr: Extras und Waffen zum Kaufen, viele Level,
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

**Pico8 Deluxe Galaga** ist eine kleine Verbeugung davor: kein Nachbau, sondern der
Versuch, das Gefühl von Formation, Sturzflug und Sternfeld in die engen
Grenzen von PICO-8 (128 × 128 Pixel, 16 Farben, 6 Tasten) zu bringen – und
dabei Lua wieder zu lernen. Grafisch wird das natürlich sehr rudimentär;
worauf es ankommt, ist das Spielgefühl, und das soll möglichst gut
eingefangen werden.

Wer das echte Spiel erleben will, braucht zum Glück weder einen Amiga noch
einen Emulator: Auf [deluxegalaga.com](https://deluxegalaga.com/index.html)
läuft es inzwischen sogar im Browser – in voller AGA-Pracht, dem Grafikmodus
der neueren Amigas (A1200/A4000).

## Neu: Geld und der Deluxe Tax Free Shop 💰

Abgeschossene Aliens lassen sich drehende **Münzen** fallen – Silber, Gold,
U238, Anti und Rot, je wertvoller, desto seltener. Vor einem Shop geht es
durch einen **Warp** (das Sternfeld wird schnell und blau), dann wird
eingekauft: Extra Speed, Extra Bullet, Double/Triple Shot, Less Speed,
**Auto Fire** und Extra Life. Am Spielende zählt das übrige Geld ×100 als
Punkte. Der **Highscore** wird gespeichert. Reicht das Geld nicht einmal
für den billigsten Artikel, wird der Shop samt Warp übersprungen.

## Eigene Level bauen – ohne PICO-8 🛠️

Im **[Level-Editor](https://callimero.github.io/dgalaga/editor/)** auf
„Load online cart“ klicken, Formation und Flugbahnen gestalten und mit
„▶ Play in browser“ sofort im Browser ausprobieren – das Spiel startet in
einem neuen Tab mit den eigenen Leveln. „Download cart“ speichert sie als
`.p8`, zum Teilen.

## Neu: Extras! 🎁

Abgeschossene Aliens lassen jetzt **Extras** fallen – einsammeln, indem man
mit dem Schiff darunter fliegt:

| Extra | Wirkung |
|---|---|
| **Bullet** | eine Ladung mehr im Akku (bis 20) |
| **Speed** | das Schiff wird schneller (es startet bewusst etwas träge) |
| **Shield** | 10 Sekunden unverwundbar (blinkend) |
| **Single / Double / Triple Shot** | installiert diese Waffe – fängt man die Waffe, die man schon hat, gibt es eine Ladung mehr. Doppelschuss trifft doppelt, jedes Projektil des Dreifachschusses auch |
| **Extraleben** | ein Schiff mehr |
| **Auto Fire** | Feuertaste halten feuert automatisch (geht bei Lebensverlust verloren) |
| **Armor** | fängt einen Treffer ab, bis zu 4 (hellblaue Punkte über der Lebensanzeige) |
| **Punkte ×2 / ×5** | 30 Sekunden lang doppelte bzw. fünffache Punkte |
| **Scoop** | ein grüner Energietrichter saugt 10 Sekunden lang kleine Aliens an: zwei docken links und rechts an, schießen mit und fangen Treffer ab – sie halten bis zum nächsten Warp; weitere werden aus dem Bild geschleudert |
| **Meteor Storm** | beendet das Level und schickt das Schiff in einen Meteoritensturm (siehe unten) |
| **Totenköpfe** (rot/blau/grün) | Vorsicht: Waffe und Tempo sinken – drei hintereinander lösen später etwas aus |

Wie oft etwas fällt, steht pro Extra als „im Schnitt jeder n-te Abschuss“
in der Cart (Bullets oft, Extraleben selten). Wer ein Leben verliert,
verliert eine Waffenstufe. Die Buchstaben E-X-T-R-A und die Wirkung der
Totenkopf-Kombinationen folgen.

## Neu: Meteor Storm ☄️

Ein Pazifisten-Level: Über das Extra oder manchmal aus dem Warp heraus
gerät man in einen Meteoritensturm. Schießen geht nicht, nur ausweichen.

- Ein weißer Blitz kündigt ihn an. Der Sturm ist 60 **Galagometer** (Gm)
  lang, normal fliegt man 1 Gm pro Sekunde. Jedes Gm bringt 50 Punkte.
- **Feuertaste halten** fliegt schneller – man ist früher durch.
- Den **Bonus** gibt es nur für Vollgas: Wer über 90 % der Zeit die
  Feuertaste hält (im Original müssen es 100 % sein), bekommt die schnell
  geflogenen Gm doppelt, dazu **1000 Punkte und 500 Geld**. Darunter gibt
  es keinen Bonus. Laufende Punkte ×2/×5 zählen für alles mit.
- Ein Treffer kostet **kein Leben**, beendet aber den Sturm: Die Punkte
  bis dahin bleiben, Bonus und Geld gibt es keine.
- Nach dem Ziel kommen keine neuen Meteore mehr, den letzten muss man
  noch ausweichen. Danach geht es mit dem nächsten Level weiter – oder in den Shop.

## Stand

- Titel, Spiel als Zustände über `_update60=funktion`
- Sternfeld mit 100 Sternen in verschiedenen Tiefen (Tempo und Helligkeit),
  dunkles Grau aus der geheimen Palette
- Schiff mit Neigung beim Lenken
- **Schüsse wie im Original:** ein Magazin mit 3 Schüssen, je Tastendruck
  einer (Festhalten feuert nicht automatisch). Erst wenn es leer ist, lädt
  es nach – also gut haushalten.
- **Waffen:** Einzel-, Doppel- und Dreifachschuss; der Dreifachschuss
  fächert auseinander. Kommen als Extras.
- **Gegner als Objekte** mit drei Arten der Darstellung:
  - Flattern in der Formation (Bilder nach Zeit, jeder Gegner mit eigenem
    Takt und Startbild, damit die Formation nicht im Gleichschritt flattert)
  - Flug mit Blick in Flugrichtung
  - Sturzflug mit gleichmäßiger Drehung
  - 8 Richtungen aus nur 3 Sprites pro Gegner (gerade, schräg, seitlich)
    plus Spiegeln
- **Formation** aus roten, grünen und blauen Gegnern, die langsam hin und
  her pendelt. Ab und zu stürzt einer kreiselnd heraus, fliegt einen Bogen,
  kommt von oben zurück und reiht sich wieder ein.
- **Käfer** (2×2-Sprite) flattert über den Grünen und wirft „Säure“ –
  Plasmabälle mit grün verglühendem Schweif
- **Abschießen:** kleine Gegner brauchen einen Treffer, der Käfer mehrere
  (einstellbar) und blitzt bei jedem Treffer weiß auf. Explosion aus
  Sprite-Animation und Funken in der Farbe des Gegners.
- **Angriffswellen** mit 1, 1, 2, 2, 3, 3 … Angreifern gleichzeitig. Sie
  schießen wie im Original nur senkrecht nach unten, in Salven von 1–3
  Schüssen: beim Abtauchen und nach dem Kreisel im Sinkflug – bis knapp
  über das eigene Schiff. Ausweichen ist Pflicht (Treffer folgen noch).
- **Treffer auf das eigene Schiff** durch Schüsse und Säure: Explosion,
  ein Leben weniger, danach kurz blinkend unverwundbar; bei 0 Leben
  „game over“. Berührungen mit Aliens schaden nicht – wie im Original.
- **Große Gegner** schießen gezielt auf das Schiff, jeder mit eigenem Projektil
- **Sturzflug:** kreiselnd aus der Formation, schräg nach unten feuernd,
  manchmal mit Kreis im unteren Bildteil
- **Level** liegen als Daten in der Map der Cart (kostet keinen Code):
  Formation, bis zu 5 Ströme auf Bézierbahnen, auf denen die Aliens
  einfliegen und sich in ihre Plätze aufteilen. Große Aliens wandern frei
  in der oberen Hälfte, wechseln die Richtung und stoßen vor.
- **Bonusrunden** („bonus stage“ blinkt): Aliens kreuzen ohne zu schießen
- **Kamikaze-Level:** Wellen von Aliens stürzen nebeneinander von oben
  herab, feuern heftig, wenden unten und fliegen wieder hinaus
- **Gegnerarten:** rot, grün, blau, UFO, kleine Fliegen (kleine Aliens mit Flattern und
  8 Drehrichtungen), dazu die großen Käfer, Fliegen und Mutterschiffe –
  jede große Art mit eigenem Geschoss (Säure, rote und grüne Kugeln)
- **Blaue Käfer** werden nach zwei Treffern grün und fliegen weiter – erst
  ein dritter Treffer erledigt sie
- **Titelbild und Levelansage:** jede Stage wird mit einem eigenen Spruch
  angekündigt („its a trap. a flytrap.“), Bonusrunden blinken schon dort
- **Sound:** Kanone, Alien-Schüsse, trudelnde Aliens, Extras und
  Explosionen
- **Akku statt Magazin:** jeder Schuss kostet eine Ladung, der Akku lädt
  ständig nach (bis 20 Ladungen mit Bullet-Extras)
- **Levelübergang** mit Stage, Punkten und Highscore; nach dem letzten
  Abschuss läuft das Level noch kurz weiter
- Lebensanzeige oben rechts (Punkte und Highscore kommen zwischen den Leveln)

## Geplant

- weitere Extras: E-X-T-R-A-Buchstaben, Totenkopf-Kombinationen, Abzeichen
- höhere Waffenstufen
- Punkte- und Highscore-Anzeige zwischen den Leveln ausbauen

## Steuerung

| Taste | Funktion |
|---|---|
| ⬅️ ➡️ | fliegen |
| 🅾️ oder ❎ | schießen, auf dem Titel: Start |

Im Browser: Pfeiltasten, **Z** oder **X** schießt (auch C/V/N/M).

## Dateien

| Datei | Inhalt |
|---|---|
| `index.html`, `index.js` | Web-Player (GitHub Pages) |
| `dgalaga.p8` | die Cart (in PICO-8: `load dgalaga`) |
| `dgalaga.p8.png` | dieselbe Cart als Bild-Datei (ohne Kommentare, sonst passt der Code nicht hinein) |
| `dgalaga.lua` | der Quellcode zum Lesen |
| `editor/index.html` | Level-Editor ([online](https://callimero.github.io/dgalaga/editor/)): lädt die Cart, Formation und Bézier-Ströme per Maus, Vorschau mit den echten Sprites, speichert direkt in die Cart (Chrome/Edge) mit nummerierten Backups – oder ganz ohne PICO-8: Online-Cart laden, Level bauen, im Browser spielen, Cart herunterladen |
| `tools/levels.py` | Notlösung: schreibt Level per Skript in die Map |
| `tools/strip.py` | entfernt Kommentare für den PNG- und Web-Export |
| `stats/index.html` | Statistik ([online](https://callimero.github.io/dgalaga/stats/)): wertet das Spiel-Log aus (siehe unten) |

## Statistik 📊

Zum Austarieren kann die Cart ein Log schreiben: In `tune()` (Tab 0)
`dbg_log=true` setzen, dann legt PICO-8 neben der Cart eine
`dgalaga_log.csv` an – eine Zeile pro Ereignis (Level, gefallene und
eingesammelte Extras, Münzen, Meteorsturm, Game over). Die
[Statistik-Seite](https://callimero.github.io/dgalaga/stats/) liest die
Datei direkt im Browser (es wird nichts hochgeladen) und zeigt Spiele,
Abschüsse, Level, Highscore, wie oft welches Extra fällt und eingesammelt
wird, Münzen, Level-Typen und Score pro Spiel. Mit der Cart dazu vergleicht
sie die eingestellte Häufigkeit der Extras mit der gemessenen. Chrome/Edge
merken sich die Datei, danach reicht „Neu laden“.

## Hinweis

Fan-Projekt ohne kommerzielle Absichten, nicht verbunden mit den Rechteinhabern
von *Deluxe Galaga* oder *Galaga* (Bandai Namco). Grafik und Code sind eigen,
nichts ist aus dem Original übernommen.
