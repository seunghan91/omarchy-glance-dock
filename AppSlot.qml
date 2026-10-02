import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Commons

// One app in a dock: icon, active marker, window-count badge, tooltip and
// click-to-focus. Shared by the bar hover dock and the edge dock.
//
// `dock` is the Main.qml widget (icon lookup, focus, bar tooltip API).
// `edge` says which side the active marker sits on: "bottom" for a
// horizontal row, "left"/"right" for a vertical column (the inner side).
Item {
  id: slot

  required property var group
  required property QtObject dock
  property string edge: "bottom"
  // Where the tooltip opens: away from the screen edge the dock sits on.
  property string tipSide: edge === "left" ? "right" : edge === "right" ? "left" : "below"
  property int cycle: 0

  readonly property int iconSize: dock.iconSize
  readonly property int slotSize: dock.slotSize

  // HyprlandToplevel.activated stays false here, and Hyprland.activeToplevel
  // is null until the next focus event after the shell starts; the Wayland
  // toplevel manager knows the active window right away.
  readonly property bool active: group.windows.some(function(w) {
    if (ToplevelManager.activeToplevel && w.wayland === ToplevelManager.activeToplevel) return true
    return Hyprland.activeToplevel !== null && w.address === Hyprland.activeToplevel.address
  })

  width: slotSize
  height: slotSize

  Rectangle {
    anchors.fill: parent
    color: Color.popups.text
    opacity: hover.hovered ? 0.08 : 0
  }

  IconImage {
    id: icon
    anchors.centerIn: parent
    implicitSize: slot.iconSize
    source: slot.dock.iconSource(slot.group.iconName)
    asynchronous: true
  }

  // No icon anywhere (not even the generic fallback in this icon theme):
  // show the app's initial so the slot is not blank.
  Rectangle {
    visible: icon.source == "" || icon.status === Image.Error
    anchors.centerIn: parent
    width: slot.iconSize
    height: slot.iconSize
    radius: Math.round(slot.iconSize * 0.22)
    color: Color.popups.text
    opacity: 0.12
  }
  Text {
    visible: icon.source == "" || icon.status === Image.Error
    anchors.centerIn: parent
    text: String(slot.group.name || slot.group.appId || "?").charAt(0).toUpperCase()
    color: Color.popups.text
    font.family: slot.dock.bar ? slot.dock.bar.fontFamily : "monospace"
    font.pixelSize: Math.round(slot.iconSize * 0.5)
    font.bold: true
  }

  // Active window: a 2px accent line covering 55% of the slot, the same
  // language as the bar's open-panel marker.
  Rectangle {
    visible: slot.active
    readonly property bool horizontal: slot.edge === "bottom"
    width: horizontal ? parent.width * 0.55 : 2
    height: horizontal ? 2 : parent.height * 0.55
    x: horizontal ? (parent.width - width) / 2 : (slot.edge === "left" ? parent.width - width - 2 : 2)
    y: horizontal ? parent.height - height - 2 : (parent.height - height) / 2
    color: Color.accent
    opacity: 0.9
  }

  Rectangle {
    visible: slot.group.windows.length > 1
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.margins: 2
    width: Math.max(height, badge.implicitWidth + 6)
    height: Math.round(slot.slotSize * 0.32)
    color: Color.popups.background
    border.width: 1
    border.color: Color.popups.border
    Text {
      id: badge
      anchors.centerIn: parent
      text: slot.group.windows.length
      color: Color.popups.text
      font.family: slot.dock.bar ? slot.dock.bar.fontFamily : "monospace"
      font.pixelSize: Math.max(8, Math.round(slot.slotSize * 0.22))
    }
  }

  HoverHandler { id: hover }

  // The bar's tooltip only serves items inside the bar window, and these
  // slots live in the dock windows, so the dock draws its own: after 400ms,
  // beside the slot on the side away from the screen edge.
  Timer { id: tipDelay; interval: 400; running: hover.hovered }
  PopupWindow {
    visible: hover.hovered && !tipDelay.running && !slot.dock.menuOpen && slot.QsWindow.window !== null
    color: "transparent"
    // Never take the pointer: the tooltip sits over the dock's hover area,
    // and stealing the pointer would read as leaving the dock.
    mask: Region {}
    implicitWidth: tipText.implicitWidth + 20
    implicitHeight: tipText.implicitHeight + 12
    anchor {
      item: slot
      readonly property int side: slot.tipSide === "right" ? Edges.Right
        : slot.tipSide === "left" ? Edges.Left
        : slot.tipSide === "above" ? Edges.Top : Edges.Bottom
      edges: side
      gravity: side
      adjustment: PopupAdjustment.Slide
      margins.left: slot.tipSide === "right" ? 6 : 0
      margins.right: slot.tipSide === "left" ? 6 : 0
      margins.top: slot.tipSide === "below" ? 6 : 0
      margins.bottom: slot.tipSide === "above" ? 6 : 0
    }
    Rectangle {
      anchors.fill: parent
      color: Color.popups.background
      border.width: 1
      border.color: Color.popups.border
      Text {
        id: tipText
        anchors.centerIn: parent
        text: slot.group.name + (slot.group.windows.length > 1 ? " · " + slot.group.windows.length : "")
        color: Color.popups.text
        font.family: slot.dock.bar ? slot.dock.bar.fontFamily : "monospace"
        font.pixelSize: 12
      }
    }
  }


  // ── context menu (right click) ──
  // The menu itself is one full-screen overlay per bar (MenuOverlay.qml),
  // so it can take the keyboard (Esc, Option for Force Quit) and close on a
  // click anywhere else. Option held while right-clicking starts it as
  // Force Quit when the compositor reports the modifier.
  TapHandler {
    id: rightTap
    acceptedButtons: Qt.RightButton
    onTapped: slot.dock.openMenu(slot.group, slot.tipSide, (rightTap.point.modifiers & Qt.AltModifier) !== 0)
  }

  // Repeated clicks cycle through the app's windows.
  TapHandler {
    acceptedButtons: Qt.LeftButton
    onTapped: {
      var wins = slot.group.windows.filter(function(w) { return w !== null && w !== undefined })
      if (wins.length === 0) return
      slot.dock.focusWindow(wins[slot.cycle % wins.length])
      slot.cycle++
    }
  }
}
