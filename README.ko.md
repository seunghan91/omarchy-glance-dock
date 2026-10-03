# Glance Dock

[English](README.md) · **한국어** · [日本語](README.ja.md) · [简体中文](README.zh-CN.md) · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [Русский](README.ru.md)

제작 **Seunghan** ([@seunghan91](https://github.com/seunghan91)) · [프로젝트 페이지](https://seunghan.xyz/omarchy/glance-dock/)

Omarchy 셸용 열린 앱 독입니다. 시계 왼쪽의 바 위에 포인터를 올려 두면 바로 아래로 앱 아이콘 줄이 내려옵니다. 워크스페이스 번호 위에서는 그 워크스페이스의 창을, 영역 안의 다른 곳에서는 포커스된 워크스페이스의 창을 보여 줍니다. 화면 왼쪽·오른쪽·아래 가장자리에는 Apple 스타일의 엣지 독을 선택해서 둘 수 있으며, 모든 워크스페이스에 열린 앱을 전부 나열합니다. 두 독은 앱의 창 목록과 Quit / Force Quit이 있는 우클릭 메뉴를 함께 씁니다.

![데모: 바 독이 포인터 아래로 내려오고 워크스페이스 번호를 따라가며, 이어서 엣지 독과 Quit·Force Quit이 있는 우클릭 메뉴가 나타납니다](docs/glance-dock-demo.gif)

![툴팁이 보이는 왼쪽 엣지 독](docs/glance-dock-edge.png)

| 바 호버 독 | 우클릭 메뉴 |
|---|---|
| ![워크스페이스 번호 아래의 호버 독](docs/glance-dock-top.png) | ![창 목록과 Quit](docs/glance-dock-menu.png) |

## 기능

- **바 안의 호버 독.** 위젯은 자리를 차지하지 않고 바의 왼쪽 끝부터 시계까지 바 전체 표면을 감시합니다. 바에 시계가 없으면 바의 왼쪽 40%가 영역입니다.
- **워크스페이스별 미리보기.** 워크스페이스 번호에 포인터를 올리면 그 워크스페이스의 앱이 보이고 번호를 따라 움직이면 독이 실시간으로 바뀝니다. 포인터가 번호 바깥의 바 위에 있을 때 독이 열린 상태로 키보드로 워크스페이스를 바꾸면 새 워크스페이스를 따라갑니다.
- **엣지 독(선택).** 모든 워크스페이스의 열린 창을 왼쪽·오른쪽·아래 가장자리에 표시합니다. `autohide`는 포인터가 가장자리에 닿으면 밀려 나오고, `pinned`는 계속 나와 있으면서 공간을 확보해 타일 창이 비켜 줍니다.
- **앱당 아이콘 하나.** 같은 앱의 창이 여러 개면 개수 배지가 붙은 아이콘 하나를 공유합니다. 아이콘을 클릭하면 창 하나에 포커스하고 다시 클릭하면 그 앱의 창을 차례로 돌아갑니다.
- **활성 표시와 툴팁.** 포커스된 창을 가진 앱에는 강조선이 붙습니다. 아이콘 위에 400 ms 머물면 이름과 창 개수가 나타납니다.
- **우클릭 메뉴**에는 앱의 창 목록(활성 창 표시)과 **Quit**이 있습니다. 메뉴가 열린 동안 **Alt**를 누르고 있으면 **Force Quit**으로 바뀝니다.
- **넘침 처리.** 긴 줄은 마우스 휠로 스크롤하며 끝을 넘어간 아이콘은 `+N`으로 개수를 표시합니다.
- **아이콘이 바를 따라감.** 아이콘 크기는 바 높이 x 1.08에 Icon size 설정 배율을 곱한 값이라 Omarchy의 UI 배율에 맞춰 달라집니다.

## 설치

```bash
omarchy plugin add https://github.com/seunghan91/omarchy-glance-dock --enable
```

위젯의 기본 섹션은 `left`입니다. 바 안에는 아무것도 그리지 않으므로 섹션 안의 위치는 상관없습니다. 그래도 옮기려면 다음을 실행합니다.

```bash
omarchy bar move io.github.seunghan91.glance-dock --section left
```

## 업데이트

```bash
omarchy plugin update
```

`omarchy plugin update`는 설치된 플러그인을 가져와 diff를 보여 주고 fast-forward합니다.

## 제거

```bash
omarchy plugin remove io.github.seunghan91.glance-dock
```

## 설정

Omarchy 바에서 위젯의 설정으로 바꿉니다.

| 키 | 값 | 기본값 | 의미 |
|---|---|---|---|
| `iconScale` | `small`, `normal`, `large` | `normal` | 바 높이 x 1.08 위에 아이콘을 0.85배, 1배, 1.2배로 조절합니다. |
| `hoverDelayMs` | 0 – 1000 (50 단위) | `250` | 호버 독이 열리기 전에 포인터가 바 위에 머물러야 하는 시간입니다. |
| `edgeDock` | `off`, `left`, `right`, `bottom` | `left` | 엣지 독의 위치입니다. `off`는 바 호버 독만 씁니다. |
| `edgeMode` | `autohide`, `pinned` | `autohide` | `autohide`는 포인터가 화면 가장자리에 닿으면 엣지 독을 밀어 내고(150 ms) 포인터가 떠난 뒤 300 ms 후에 숨깁니다. `pinned`는 계속 보이게 하고 너비를 확보해 타일 창이 비켜 줍니다. |

## 사용법

- **호버 독 열기:** 호버 지연 시간 동안 시계 왼쪽의 바 어디든 포인터를 올려 둡니다. 워크스페이스 번호 위에서는 그 워크스페이스의 앱이, 영역 안의 다른 곳에서는 포커스된 워크스페이스의 앱이 보입니다. 포인터가 영역이나 독 위에 있는 동안 독이 열려 있고 둘 다 벗어난 뒤 120 ms 후에 닫힙니다.
- **창 포커스:** 아이콘을 왼쪽 클릭합니다. 다시 클릭하면 그 앱의 다른 창을 차례로 돌아갑니다. 엣지 독에서는 그 창의 워크스페이스로도 전환합니다.
- **아이콘 우클릭**으로 메뉴를 엽니다. 창 제목을 클릭하면 포커스하고 **Quit**을 클릭하면 메뉴에 나열된 창을 닫습니다. 바 독에서는 해당 워크스페이스의 앱 창이, 엣지 독에서는 모든 워크스페이스의 앱 창이 대상입니다.
- **Force Quit:** 메뉴가 열린 상태에서 **Alt**를 누르고 있으면 Quit이 Force Quit으로 바뀝니다. Alt를 놓으면 되돌아옵니다.
- **메뉴 닫기:** **Esc**를 누르거나 메뉴 바깥을 클릭합니다.

## Quit과 Force Quit의 동작 방식

- **Quit**은 앱의 각 창에 닫기를 요청합니다. 키보드로 창을 닫는 것과 같아서 앱이 저장하지 않은 작업을 물어볼 수 있습니다.
- **Force Quit**은 `hyprctl clients -j`와 `jq`로 각 창의 프로세스 ID를 찾아 **SIGKILL**을 보냅니다. 그 프로세스의 저장하지 않은 작업은 사라지며 여러 창이 한 프로세스를 공유하면(브라우저와 터미널에서 흔함) 그 창이 모두 닫힙니다.

## 알려진 제한

- 우클릭 *전에* Alt를 누른 상태는 감지하지 못해 메뉴가 Quit으로 열립니다. 메뉴가 열린 뒤에 Alt를 누르십시오.
- 멀티 모니터: 다른 모니터의 아무 곳이나 클릭해도 macOS처럼 열린 메뉴가 닫힙니다.
- 모든 모니터를 통틀어 메뉴는 한 번에 하나만 열립니다. 하나를 열면 다른 하나가 닫힙니다.

## 요구 사항

- Quickshell 기반 셸과 플러그인(바 위젯)을 지원하는 Omarchy.
- Hyprland 0.56 (창 포커스와 닫기에 Lua 디스패처 문법 `hl.dsp.*`를 씁니다).
- `hyprctl`(Hyprland에 포함), `jq`(Force Quit), `bash`와 `find`(아이콘 검색). 모두 표준 Omarchy 설치에 들어 있습니다.

## 개인정보와 안전

- 네트워크에 접근하지 않습니다. 외부 명령은 `hyprctl`(포커스, 닫기, 커서 위치, 클라이언트 목록), XDG 아이콘 디렉터리와 `/usr/share/pixmaps`의 로컬 검색, Force Quit용 `kill -KILL`뿐입니다.
- 설정 파일을 쓰거나 수정하지 않습니다. pinned 모드는 독이 실행 중일 때만 layer-shell exclusive zone으로 화면 공간을 확보합니다.
- 창 주소는 셸 명령에 전달되기 전에 16진수인지 검증합니다.
- Force Quit은 창의 프로세스에 SIGKILL을 보냅니다. 위의 설명을 참고하십시오.

## 제작자

**Seunghan**이 설계하고 개발했습니다. GitHub [@seunghan91](https://github.com/seunghan91), [seunghan.xyz](https://seunghan.xyz/omarchy/).
이슈와 풀 리퀘스트를 환영합니다.

## 라이선스

[MIT](LICENSE) © 2026 seunghan91
