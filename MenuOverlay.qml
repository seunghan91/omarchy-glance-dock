import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons

// The right-click menu for both docks, like the macOS Dock: the app's
// windows, then Quit. Holding Option (Alt) turns Quit into Force Quit.
//
// It is a transparent full-screen overlay with exclusive keyboard focus, so
// Escape and Option reach it and a click anywhere outside the box closes it.
// The docks have no keyboard focus and a popup's focus grab never saw these
// keys, which is why the menu is not a popup of the slot.
PanelWindow {
  id: overlay

  required property QtObject dock
  readonly property var group: dock.menuGroup
  property bool force: false

  screen: dock.barWindow ? dock.barWindow.screen : null
  visible: dock.menuOpen && dock.menuReady && group !== null
  color: "transparent"
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: "glance-dock-menu"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  onVisibleChanged: {
    if (!visible) return
    overlay.force = overlay.dock.menuForce
    Qt.callLater(function() { if (overlay.visible) keys.forceActiveFocus() })
  }

  function clamp(v, lo, hi) { return Math.max(lo, Math.min(v, hi)) }

  // Anywhere outside the box: close.
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
    onPressed: overlay.dock.closeMenu()
  }

  Item {
    id: keys
    anchors.fill: parent
    focus: true
    Keys.onPressed: function(event) {
      if (event.key === Qt.Key_Escape) { overlay.dock.closeMenu(); event.accepted = true }
      else if (event.key === Qt.Key_Alt || (event.modifiers & Qt.AltModifier)) overlay.force = true
    }
    Keys.onReleased: function(event) {
      if (event.key === Qt.Key_Alt) overlay.force = false
    }
  }

  // Opens away from the dock's screen edge, beside the pointer.
  Rectangle {
    id: box
    readonly property string side: overlay.dock.menuSide
    readonly property real px: overlay.dock.menuX
    readonly property real py: overlay.dock.menuY
    // Fixed width; long window titles elide.
    width: 220
    height: menuColumn.implicitHeight + 2
    x: overlay.clamp(side === "right" ? px + 6 : side === "left" ? px - 6 - width : px - width / 2,
      4, Math.max(4, overlay.width - width - 4))
    y: overlay.clamp(side === "above" ? py - 6 - height : side === "below" ? Math.max(py + 6, overlay.dock.menuFloor) : py - 13,
      4, Math.max(4, overlay.height - height - 4))
    color: Color.popups.background
    border.width: 1
    border.color: Color.popups.border

    // Clicks on the box itself (border, separator) stay inside the menu.
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

    Column {
      id: menuColumn
      x: 1
      y: 1
      width: box.width - 2

      component MenuRow: Rectangle {
        id: menuRow
        property string label: ""
        property bool checked: false
        property bool strong: false
        signal activated()
        width: parent ? parent.width : 180
        height: 26
        color: Color.popups.background
        Rectangle { anchors.fill: parent; color: Color.popups.text; opacity: rowMouse.containsMouse ? 0.08 : 0 }
        Text {
          id: rowText
          anchors.verticalCenter: parent.verticalCenter
          x: 10
          width: parent.width - 20
          elide: Text.ElideRight
          text: (menuRow.checked ? "• " : "  ") + menuRow.label
          color: Color.popups.text
          font.family: overlay.dock.bar ? overlay.dock.bar.fontFamily : "monospace"
          font.pixelSize: 12
          font.bold: menuRow.strong
        }
        MouseArea {
          id: rowMouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: menuRow.activated()
        }
      }

      // With many windows the list scrolls inside the screen, so Quit below
      // it always stays in reach.
      Flickable {
        id: windowList
        width: parent.width
        height: Math.min(windowRows.implicitHeight, Math.max(26, overlay.height - 8 - 2 - 1 - 26))
        contentHeight: windowRows.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
          id: windowRows
          width: windowList.width

          Repeater {
            model: overlay.group ? overlay.group.windows : []
            MenuRow {
              required property var modelData
              label: modelData && modelData.title ? modelData.title : (overlay.group ? overlay.group.name : "")
              checked: !!modelData && ((ToplevelManager.activeToplevel && modelData.wayland === ToplevelManager.activeToplevel)
                || (Hyprland.activeToplevel !== null && modelData.address === Hyprland.activeToplevel.address))
              onActivated: { var w = modelData; overlay.dock.closeMenu(); overlay.dock.focusWindow(w) }
            }
          }
        }
      }

      Rectangle { width: parent.width; height: 1; color: Color.popups.border; opacity: 0.5 }

      MenuRow {
        label: overlay.force ? "Force Quit" : "Quit"
        strong: overlay.force
        onActivated: { var g = overlay.group; var f = overlay.force; overlay.dock.closeMenu(); overlay.dock.quitApp(g, f) }
      }
    }
  }
}
