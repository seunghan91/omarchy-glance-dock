import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Commons
import qs.Ui
import "MenuOwner.js" as MenuOwner

// Glance Dock — hover the bar left of the clock and a row of app icons
// drops down under the pointer. Over a workspace number it shows that
// workspace's windows; anywhere else in the zone, the monitor's active workspace's.
//
// The widget itself takes no space in the bar. It watches the whole bar
// surface through a HoverHandler parented to the bar window's content item,
// so the hover zone spans every widget left of the clock, not just this slot.
BarWidget {
  id: root
  moduleName: "io.github.seunghan91.glance-dock"

  implicitWidth: 0
  implicitHeight: 0
  visible: true

  // ── settings ──
  readonly property real iconScale: ({ small: 0.85, normal: 1.0, large: 1.2 })[setting("iconScale", "normal")] || 1.0
  readonly property int hoverDelay: Math.max(0, Number(setting("hoverDelayMs", 250)) || 0)
  readonly property string edgePosition: ["off", "left", "right", "bottom"].indexOf(setting("edgeDock", "left")) >= 0
    ? setting("edgeDock", "left") : "left"
  readonly property string edgeMode: setting("edgeMode", "autohide") === "pinned" ? "pinned" : "autohide"

  // Icons follow Omarchy's UI scale: the bar height already tracks the font
  // base size (Style.qml), so icon = bar height x 1.08 (28px on a 26px bar).
  readonly property int iconSize: Math.round(root.barSize * 1.08 * root.iconScale)
  readonly property int slotSize: Math.round(root.iconSize * 1.43)
  readonly property int edgeMargin: 8

  // ── bar surface ──
  readonly property var barWindow: root.QsWindow.window
  readonly property Item barContent: barWindow ? barWindow.contentItem : null
  readonly property var barMonitor: barWindow && barWindow.screen ? Hyprland.monitorFor(barWindow.screen) : null
  property real zoneEdge: 0
  onBarContentChanged: root.refreshZoneEdge()

  // Find another bar module by its moduleName. Widgets sit inside Loaders and
  // layout rows, so walk the item tree instead of assuming a fixed depth.
  function findModule(item, name, depth) {
    if (!item || depth > 40) return null
    if (item !== root && item.moduleName === name) return item
    var kids = item.children || []
    for (var i = 0; i < kids.length; i++) {
      var found = findModule(kids[i], name, depth + 1)
      if (found) return found
    }
    return null
  }

  function collectWorkspaceButtons(item, out, depth) {
    if (!item || depth > 20) return out
    if (typeof item.modelData === "number" && item.occupied !== undefined) out.push(item)
    var kids = item.children || []
    for (var i = 0; i < kids.length; i++) collectWorkspaceButtons(kids[i], out, depth + 1)
    return out
  }

  // The zone ends just before the clock. Without a clock, fall back to the
  // left 40% so the dock still works on custom layouts.
  function refreshZoneEdge() {
    if (!barContent) { root.zoneEdge = 0; return }
    var name = root.bar ? root.bar.centerAnchor : ""
    var clock = typeof name === "string" && name.length > 0 ? findModule(barContent, name, 0) : null
    if (!clock || !clock.visible) clock = findModule(barContent, "omarchy.clock", 0)
    root.zoneEdge = clock && clock.visible ? clock.mapToItem(barContent, 0, 0).x - 4 : barContent.width * 0.4
  }

  Connections {
    target: root.barContent
    function onWidthChanged() { root.refreshZoneEdge() }
    function onChildrenChanged() { root.refreshZoneEdge() }
  }

  Connections {
    target: root.barWindow
    function onScreenChanged() { root.refreshZoneEdge() }
  }

  Timer {
    interval: 2000
    running: zoneHover.hovered
    repeat: true
    onTriggered: root.refreshZoneEdge()
  }

  function workspaceAt(x) {
    var ws = findModule(barContent, "omarchy.workspaces", 0)
    if (ws) {
      var buttons = collectWorkspaceButtons(ws, [], 0)
      for (var i = 0; i < buttons.length; i++) {
        var p = buttons[i].mapToItem(barContent, 0, 0)
        if (x >= p.x && x <= p.x + buttons[i].width) return buttons[i].modelData
      }
    }
    if (root.barMonitor && root.barMonitor.activeWorkspace) return root.barMonitor.activeWorkspace.id
    return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
  }

  // ── window data ──
  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) if (values[i].id === id) return values[i]
    return null
  }

  function appIdOf(toplevel) {
    if (toplevel.wayland && toplevel.wayland.appId) return toplevel.wayland.appId
    var ipc = toplevel.lastIpcObject || {}
    return ipc["class"] || ipc.initialClass || ""
  }

  // Icon name from the desktop entry, falling back to the app id itself.
  function iconNameFor(appId) {
    var entry = appId && typeof DesktopEntries.heuristicLookup === "function"
      ? DesktopEntries.heuristicLookup(appId) : null
    return (entry && entry.icon) || appId || ""
  }

  // Qt's themed lookup returns "" for most icons on this desktop, and
  // Omarchy only hands its AppLibrary icon index to "menu" plugins
  // (shell.qml), so build a small index the same way: scan the XDG icon dirs
  // for app icons, prefer SVG, otherwise the largest PNG.
  property var iconIndex: ({})

  Process {
    id: iconScan
    running: true
    command: ["bash", "-c", [
      'dirs=("$HOME/.icons" "$HOME/.local/share/icons");',
      'IFS=: read -r -a xdg <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}";',
      'for d in "${xdg[@]}"; do dirs+=("$d/icons"); done;',
      'for base in "${dirs[@]}"; do [[ -d $base ]] && find "$base" -path "*/apps/*" \\( -name "*.svg" -o -name "*.png" \\) 2>/dev/null; done;',
      'find /usr/share/pixmaps -maxdepth 1 \\( -name "*.svg" -o -name "*.png" \\) 2>/dev/null'
    ].join(" ")]
    stdout: StdioCollector {
      onStreamFinished: {
        var index = {}, rank = {}
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
          var path = lines[i].trim()
          if (!path) continue
          var file = path.substring(path.lastIndexOf("/") + 1)
          var dot = file.lastIndexOf(".")
          var name = file.substring(0, dot)
          var size = /\/(\d+)x\d+\//.exec(path)
          var score = file.substring(dot) === ".svg" ? 100000 : (size ? Number(size[1]) : 1)
          if (path.indexOf("/symbolic/") !== -1 || name.indexOf("-symbolic") !== -1) score = 0
          if (rank[name] === undefined || score > rank[name]) { rank[name] = score; index[name] = path }
        }
        root.iconIndex = index
      }
    }
  }

  function iconSource(name) {
    var candidates = [name, String(name || "").toLowerCase(), "application-x-executable"]
    for (var i = 0; i < candidates.length; i++) {
      var c = candidates[i]
      if (!c) continue
      if (root.iconIndex[c]) return "file://" + root.iconIndex[c]
      var themed = Quickshell.iconPath(c, true)
      if (themed.length > 0) return themed
    }
    return ""
  }

  function nameFor(appId, toplevel) {
    var entry = appId && typeof DesktopEntries.heuristicLookup === "function"
      ? DesktopEntries.heuristicLookup(appId) : null
    return (entry && entry.name) || appId || toplevel.title || "Window"
  }

  // One icon per app; several windows of the same app share an icon with a
  // count badge, and repeated clicks cycle through them.
  function groupsFor(wsId) {
    var ws = workspaceById(wsId)
    return ws ? groupsOf(ws.toplevels.values) : []
  }

  // Shell surfaces that are windows to Hyprland but not apps to the user.
  readonly property var hiddenAppIds: ["org.omarchy.screensaver"]

  function groupsOf(tops) {
    var order = [], byApp = {}
    var missing = 0
    for (var i = 0; i < tops.length; i++) {
      var t = tops[i]
      var appId = appIdOf(t)
      if (!appId) { missing++; continue }
      if (root.hiddenAppIds.indexOf(appId) !== -1) continue
      var id = appId
      if (!byApp[id]) {
        byApp[id] = { appId: id, name: nameFor(id, t), iconName: iconNameFor(id), windows: [] }
        order.push(id)
      }
      byApp[id].windows.push(t)
    }
    root.unresolved = missing
    return order.map(function(id) { return byApp[id] })
  }

  // Hyprland addresses are hex; refuse anything else before it reaches a shell.
  function addressOf(toplevel) {
    if (!toplevel) return ""
    var addr = String(toplevel.address || "")
    if (addr.indexOf("0x") !== 0) addr = "0x" + addr
    return /^0x[0-9a-fA-F]+$/.test(addr) ? addr : ""
  }

  function focusWindow(toplevel) {
    var addr = addressOf(toplevel)
    if (!addr || !root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ window = \"address:" + addr + "\" })"))
  }

  // Quit asks each of the app's windows to close, like Super+W, so apps can
  // still prompt about unsaved work. Force Quit kills the owning processes.
  function quitApp(group, force) {
    if (!root.bar || !group) return
    for (var i = 0; i < group.windows.length; i++) {
      var addr = addressOf(group.windows[i])
      if (!addr) continue
      if (force)
        root.bar.run("pid=$(hyprctl clients -j | jq -r '.[] | select(.address == \"" + addr + "\") | .pid'); "
          + "[[ $pid =~ ^[0-9]+$ ]] && kill -KILL \"$pid\"")
      else
        root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.window.close({ window = \"address:" + addr + "\" })"))
    }
  }

  // ── context menu ──
  // One overlay per bar (MenuOverlay.qml). Both docks stay out while it is
  // open. The menu opens at the pointer, read from Hyprland because the
  // overlay has not seen the pointer yet when it maps.
  property bool menuOpen: false
  property bool menuReady: false
  property var menuGroup: null
  property string menuSide: "below"     // where the menu opens from the pointer
  property bool menuForce: false
  property real menuX: 0                // pointer, relative to the bar's screen
  property real menuY: 0
  // A menu under the top dock starts below its card: the dock is a popup of
  // the bar and draws above the overlay.
  readonly property real menuFloor: root.barWindow ? root.barWindow.height + Style.gapsOut + dock.implicitHeight + 4 : 0

  function openMenu(group, side, force) {
    if (!group) return
    MenuOwner.claim(root)
    root.menuGroup = group
    root.menuSide = side || "below"
    root.menuForce = !!force
    root.menuReady = false
    root.menuOpen = true
    cursorProc.running = false
    cursorProc.running = true
  }
  function closeMenu() {
    root.menuOpen = false
    root.menuReady = false
    root.menuGroup = null
    MenuOwner.release(root)
  }

  // The menu lists the windows it was opened with. Drop the ones that have
  // closed since; once none are left, close the menu so its full-screen
  // overlay stops catching input.
  function pruneMenu() {
    if (!root.menuGroup) return
    var live = {}
    var tops = Hyprland.toplevels.values
    for (var i = 0; i < tops.length; i++) live[addressOf(tops[i])] = true
    var kept = root.menuGroup.windows.filter(function(w) { return live[addressOf(w)] === true })
    if (kept.length === 0) { root.closeMenu(); return }
    if (kept.length !== root.menuGroup.windows.length)
      root.menuGroup = Object.assign({}, root.menuGroup, { windows: kept })
  }
  Process {
    id: cursorProc
    command: ["hyprctl", "cursorpos"]
    stdout: StdioCollector {
      onStreamFinished: {
        var s = root.barWindow ? root.barWindow.screen : null
        var m = /(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)/.exec(text)
        if (m) {
          root.menuX = Number(m[1]) - (s ? s.x : 0)
          root.menuY = Number(m[2]) - (s ? s.y : 0)
        } else {
          console.warn("glance-dock: hyprctl cursorpos gave", JSON.stringify(text))
          root.menuX = s ? s.width / 2 : 0
          root.menuY = s ? s.height / 2 : 0
        }
        if (root.menuOpen) root.menuReady = true
      }
    }
  }

  Loader {
    active: root.barWindow !== null
    sourceComponent: MenuOverlay { dock: root }
  }

  // A menu is open on another monitor: a click anywhere on this screen
  // closes it, as on macOS. The menu's overlay only covers its own screen.
  property bool remoteMenuOpen: false
  Loader {
    active: root.remoteMenuOpen && root.barWindow !== null
    sourceComponent: PanelWindow {
      screen: root.barWindow ? root.barWindow.screen : null
      color: "transparent"
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "glance-dock-menu-catcher"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: MenuOwner.closeOwner()
      }
    }
  }

  // Every open window on every workspace, for the edge dock.
  property var allGroups: []
  // A new toplevel's Wayland handle (and so its app id) attaches a moment
  // after Hyprland announces it, and lastIpcObject stays empty. Regroup on a
  // short timer until every window has an app id, so it neither shows as a
  // blank slot nor misses its app's group.
  property int unresolved: 0
  property int regroupTries: 0
  function refreshAll() {
    root.allGroups = root.groupsOf(Hyprland.toplevels.values)
    root.pruneMenu()
    if (root.unresolved > 0 && root.regroupTries < 40) { root.regroupTries++; regroupTimer.restart() }
    else root.regroupTries = 0
  }
  Timer {
    id: regroupTimer
    interval: 250
    onTriggered: {
      root.refreshAll()
      if (root.open) root.groups = root.groupsFor(root.shownWorkspace)
    }
  }

  Connections {
    target: Hyprland.toplevels
    function onValuesChanged() { root.refreshAll() }
  }

  // Moving a window to another workspace or closing it does not always change
  // the global toplevel list the dock was built from, so rebuild on the
  // compositor's window events too (debounced through regroupTimer).
  Connections {
    target: Hyprland
    // Switching workspace by keyboard while the dock is open over the bar
    // (outside the workspace numbers) should follow the new workspace.
    function onFocusedWorkspaceChanged() {
      if (root.open && root.inZone) root.show(root.workspaceAt(root.pointerX))
    }
    function onRawEvent(event) {
      var name = event ? event.name : ""
      if (/^(openwindow|closewindow|movewindow|movewindowv2|activewindow|activewindowv2|windowtitle|windowtitlev2)$/.test(name)) {
        root.regroupTries = 0
        regroupTimer.restart()
      }
    }
  }
  // With several monitors, this bar's monitor can switch workspace while focus
  // stays on another monitor, so focusedWorkspace never changes. Follow it too.
  Connections {
    target: root.barMonitor
    ignoreUnknownSignals: true
    function onActiveWorkspaceChanged() {
      if (root.open && root.inZone) root.show(root.workspaceAt(root.pointerX))
    }
  }
  Component.onCompleted: { root.refreshZoneEdge(); Hyprland.refreshToplevels(); root.refreshAll(); MenuOwner.register(root) }

  Loader {
    active: root.edgePosition !== "off" && root.barWindow !== null
    sourceComponent: EdgeDock {
      dock: root
      position: root.edgePosition
      mode: root.edgeMode
    }
  }

  // ── hover state ──
  property real pointerX: 0
  property int shownWorkspace: -1
  property var groups: []
  property bool open: false
  property real dockX: 0
  property real dockCentre: 0   // pointer x where the dock was last shown

  readonly property bool inZone: zoneHover.hovered && root.pointerX < root.zoneEdge
  readonly property bool keepOpen: root.inZone || dockHover.hovered || root.menuOpen

  function show(wsId) {
    Hyprland.refreshToplevels()
    root.shownWorkspace = wsId
    root.groups = root.groupsFor(wsId)
    if (root.unresolved > 0) regroupTimer.restart()
    root.dockCentre = root.pointerX
    root.place()
    // The row re-lays out after `groups` changes; place again with its width.
    Qt.callLater(root.place)
  }

  // Centre the dock on the pointer, then slide it inward at the screen edges.
  function place() {
    if (!barContent) return
    var w = dock.implicitWidth
    var x = root.dockCentre - w / 2
    root.dockX = Math.max(root.edgeMargin, Math.min(x, barContent.width - root.edgeMargin - w))
  }

  // Reparenting a pointer handler also moves its QObject ownership, so hand
  // it back before this widget goes away; otherwise reloads would leave
  // handlers piling up on the bar.
  Component.onDestruction: { zoneHover.parent = root; MenuOwner.unregister(root) }

  HoverHandler {
    id: zoneHover
    parent: root.barContent
    onHoveredChanged: if (hovered) root.refreshZoneEdge()
    onPointChanged: {
      root.pointerX = point.position.x
      if (root.open && root.inZone) {
        var ws = root.workspaceAt(root.pointerX)
        if (ws !== root.shownWorkspace) root.show(ws)
      }
    }
  }

  onKeepOpenChanged: {
    if (root.keepOpen) {
      closeTimer.stop()
      if (!root.open && root.inZone) openTimer.restart()
    } else {
      openTimer.stop()
      closeTimer.restart()
    }
  }

  Timer {
    id: openTimer
    interval: root.hoverDelay
    onTriggered: if (root.inZone) { root.show(root.workspaceAt(root.pointerX)); root.open = true }
  }

  Timer {
    id: closeTimer
    interval: 120
    onTriggered: if (!root.keepOpen) { root.open = false; root.shownWorkspace = -1 }
  }

  Connections {
    target: Hyprland.workspaces
    function onValuesChanged() { if (root.open) root.show(root.shownWorkspace) }
  }

  // ── the dock ──
  PopupWindow {
    id: dock
    visible: root.open || card.opacity > 0
    color: "transparent"

    readonly property int padding: 4
    readonly property int maxWidth: root.barContent ? root.barContent.width - root.edgeMargin * 2 : 600
    readonly property int contentWidth: root.groups.length ? row.implicitWidth : emptyWidth
    readonly property int emptyWidth: 150
    // Reserve room for "+N" only when the row is wider than the screen allows;
    // deriving it from the scroll position would loop through the width.
    readonly property bool overflow: row.implicitWidth + padding * 2 > maxWidth
    readonly property int moreArea: overflow ? 30 : 0
    implicitWidth: Math.min(maxWidth, contentWidth + padding * 2)
    implicitHeight: root.slotSize + padding * 2
    onImplicitWidthChanged: root.place()

    anchor {
      window: root.barWindow
      adjustment: PopupAdjustment.Slide
      edges: Edges.Top | Edges.Left
      gravity: Edges.Bottom | Edges.Right
      rect.x: root.dockX
      rect.y: root.barWindow ? root.barWindow.height + Style.gapsOut : 0
      rect.width: 1
      rect.height: 1
    }

    HoverHandler { id: dockHover }

    Rectangle {
      id: card
      anchors.fill: parent
      color: Color.popups.background
      border.width: 1
      border.color: Color.popups.border
      radius: Style.cornerRadius
      opacity: root.open ? 1 : 0
      transform: Translate { y: root.open ? 0 : -8 }
      Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

      Flickable {
        id: scroller
        anchors.fill: parent
        anchors.margins: dock.padding
        anchors.rightMargin: dock.padding + dock.moreArea
        clip: true
        contentWidth: row.implicitWidth
        contentHeight: height
        flickableDirection: Flickable.HorizontalFlick
        boundsBehavior: Flickable.StopAtBounds

        // A vertical wheel scrolls the row sideways.
        WheelHandler {
          onWheel: function(event) {
            var delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
            scroller.contentX = Math.max(0, Math.min(scroller.contentWidth - scroller.width, scroller.contentX - delta))
          }
        }

        Row {
          id: row
          height: parent.height
          opacity: root.groups.length > 0 ? 1 : 0

          Repeater {
            model: root.groups

            AppSlot {
              required property var modelData
              group: modelData
              dock: root
              edge: "bottom"
            }
          }
        }

      }

      // Outside the Flickable: an empty row has no content width to centre in.
      Text {
        anchors.centerIn: parent
        visible: root.groups.length === 0
        text: "No open windows"
        textFormat: Text.PlainText
        color: Color.popups.text
        opacity: 0.6
        font.family: root.bar ? root.bar.fontFamily : "monospace"
        font.pixelSize: 11
      }

      // "+N" for icons past the right edge.
      Text {
        id: moreLabel
        readonly property int hidden: {
          var visibleSlots = Math.floor((scroller.contentX + scroller.width + 1) / root.slotSize)
          return Math.max(0, root.groups.length - visibleSlots)
        }
        anchors.right: parent.right
        anchors.rightMargin: dock.padding
        anchors.verticalCenter: parent.verticalCenter
        width: dock.moreArea
        horizontalAlignment: Text.AlignHCenter
        visible: dock.overflow && hidden > 0
        text: "+" + hidden
        textFormat: Text.PlainText
        color: Color.popups.text
        opacity: 0.6
        font.family: root.bar ? root.bar.fontFamily : "monospace"
        font.pixelSize: 10
      }
    }
  }
}
