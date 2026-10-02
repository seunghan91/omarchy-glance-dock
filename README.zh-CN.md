# Glance Dock

[English](README.md) · [한국어](README.ko.md) · [日本語](README.ja.md) · **简体中文** · [Español](README.es.md) · [Deutsch](README.de.md) · [Français](README.fr.md) · [Português (BR)](README.pt-BR.md) · [Русский](README.ru.md)

作者 **Seunghan**（[@seunghan91](https://github.com/seunghan91)）· [项目主页](https://seunghan.xyz/omarchy/glance-dock/)

Omarchy shell 的已打开应用 Dock。将指针停在时钟左侧的状态栏上，一排应用图标会立即在其正下方落下：指针在工作区编号上时，显示该工作区的窗口；在区域内的其他位置时，显示当前聚焦工作区的窗口。另有可选的 Apple 风格边缘 Dock，可放在屏幕左侧、右侧或底部，列出所有工作区中已打开的全部应用。两种 Dock 共用同一个右键菜单，菜单中列出该应用的窗口以及 Quit / Force Quit。

![演示：状态栏 Dock 在指针下方落下并跟随工作区编号切换，随后是边缘 Dock 及其带有 Quit 和 Force Quit 的右键菜单](docs/glance-dock-demo.gif)

![左侧边缘 Dock 及工具提示](docs/glance-dock-edge.png)

| 状态栏悬停 Dock | 右键菜单 |
|---|---|
| ![工作区编号下方的悬停 Dock](docs/glance-dock-top.png) | ![窗口列表和 Quit](docs/glance-dock-menu.png) |

## 功能

- **状态栏悬停 Dock。** 该组件本身不占用空间，而是监视从状态栏左边缘到时钟之间的整个区域。如果状态栏没有时钟，则监视区域为状态栏左侧 40%。
- **按工作区预览。** 悬停在工作区编号上会显示该工作区的应用；沿着编号移动时，Dock 会实时切换。指针位于编号之外的状态栏上时，在 Dock 打开的状态下用键盘切换工作区，Dock 会跟随到新的工作区。
- **边缘 Dock（可选）。** 在左侧、右侧或底部边缘列出所有工作区中已打开的全部窗口。`autohide` 在指针触碰边缘时滑入；`pinned` 则保持显示并预留其空间，使平铺窗口自动让开。
- **每个应用一个图标。** 同一应用的多个窗口共用一个图标，并带有数量角标。点击图标会聚焦一个窗口；再次点击则在该应用的窗口之间循环切换。
- **活动标记与工具提示。** 拥有当前聚焦窗口的应用会显示强调色线条；在图标上悬停 400 ms 会显示应用名称和窗口数量。
- **右键菜单** 列出该应用的窗口（当前活动窗口带标记），其后是 **Quit**。菜单打开时按住 **Alt**，即可将其变为 **Force Quit**。
- **溢出处理。** 过长的图标行可用鼠标滚轮滚动，并以 `+N` 显示超出末尾的图标数量。
- **图标跟随状态栏。** 图标大小为状态栏高度 x 1.08，再按图标大小设置缩放，因此会跟随 Omarchy 的 UI 缩放。

## 安装

```bash
omarchy plugin add https://github.com/seunghan91/omarchy-glance-dock --enable
```

该组件声明 `left` 为默认区段。它不会在状态栏中绘制任何内容，因此在区段中的位置无关紧要。如仍想移动它：

```bash
omarchy bar move io.github.seunghan91.glance-dock --section left
```

## 更新

```bash
omarchy plugin update
```

`omarchy plugin update` 会拉取已安装的插件，显示差异并快进更新。

## 卸载

```bash
omarchy plugin remove io.github.seunghan91.glance-dock
```

## 设置

在 Omarchy 状态栏中该组件的设置里修改这些选项。

| 键 | 取值 | 默认值 | 含义 |
|---|---|---|---|
| `iconScale` | `small`、`normal`、`large` | `normal` | 在状态栏高度 x 1.08 的基础上，将图标缩放为 0.85、1 或 1.2 倍。 |
| `hoverDelayMs` | 0 – 1000（步长 50） | `250` | 指针在状态栏上停留多久后打开悬停 Dock。 |
| `edgeDock` | `off`、`left`、`right`、`bottom` | `left` | 边缘 Dock 的位置；设为 `off` 则只使用状态栏悬停 Dock。 |
| `edgeMode` | `autohide`、`pinned` | `autohide` | `autohide` 在指针触碰屏幕边缘时滑入边缘 Dock（150 ms），并在指针离开 300 ms 后隐藏。`pinned` 则保持可见并预留其宽度，使平铺窗口自动让开。 |

## 使用方法

- **打开悬停 Dock：** 将指针停在时钟左侧状态栏的任意位置，达到悬停延迟后即可打开。在工作区编号上会看到该工作区的应用；在区域内的其他位置，则是当前聚焦工作区的应用。指针位于该区域或 Dock 上时，Dock 保持打开；指针离开两者 120 ms 后关闭。
- **聚焦窗口：** 左键点击图标。再次点击可在该应用的其他窗口之间循环。从边缘 Dock 点击时，也会切换到该窗口所在的工作区。
- **右键点击图标** 打开菜单：点击窗口标题可聚焦该窗口，点击 **Quit** 则关闭菜单中列出的窗口。在状态栏 Dock 上，这是该应用在当前工作区的窗口；在边缘 Dock 上，则是所有工作区中的窗口。
- **Force Quit：** 菜单打开时按住 **Alt**，Quit 就会变成 Force Quit。松开 Alt 即切换回来。
- **关闭菜单：** 按 **Esc**，或点击菜单之外的任意位置。

## Quit 与 Force Quit 的工作方式

- **Quit** 会请求该应用的每个窗口关闭，效果与用键盘关闭窗口相同，因此应用仍可就未保存的内容进行提示。
- **Force Quit** 通过 `hyprctl clients -j` 和 `jq` 查出每个窗口的进程 ID，并向其发送 **SIGKILL**。该进程中未保存的内容会丢失；如果多个窗口共用同一个进程（浏览器和终端中很常见），这些窗口会全部关闭。

## 已知限制

- 在右键点击之前就按住 Alt 不会被检测到，菜单会以 Quit 打开。请在菜单打开后再按 Alt。
- 多显示器：菜单打开时，Hyprland 不会把另一个显示器上的点击传给菜单，因此在那里点击不会关闭菜单。请按 **Esc**。
- 所有显示器上同一时间只会打开一个菜单；打开新菜单会关闭另一个。

## 要求

- 带有基于 Quickshell 的 shell 且支持插件（状态栏组件）的 Omarchy。
- Hyprland 0.56（窗口聚焦和关闭使用 Lua dispatcher 语法 `hl.dsp.*`）。
- `hyprctl`（随 Hyprland 提供）、`jq`（Force Quit 使用）、`bash` 和 `find`（图标查找使用）。标准 Omarchy 安装中均已具备。

## 隐私与安全

- 不访问网络。仅调用的外部命令有：`hyprctl`（聚焦、关闭、光标位置、客户端列表）、对 XDG 图标目录和 `/usr/share/pixmaps` 的本地扫描，以及用于 Force Quit 的 `kill -KILL`。
- 不会写入或修改你的任何配置文件。pinned 模式仅在 Dock 运行期间，通过 layer-shell 独占区域预留屏幕空间。
- 窗口地址在传给 shell 命令之前会先校验为十六进制。
- Force Quit 会向窗口的进程发送 SIGKILL；详见上文。

## 作者

由 **Seunghan** 设计开发 — GitHub [@seunghan91](https://github.com/seunghan91)、[seunghan.xyz](https://seunghan.xyz/omarchy/)。
欢迎提交 Issue 和 Pull Request。

## 许可证

[MIT](LICENSE) © 2026 seunghan91
