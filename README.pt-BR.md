# Glance Dock

[English](README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · **Português (BR)** · [Русский](README.ru.md)

Por **Seunghan** ([@seunghan91](https://github.com/seunghan91)) · [Página do projeto](https://seunghan.xyz/omarchy/glance-dock/)

Um dock de aplicativos abertos para o shell do Omarchy. Deixe o ponteiro
parado na barra, à esquerda do relógio, e logo abaixo aparece uma fileira de
ícones de aplicativos: sobre o número de um workspace, ela mostra as janelas
desse workspace; em qualquer outro ponto da zona, mostra as do workspace em
foco. Um dock de borda opcional, no estilo Apple, à esquerda, à direita ou na
parte inferior da tela, lista todos os aplicativos abertos em todos os
workspaces. Os dois docks compartilham um mesmo menu de clique direito com as
janelas do aplicativo e Quit / Force Quit.

![Demo: o dock da barra aparece sob o ponteiro, acompanha os números dos workspaces e depois são exibidos o dock de borda e seu menu de clique direito com Quit e Force Quit](docs/glance-dock-demo.gif)

![Dock de borda à esquerda com um tooltip](docs/glance-dock-edge.png)

| Dock ao passar o ponteiro na barra | Menu de clique direito |
|---|---|
| ![Dock ao passar o ponteiro sob os números dos workspaces](docs/glance-dock-top.png) | ![Lista de janelas e Quit](docs/glance-dock-menu.png) |

## Recursos

- **Dock ao passar o ponteiro na barra.** O widget não ocupa espaço próprio;
  ele observa toda a superfície da barra, da borda esquerda até o relógio. Se
  a barra não tem relógio, a zona é os 40% da esquerda da barra.
- **Prévia por workspace.** Passar o ponteiro sobre o número de um workspace
  mostra os aplicativos dele; ao mover o ponteiro pelos números, o dock muda
  em tempo real. Com o ponteiro na barra, fora dos números, trocar de
  workspace pelo teclado com o dock aberto faz o dock acompanhar o novo
  workspace.
- **Dock de borda (opcional).** Todas as janelas abertas de todos os
  workspaces, na borda esquerda, direita ou inferior. `autohide` o desliza
  para dentro quando o ponteiro toca a borda; `pinned` o mantém à mostra e
  reserva o espaço dele para que as janelas em mosaico se afastem.
- **Um ícone por aplicativo.** Várias janelas do mesmo aplicativo compartilham
  um ícone com um selo de contagem. Clicar em um ícone foca uma janela; clicar
  de novo percorre as janelas desse aplicativo.
- **Marcador ativo e tooltips.** O aplicativo dono da janela em foco recebe uma
  linha de destaque; manter o ponteiro 400 ms sobre um ícone mostra o nome e a
  quantidade de janelas.
- **Menu de clique direito** com as janelas do aplicativo (a ativa vem
  marcada) e depois **Quit**. Mantenha **Alt** pressionada com o menu aberto
  para transformá-lo em **Force Quit**.
- **Tratamento de estouro.** Fileiras longas rolam com a roda do mouse e
  mostram uma contagem `+N` para os ícones que ficam além do fim.
- **Os ícones acompanham a barra.** O tamanho do ícone é a altura da barra x
  1,08, escalado pela configuração Icon size, então acompanha a escala da
  interface do Omarchy.

## Instalação

```bash
omarchy plugin add https://github.com/seunghan91/omarchy-glance-dock --enable
```

O widget declara `left` como seção padrão. Ele não desenha nada na própria
barra, então a posição dele dentro da seção não importa. Para movê-lo mesmo
assim:

```bash
omarchy bar move io.github.seunghan91.glance-dock --section left
```

## Atualização

```bash
omarchy plugin update
```

`omarchy plugin update` busca os plugins instalados, mostra um diff e faz
fast-forward.

## Desinstalação

```bash
omarchy plugin remove io.github.seunghan91.glance-dock
```

## Configurações

Altere-as nas configurações do widget na barra do Omarchy.

| Chave | Valores | Padrão | Significado |
|---|---|---|---|
| `iconScale` | `small`, `normal`, `large` | `normal` | Escala os ícones por 0,85, 1 ou 1,2 sobre a altura da barra x 1,08. |
| `hoverDelayMs` | 0 – 1000 (passo de 50) | `250` | Por quanto tempo o ponteiro precisa ficar parado na barra antes de o dock abrir. |
| `edgeDock` | `off`, `left`, `right`, `bottom` | `left` | Onde fica o dock de borda, ou `off` para usar só o dock da barra. |
| `edgeMode` | `autohide`, `pinned` | `autohide` | `autohide` desliza o dock de borda para dentro quando o ponteiro toca a borda da tela (150 ms) e o esconde 300 ms depois que o ponteiro sai. `pinned` o mantém visível e reserva a largura dele para que as janelas em mosaico se afastem. |

## Uso

- **Abrir o dock:** deixe o ponteiro parado em qualquer ponto da barra à
  esquerda do relógio pelo tempo de espera configurado. Sobre o número de um
  workspace você vê os aplicativos dele; no resto da zona, os do workspace em
  foco. O dock fica aberto enquanto o ponteiro estiver na zona ou no dock, e
  fecha 120 ms depois que o ponteiro sai dos dois.
- **Focar uma janela:** clique esquerdo em um ícone. Clique de novo para
  percorrer as outras janelas do aplicativo. No dock de borda, isso também
  troca para o workspace da janela.
- **Clique direito em um ícone** para abrir o menu: clique no título de uma
  janela para focá-la, ou em **Quit** para fechar as janelas listadas no menu
  — no dock da barra, são as janelas do aplicativo naquele workspace; no dock
  de borda, as de todos os workspaces.
- **Force Quit:** com o menu aberto, mantenha **Alt** pressionada — Quit vira
  Force Quit. Solte a Alt para voltar.
- **Fechar o menu:** pressione **Esc** ou clique em qualquer lugar fora dele.

## Como Quit e Force Quit funcionam

- **Quit** pede a cada janela do aplicativo que feche, o mesmo que fechá-las
  pelo teclado, então os aplicativos ainda podem avisar sobre trabalho não
  salvo.
- **Force Quit** consulta o ID de processo de cada janela com
  `hyprctl clients -j` e `jq`, e envia **SIGKILL** a ele. O trabalho não salvo
  nesse processo é perdido e, se várias janelas compartilham um processo
  (comum em navegadores e terminais), todas elas fecham.

## Limitações conhecidas

- Segurar a Alt *antes* do clique direito não é detectado, então o menu abre
  como Quit. Pressione a Alt depois que o menu já estiver aberto.
- Vários monitores: enquanto um menu está aberto, o Hyprland não entrega a ele
  os cliques feitos em outro monitor, então clicar lá não o fecha. Pressione
  **Esc**.
- Só há um menu aberto por vez em todos os monitores; abrir um fecha o outro.

## Requisitos

- Omarchy com o shell baseado em Quickshell e suporte a plugins (widgets de
  barra).
- Hyprland 0.56 (focar e fechar janelas usam a sintaxe do dispatcher Lua,
  `hl.dsp.*`).
- `hyprctl` (vem com o Hyprland), `jq` (Force Quit), `bash` e `find` (busca de
  ícones). Todos estão presentes em uma instalação padrão do Omarchy.

## Privacidade e segurança

- Sem acesso à rede. Os únicos comandos externos são `hyprctl` (focar, fechar,
  posição do cursor, lista de clientes), uma varredura local dos diretórios de
  ícones XDG e de `/usr/share/pixmaps`, e `kill -KILL` para o Force Quit.
- Não grava nem modifica nenhum dos seus arquivos de configuração. O modo
  pinned reserva espaço da tela pela zona exclusiva do layer-shell somente
  enquanto o dock está em execução.
- Os endereços das janelas são validados como hexadecimal antes de chegarem a
  um comando de shell.
- O Force Quit envia SIGKILL ao processo da janela; veja acima.

## Autor

Projetado e desenvolvido por **Seunghan** — GitHub [@seunghan91](https://github.com/seunghan91), [seunghan.xyz](https://seunghan.xyz/omarchy/).
Issues e pull requests são bem-vindos.

## Licença

[MIT](LICENSE) © 2026 seunghan91
