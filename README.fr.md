# Glance Dock

[English](README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [Deutsch](README.de.md) · **Français** · [Português (BR)](README.pt-BR.md) · [Русский](README.ru.md)

Par **Seunghan** ([@seunghan91](https://github.com/seunghan91)) · [Page du projet](https://seunghan.xyz/omarchy/glance-dock/)

Un dock des applications ouvertes pour le shell Omarchy. Laissez le pointeur
sur la barre, à gauche de l'horloge, et une rangée d'icônes d'applications se
déploie juste en dessous : au-dessus d'un numéro d'espace de travail, elle
affiche les fenêtres de cet espace de travail, et partout ailleurs dans la zone
celles de l'espace de travail actif. Un dock de bord optionnel, dans le style
d'Apple, à gauche, à droite ou en bas de l'écran, liste toutes les applications
ouvertes de tous les espaces de travail. Les deux docks partagent un même menu
du clic droit avec les fenêtres de l'application et Quit / Force Quit.

![Démo : le dock de la barre se déploie sous le pointeur et suit les numéros d'espace de travail, puis le dock de bord et son menu du clic droit avec Quit et Force Quit](docs/glance-dock-demo.gif)

![Dock de bord à gauche avec une infobulle](docs/glance-dock-edge.png)

| Dock au survol de la barre | Menu du clic droit |
|---|---|
| ![Dock au survol sous les numéros d'espace de travail](docs/glance-dock-top.png) | ![Liste des fenêtres et Quit](docs/glance-dock-menu.png) |

## Fonctionnalités

- **Dock au survol dans la barre.** Le widget n'occupe aucune place ; il
  surveille toute la surface de la barre, de son bord gauche jusqu'à l'horloge.
  Si la barre n'a pas d'horloge, la zone correspond aux 40 % de gauche de la
  barre.
- **Aperçu par espace de travail.** Survoler un numéro d'espace de travail
  affiche ses applications ; en se déplaçant le long des numéros, le dock change
  en direct. Si le pointeur est sur la barre en dehors des numéros, changer
  d'espace de travail au clavier alors que le dock est ouvert le fait suivre le
  nouvel espace de travail.
- **Dock de bord (optionnel).** Toutes les fenêtres ouvertes de tous les espaces
  de travail, sur le bord gauche, droit ou inférieur. `autohide` le fait glisser
  dans l'écran quand le pointeur touche le bord ; `pinned` le garde sorti et
  réserve son espace pour que les fenêtres en mosaïque se décalent.
- **Une icône par application.** Plusieurs fenêtres de la même application
  partagent une icône avec un badge de compte. Cliquer sur une icône donne le
  focus à une fenêtre ; cliquer à nouveau parcourt les fenêtres de cette
  application.
- **Marqueur d'activité et infobulles.** L'application qui possède la fenêtre
  active reçoit un trait d'accent ; survoler une icône pendant 400 ms affiche
  son nom et son nombre de fenêtres.
- **Menu du clic droit** listant les fenêtres de l'application (la fenêtre
  active est marquée), puis **Quit**. Maintenez **Alt** pendant que le menu est
  ouvert pour le transformer en **Force Quit**.
- **Gestion du débordement.** Les longues rangées défilent à la molette et
  affichent un compteur `+N` pour les icônes au-delà de la fin.
- **Les icônes suivent la barre.** La taille des icônes est la hauteur de la
  barre x 1,08, mise à l'échelle par le réglage Icon size, de sorte qu'elle suit
  l'échelle d'interface d'Omarchy.

## Installation

```bash
omarchy plugin add https://github.com/seunghan91/omarchy-glance-dock --enable
```

Le widget déclare `left` comme section par défaut. Il ne dessine rien dans la
barre elle-même, donc sa position dans la section n'a pas d'importance. Pour le
déplacer malgré tout :

```bash
omarchy bar move io.github.seunghan91.glance-dock --section left
```

## Mise à jour

```bash
omarchy plugin update
```

`omarchy plugin update` récupère les plugins installés, affiche un diff et
effectue un fast-forward.

## Désinstallation

```bash
omarchy plugin remove io.github.seunghan91.glance-dock
```

## Réglages

Modifiez-les dans les réglages du widget dans la barre Omarchy.

| Clé | Valeurs | Par défaut | Signification |
|---|---|---|---|
| `iconScale` | `small`, `normal`, `large` | `normal` | Met les icônes à l'échelle de 0,85, 1 ou 1,2 en plus de la hauteur de la barre x 1,08. |
| `hoverDelayMs` | 0 – 1000 (pas de 50) | `250` | Durée pendant laquelle le pointeur doit rester sur la barre avant l'ouverture du dock au survol. |
| `edgeDock` | `off`, `left`, `right`, `bottom` | `left` | Emplacement du dock de bord, ou `off` pour n'utiliser que le dock au survol de la barre. |
| `edgeMode` | `autohide`, `pinned` | `autohide` | `autohide` fait glisser le dock de bord dans l'écran quand le pointeur touche le bord de l'écran (150 ms) et le masque 300 ms après le départ du pointeur. `pinned` le garde visible et réserve sa largeur pour que les fenêtres en mosaïque se décalent. |

## Utilisation

- **Ouvrir le dock au survol :** laissez le pointeur n'importe où sur la barre, à
  gauche de l'horloge, pendant le délai de survol. Au-dessus d'un numéro
  d'espace de travail, vous voyez les applications de cet espace de travail ;
  ailleurs dans la zone, celles de l'espace de travail actif. Le dock reste
  ouvert tant que le pointeur est sur la zone ou sur le dock, et se ferme 120 ms
  après qu'il a quitté les deux.
- **Donner le focus à une fenêtre :** clic gauche sur une icône. Cliquez à
  nouveau pour parcourir les autres fenêtres de l'application. Depuis le dock de
  bord, cela bascule aussi vers l'espace de travail de la fenêtre.
- **Clic droit sur une icône** pour le menu : cliquez sur un titre de fenêtre
  pour lui donner le focus, ou sur **Quit** pour fermer les fenêtres listées
  dans le menu — sur le dock de la barre, ce sont les fenêtres de l'application
  sur cet espace de travail ; sur le dock de bord, sur tous les espaces de
  travail.
- **Force Quit :** avec le menu ouvert, maintenez **Alt** — Quit devient Force
  Quit. Relâchez Alt pour revenir en arrière.
- **Fermer le menu :** appuyez sur **Esc** ou cliquez n'importe où en dehors.

## Fonctionnement de Quit et Force Quit

- **Quit** demande à chaque fenêtre de l'application de se fermer, comme en les
  fermant au clavier, de sorte que les applications peuvent encore proposer
  d'enregistrer le travail non sauvegardé.
- **Force Quit** détermine l'identifiant de processus de chaque fenêtre avec
  `hyprctl clients -j` et `jq`, et lui envoie **SIGKILL**. Le travail non
  enregistré dans ce processus est perdu, et si plusieurs fenêtres partagent un
  même processus (fréquent pour les navigateurs et les terminaux), toutes se
  ferment.

## Limitations connues

- Maintenir Alt *avant* le clic droit n'est pas détecté : le menu s'ouvre donc
  en Quit. Appuyez plutôt sur Alt une fois le menu ouvert.
- Multi-écran : tant qu'un menu est ouvert, Hyprland ne lui transmet pas les
  clics sur un autre écran, donc cliquer à cet endroit ne le ferme pas. Appuyez
  sur **Esc**.
- Un seul menu est ouvert à la fois sur l'ensemble des écrans ; en ouvrir un
  ferme l'autre.

## Prérequis

- Omarchy avec le shell basé sur Quickshell et la prise en charge des plugins
  (widgets de barre).
- Hyprland 0.56 (le focus et la fermeture des fenêtres utilisent la syntaxe de
  dispatcher Lua, `hl.dsp.*`).
- `hyprctl` (fourni avec Hyprland), `jq` (Force Quit), `bash` et `find`
  (recherche d'icônes). Tous sont présents dans une installation standard
  d'Omarchy.

## Confidentialité et sécurité

- Aucun accès réseau. Les seules commandes externes sont `hyprctl` (focus,
  fermeture, position du curseur, liste des clients), une analyse locale des
  dossiers d'icônes XDG et de `/usr/share/pixmaps`, et `kill -KILL` pour Force
  Quit.
- N'écrit dans aucun de vos fichiers de configuration et n'en modifie aucun. Le
  mode pinned réserve de l'espace d'écran via la zone exclusive du layer-shell
  uniquement tant que le dock s'exécute.
- Les adresses de fenêtre sont validées en hexadécimal avant d'atteindre une
  commande shell.
- Force Quit envoie SIGKILL au processus de la fenêtre ; voir plus haut.

## Auteur

Conçu et développé par **Seunghan** — GitHub [@seunghan91](https://github.com/seunghan91), [seunghan.xyz](https://seunghan.xyz/omarchy/).
Les issues et pull requests sont les bienvenues.

## Licence

[MIT](LICENSE) © 2026 seunghan91
