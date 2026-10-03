# Glance Dock

**English** · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [Русский](README.ru.md)

By **Seunghan** ([@seunghan91](https://github.com/seunghan91)) · [Project page](https://seunghan.xyz/omarchy/glance-dock/)

A dock of open apps for the Omarchy shell. Rest the pointer on the bar left of
the clock and a row of app icons drops down right under it: over a workspace
number it shows that workspace's windows, anywhere else in the zone it shows
the focused workspace's. An optional Apple-style edge dock on the left, right
or bottom of the screen lists every open app across all workspaces. Both docks
share one right-click menu with the app's windows and Quit / Force Quit.

![Demo: the bar dock drops under the pointer, follows the workspace numbers, then the edge dock and its right-click menu with Quit and Force Quit](docs/glance-dock-demo.gif)

![Edge dock on the left with a tooltip](docs/glance-dock-edge.png)

| Bar hover dock | Right-click menu |
|---|---|
| ![Hover dock under the workspace numbers](docs/glance-dock-top.png) | ![Window list and Quit](docs/glance-dock-menu.png) |

## Features

- **Hover dock in the bar.** The widget takes no space of its own; it watches
  the whole bar surface from its left edge up to the clock. If the bar has no
  clock, the zone is the left 40% of the bar.
- **Per-workspace peek.** Hovering a workspace number shows that workspace's
  apps; moving along the numbers switches the dock live. With the pointer on
  the bar outside the numbers, switching workspace by keyboard while the dock
  is open follows the new workspace.
- **Edge dock (optional).** Every open window on all workspaces, on the left,
  right or bottom edge. `autohide` slides it in when the pointer touches the
  edge; `pinned` keeps it out and reserves its space so tiled windows move
  aside.
- **One icon per app.** Several windows of the same app share an icon with a
  count badge. Clicking an icon focuses a window; clicking again cycles through
  that app's windows.
- **Active marker and tooltips.** The app that owns the focused window gets an
  accent line; hovering an icon for 400 ms shows its name and window count.
- **Right-click menu** listing the app's windows (the active one is marked),
  then **Quit**. Hold **Alt** while the menu is open to turn it into
  **Force Quit**.
- **Overflow handling.** Long rows scroll with the mouse wheel and show a
  `+N` count for icons past the end.
- **Icons follow the bar.** Icon size is the bar height x 1.08, scaled by the
  Icon size setting, so it tracks Omarchy's UI scale.

## Install

```bash
omarchy plugin add https://github.com/seunghan91/omarchy-glance-dock --enable
```

The widget declares `left` as its default section. It draws nothing in the
bar itself, so its position in the section does not matter. To move it
anyway:

```bash
omarchy bar move io.github.seunghan91.glance-dock --section left
```

## Update

```bash
omarchy plugin update
```

`omarchy plugin update` fetches installed plugins, shows a diff and
fast-forwards.

## Uninstall

```bash
omarchy plugin remove io.github.seunghan91.glance-dock
```

## Settings

Change these in the widget's settings in the Omarchy bar.

| Key | Values | Default | Meaning |
|---|---|---|---|
| `iconScale` | `small`, `normal`, `large` | `normal` | Scales icons by 0.85, 1 or 1.2 on top of bar height x 1.08. |
| `hoverDelayMs` | 0 – 1000 (step 50) | `250` | How long the pointer rests on the bar before the hover dock opens. |
| `edgeDock` | `off`, `left`, `right`, `bottom` | `left` | Where the edge dock sits, or `off` to use only the bar hover dock. |
| `edgeMode` | `autohide`, `pinned` | `autohide` | `autohide` slides the edge dock in when the pointer touches the screen edge (150 ms) and hides it 300 ms after the pointer leaves. `pinned` keeps it visible and reserves its width so tiled windows move aside. |

## Usage

- **Open the hover dock:** rest the pointer anywhere on the bar left of the
  clock for the hover delay. Over a workspace number you see that
  workspace's apps; elsewhere in the zone, the focused workspace's. The dock
  stays open while the pointer is on the zone or the dock, and closes 120 ms
  after it leaves both.
- **Focus a window:** left-click an icon. Click again to cycle through the
  app's other windows. From the edge dock this also switches to the window's
  workspace.
- **Right-click an icon** for the menu: click a window title to focus it, or
  **Quit** to close the windows listed in the menu — on the bar dock that is
  the app's windows on that workspace; on the edge dock, on every workspace.
- **Force Quit:** with the menu open, hold **Alt** — Quit becomes Force Quit.
  Release Alt to switch back.
- **Close the menu:** press **Esc** or click anywhere outside it.

## How Quit and Force Quit work

- **Quit** asks each of the app's windows to close, the same as closing them
  with the keyboard, so apps can still prompt about unsaved work.
- **Force Quit** looks up each window's process ID with `hyprctl clients -j`
  and `jq`, and sends it **SIGKILL**. Unsaved work in that process is lost, and
  if several windows share one process (common for browsers and terminals),
  all of them close.

## Known limitations

- Holding Alt *before* right-clicking is not detected, so the menu opens as
  Quit. Press Alt after the menu is open instead.
- Multi-monitor: a click anywhere on another monitor also closes the open
  menu, as on macOS.
- Only one menu is open at a time across all monitors; opening one closes the
  other.

## Requirements

- Omarchy with the Quickshell-based shell and plugin support (bar widgets).
- Hyprland 0.56 (window focus and close use the Lua dispatcher syntax,
  `hl.dsp.*`).
- `hyprctl` (ships with Hyprland), `jq` (Force Quit), `bash` and `find`
  (icon lookup). All are present on a standard Omarchy install.

## Privacy and safety

- No network access. The only external commands are `hyprctl` (focus, close,
  cursor position, client list), a local scan of the XDG icon directories and
  `/usr/share/pixmaps`, and `kill -KILL` for Force Quit.
- Does not write to or modify any of your configuration files. Pinned mode
  reserves screen space through the layer-shell exclusive zone only while the
  dock is running.
- Window addresses are validated as hex before they reach a shell command.
- Force Quit sends SIGKILL to the window's process; see above.

## Author

Designed and developed by **Seunghan** — GitHub [@seunghan91](https://github.com/seunghan91), [seunghan.xyz](https://seunghan.xyz/omarchy/).
Issues and pull requests are welcome.

## License

[MIT](LICENSE) © 2026 seunghan91
