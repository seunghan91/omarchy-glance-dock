# Glance Dock

[English](README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · **Deutsch** · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [Русский](README.ru.md)

Von **Seunghan** ([@seunghan91](https://github.com/seunghan91)) · [Projektseite](https://seunghan.xyz/omarchy/glance-dock/)

Ein Dock mit den geöffneten Apps für die Omarchy-Shell. Hält man den Mauszeiger
auf der Leiste links neben der Uhr an, klappt direkt darunter eine Reihe von
App-Symbolen auf: Über einer Arbeitsflächennummer zeigt sie die Fenster dieser
Arbeitsfläche, überall sonst in der Zone die der fokussierten Arbeitsfläche.
Ein optionales Edge-Dock im Apple-Stil am linken, rechten oder unteren
Bildschirmrand listet alle geöffneten Apps über sämtliche Arbeitsflächen auf.
Beide Docks teilen sich ein Rechtsklickmenü mit den Fenstern der App sowie
Quit / Force Quit.

![Demo: Das Leisten-Dock klappt unter dem Mauszeiger auf, folgt den Arbeitsflächennummern, danach das Edge-Dock und sein Rechtsklickmenü mit Quit und Force Quit](docs/glance-dock-demo.gif)

![Edge-Dock am linken Rand mit Tooltip](docs/glance-dock-edge.png)

| Hover-Dock in der Leiste | Rechtsklickmenü |
|---|---|
| ![Hover-Dock unter den Arbeitsflächennummern](docs/glance-dock-top.png) | ![Fensterliste und Quit](docs/glance-dock-menu.png) |

## Funktionen

- **Hover-Dock in der Leiste.** Das Widget belegt keinen eigenen Platz; es
  überwacht die gesamte Leistenfläche vom linken Rand bis zur Uhr. Hat die
  Leiste keine Uhr, ist die Zone die linken 40 % der Leiste.
- **Vorschau pro Arbeitsfläche.** Fährt man über eine Arbeitsflächennummer,
  zeigt das Dock deren Apps; bewegt man sich an den Nummern entlang, wechselt
  das Dock live. Steht der Mauszeiger auf der Leiste außerhalb der Nummern,
  folgt das geöffnete Dock beim Wechsel der Arbeitsfläche per Tastatur der
  neuen Arbeitsfläche.
- **Edge-Dock (optional).** Alle offenen Fenster aller Arbeitsflächen am
  linken, rechten oder unteren Rand. `autohide` schiebt es ein, sobald der
  Mauszeiger den Rand berührt; `pinned` hält es ausgefahren und reserviert
  seinen Platz, sodass gekachelte Fenster zur Seite rücken.
- **Ein Symbol pro App.** Mehrere Fenster derselben App teilen sich ein Symbol
  mit Zähler-Badge. Ein Klick auf ein Symbol fokussiert ein Fenster; ein
  weiterer Klick wechselt durch die Fenster dieser App.
- **Aktiv-Markierung und Tooltips.** Die App, der das fokussierte Fenster
  gehört, erhält eine Akzentlinie; hält man den Mauszeiger 400 ms auf einem
  Symbol, erscheinen Name und Fensteranzahl.
- **Rechtsklickmenü** mit den Fenstern der App (das aktive ist markiert),
  danach **Quit**. Hält man bei geöffnetem Menü **Alt** gedrückt, wird daraus
  **Force Quit**.
- **Umgang mit Überlänge.** Lange Reihen scrollen mit dem Mausrad und zeigen
  für Symbole über das Ende hinaus eine Zahl `+N`.
- **Symbole folgen der Leiste.** Die Symbolgröße ist die Leistenhöhe x 1,08,
  skaliert mit der Einstellung Icon size, sodass sie der UI-Skalierung von
  Omarchy folgt.

## Installation

```bash
omarchy plugin add https://github.com/seunghan91/omarchy-glance-dock --enable
```

Das Widget deklariert `left` als Standardabschnitt. Es zeichnet selbst nichts
in die Leiste, daher spielt seine Position im Abschnitt keine Rolle. Um es
trotzdem zu verschieben:

```bash
omarchy bar move io.github.seunghan91.glance-dock --section left
```

## Aktualisierung

```bash
omarchy plugin update
```

`omarchy plugin update` ruft die installierten Plugins ab, zeigt einen Diff und
führt einen Fast-Forward aus.

## Deinstallation

```bash
omarchy plugin remove io.github.seunghan91.glance-dock
```

## Einstellungen

Diese werden in den Einstellungen des Widgets in der Omarchy-Leiste geändert.

| Schlüssel | Werte | Standard | Bedeutung |
|---|---|---|---|
| `iconScale` | `small`, `normal`, `large` | `normal` | Skaliert die Symbole mit 0,85, 1 oder 1,2 zusätzlich zu Leistenhöhe x 1,08. |
| `hoverDelayMs` | 0 – 1000 (Schritt 50) | `250` | Wie lange der Mauszeiger auf der Leiste ruhen muss, bevor sich das Hover-Dock öffnet. |
| `edgeDock` | `off`, `left`, `right`, `bottom` | `left` | Wo das Edge-Dock sitzt, oder `off`, um nur das Hover-Dock der Leiste zu nutzen. |
| `edgeMode` | `autohide`, `pinned` | `autohide` | `autohide` schiebt das Edge-Dock ein, wenn der Mauszeiger den Bildschirmrand berührt (150 ms), und blendet es 300 ms nach dem Verlassen wieder aus. `pinned` hält es sichtbar und reserviert seine Breite, sodass gekachelte Fenster zur Seite rücken. |

## Verwendung

- **Hover-Dock öffnen:** den Mauszeiger für die Hover-Verzögerung an eine
  beliebige Stelle der Leiste links neben der Uhr halten. Über einer
  Arbeitsflächennummer erscheinen die Apps dieser Arbeitsfläche, sonst die der
  fokussierten. Das Dock bleibt offen, solange der Mauszeiger auf der Zone oder
  dem Dock steht, und schließt 120 ms nach dem Verlassen von beiden.
- **Fenster fokussieren:** ein Symbol linksklicken. Erneut klicken, um durch die
  weiteren Fenster der App zu wechseln. Vom Edge-Dock aus wechselt das auch zur
  Arbeitsfläche des Fensters.
- **Rechtsklick auf ein Symbol** öffnet das Menü: einen Fenstertitel anklicken,
  um das Fenster zu fokussieren, oder **Quit**, um die im Menü aufgeführten
  Fenster zu schließen — im Leisten-Dock sind das die Fenster der App auf
  dieser Arbeitsfläche, im Edge-Dock die auf allen Arbeitsflächen.
- **Force Quit:** bei geöffnetem Menü **Alt** gedrückt halten — aus Quit wird
  Force Quit. Alt loslassen, um zurückzuwechseln.
- **Menü schließen:** **Esc** drücken oder irgendwo außerhalb klicken.

## So funktionieren Quit und Force Quit

- **Quit** fordert jedes Fenster der App zum Schließen auf, genau wie beim
  Schließen per Tastatur, sodass Apps weiterhin nach ungespeicherter Arbeit
  fragen können.
- **Force Quit** ermittelt die Prozess-ID jedes Fensters mit `hyprctl clients -j`
  und `jq` und sendet ihr **SIGKILL**. Ungespeicherte Arbeit in diesem Prozess
  geht verloren, und wenn sich mehrere Fenster einen Prozess teilen (häufig bei
  Browsern und Terminals), werden alle geschlossen.

## Bekannte Einschränkungen

- Wird Alt gehalten, *bevor* man rechtsklickt, wird das nicht erkannt, das Menü
  öffnet sich also als Quit. Alt stattdessen drücken, wenn das Menü bereits
  offen ist.
- Mehrere Monitore: Solange ein Menü offen ist, liefert Hyprland Klicks auf
  einem anderen Monitor nicht an das Menü, ein Klick dort schließt es also
  nicht. **Esc** drücken.
- Über alle Monitore hinweg ist immer nur ein Menü offen; das Öffnen eines
  Menüs schließt das andere.

## Voraussetzungen

- Omarchy mit der Quickshell-basierten Shell und Plugin-Unterstützung
  (Leisten-Widgets).
- Hyprland 0.56 (Fensterfokus und Schließen nutzen die Lua-Dispatcher-Syntax,
  `hl.dsp.*`).
- `hyprctl` (wird mit Hyprland ausgeliefert), `jq` (Force Quit), `bash` und
  `find` (Symbolsuche). Alle sind bei einer Standardinstallation von Omarchy
  vorhanden.

## Datenschutz und Sicherheit

- Kein Netzwerkzugriff. Die einzigen externen Befehle sind `hyprctl` (Fokus,
  Schließen, Mausposition, Client-Liste), ein lokaler Scan der XDG-Symbolordner
  und von `/usr/share/pixmaps` sowie `kill -KILL` für Force Quit.
- Schreibt in keine deiner Konfigurationsdateien und ändert keine. Der
  Pinned-Modus reserviert Bildschirmplatz über die Exclusive Zone der
  Layer-Shell nur, solange das Dock läuft.
- Fensteradressen werden als Hex validiert, bevor sie an einen Shell-Befehl
  gelangen.
- Force Quit sendet SIGKILL an den Prozess des Fensters; siehe oben.

## Autor

Entworfen und entwickelt von **Seunghan** — GitHub [@seunghan91](https://github.com/seunghan91), [seunghan.xyz](https://seunghan.xyz/omarchy/).
Issues und Pull Requests sind willkommen.

## Lizenz

[MIT](LICENSE) © 2026 seunghan91
