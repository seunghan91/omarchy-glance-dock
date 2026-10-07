import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons

// Apple-style dock on the left, right or bottom edge of one screen.
//
// One layer-shell window does both jobs. While hidden, its input mask is a
// 4px strip on the screen edge; touching it for 150ms slides the card in
// (200ms), and the mask grows to the card. Leaving the card hides it again
// after 300ms. In "pinned" mode the card stays out and Hyprland reserves its
// thickness so tiled windows move aside.
//
// It lists every open window on all workspaces, grouped by app; clicking an
// icon focuses that window (switching workspace if needed).
PanelWindow {
  id: edgeDock

  required property QtObject dock
  property string position: "left"      // left | right | bottom
  property string mode: "autohide"      // autohide | pinned

  readonly property bool vertical: position !== "bottom"
  readonly property int pad: 4
  readonly property int gap: 6           // distance from the screen edge
  readonly property int thickness: dock.slotSize + pad * 2
  readonly property int maxLength: vertical
    ? (screen ? screen.height - 120 : 600)
    : (screen ? screen.width - 120 : 800)
  readonly property int contentLength: Math.max(dock.slotSize, (vertical ? column.implicitHeight : row.implicitWidth))
  readonly property int length: Math.min(maxLength, contentLength + pad * 2)
  readonly property bool overflow: contentLength + pad * 2 > maxLength

  // Timers only touch hoverRevealed, so switching to pinned later still
  // shows the dock (assigning `revealed` itself would drop its binding).
  property bool hoverRevealed: false
  // With no windows there is nothing to show; autohide stays tucked away.
  readonly property bool revealed: mode === "pinned" || (hoverRevealed && dock.allGroups.length > 0)

  screen: dock.barWindow ? dock.barWindow.screen : null
  color: "transparent"
  WlrLayershell.namespace: "glance-dock-edge"
  WlrLayershell.layer: WlrLayer.Top
  // Setting exclusiveZone also flips exclusionMode to Normal (Quickshell
  // 0.3.1), so apply both in order instead of as two competing bindings.
  function applyExclusion() {
    exclusiveZone = mode === "pinned" ? thickness + gap : 0
    exclusionMode = mode === "pinned" ? ExclusionMode.Normal : ExclusionMode.Ignore
  }
  onModeChanged: {
    // Drop hover state left over from the other mode, so switching back to
    // autohide starts hidden instead of stuck open.
    showTimer.stop()
    hideTimer.stop()
    hoverRevealed = false
    applyExclusion()
  }
  onThicknessChanged: applyExclusion()
  Component.onCompleted: applyExclusion()

  anchors {
    left: position === "left"
    right: position === "right"
    bottom: position === "bottom"
  }
  implicitWidth: vertical ? thickness + gap : length
  implicitHeight: vertical ? length : thickness + gap

  // Hidden: only the edge strip takes input, so the rest of the screen edge
  // stays clickable. Shown: the whole window, including the gap between the
  // card and the screen edge. Masking to the card alone loses the pointer
  // while the card slides in past it, and nothing would hide the dock again.
  mask: Region { item: edgeDock.revealed ? area : hotStrip }

  Item {
    id: area
    anchors.fill: parent
    HoverHandler {
      id: areaHover
      onHoveredChanged: {
        if (edgeDock.mode === "pinned") return
        if (hovered) hideTimer.stop()
        else if (!hotHover.hovered) hideTimer.restart()
      }
    }
  }

  Item {
    id: hotStrip
    width: edgeDock.vertical ? 4 : parent.width
    height: edgeDock.vertical ? parent.height : 4
    x: edgeDock.position === "right" ? parent.width - width : 0
    y: edgeDock.position === "bottom" ? parent.height - height : 0
    HoverHandler {
      id: hotHover
      onHoveredChanged: {
        if (edgeDock.mode === "pinned") return
        if (hovered) { hideTimer.stop(); showTimer.restart() }
        else {
          showTimer.stop()
          if (edgeDock.revealed && !areaHover.hovered) hideTimer.restart()
        }
      }
    }
  }

  Connections {
    target: edgeDock.dock
    function onMenuOpenChanged() {
      if (!edgeDock.dock.menuOpen && edgeDock.mode !== "pinned" && !areaHover.hovered) hideTimer.restart()
    }
  }

  Timer {
    id: showTimer
    interval: 150
    onTriggered: if (edgeDock.dock.allGroups.length > 0) { edgeDock.hoverRevealed = true; hideTimer.restart() }
  }
  Timer {
    id: hideTimer
    interval: 300
    onTriggered: if (!areaHover.hovered && !hotHover.hovered && !edgeDock.dock.menuOpen) edgeDock.hoverRevealed = false
  }

  Rectangle {
    id: card
    // Inside `area`, so the area's HoverHandler stays hovered while the
    // pointer is over a slot (hover reaches ancestors, not siblings below).
    parent: area
    width: edgeDock.vertical ? edgeDock.thickness : edgeDock.length
    height: edgeDock.vertical ? edgeDock.length : edgeDock.thickness
    color: Color.popups.background
    border.width: 1
    border.color: Color.popups.border
    radius: Style.cornerRadius

    // Resting place: `gap` px in from the screen edge. Hidden: fully past it.
    x: edgeDock.position === "left" ? (edgeDock.revealed ? edgeDock.gap : -width - 2)
      : edgeDock.position === "right" ? (edgeDock.revealed ? 0 : parent.width + 2)
      : 0
    y: edgeDock.position === "bottom" ? (edgeDock.revealed ? 0 : parent.height + 2) : 0
    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }


    Flickable {
      id: scroller
      anchors.fill: parent
      anchors.margins: edgeDock.pad
      anchors.bottomMargin: edgeDock.pad + (edgeDock.vertical && edgeDock.overflow ? 16 : 0)
      anchors.rightMargin: edgeDock.pad + (!edgeDock.vertical && edgeDock.overflow ? 30 : 0)
      clip: true
      contentWidth: edgeDock.vertical ? width : row.implicitWidth
      contentHeight: edgeDock.vertical ? column.implicitHeight : height
      flickableDirection: edgeDock.vertical ? Flickable.VerticalFlick : Flickable.HorizontalFlick
      boundsBehavior: Flickable.StopAtBounds

      WheelHandler {
        onWheel: function(event) {
          var delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
          if (edgeDock.vertical)
            scroller.contentY = Math.max(0, Math.min(scroller.contentHeight - scroller.height, scroller.contentY - delta))
          else
            scroller.contentX = Math.max(0, Math.min(scroller.contentWidth - scroller.width, scroller.contentX - delta))
        }
      }

      Column {
        id: column
        visible: edgeDock.vertical
        Repeater {
          model: edgeDock.vertical ? edgeDock.dock.allGroups : []
          AppSlot {
            required property var modelData
            group: modelData
            dock: edgeDock.dock
            edge: edgeDock.position
          }
        }
      }

      Row {
        id: row
        visible: !edgeDock.vertical
        Repeater {
          model: edgeDock.vertical ? [] : edgeDock.dock.allGroups
          AppSlot {
            required property var modelData
            group: modelData
            dock: edgeDock.dock
            edge: "bottom"
            tipSide: "above"
          }
        }
      }
    }

    // "+N" for icons past the end of the scroll.
    Text {
      readonly property int hidden: {
        var seen = edgeDock.vertical
          ? Math.floor((scroller.contentY + scroller.height + 1) / edgeDock.dock.slotSize)
          : Math.floor((scroller.contentX + scroller.width + 1) / edgeDock.dock.slotSize)
        return Math.max(0, edgeDock.dock.allGroups.length - seen)
      }
      visible: edgeDock.overflow && hidden > 0
      text: "+" + hidden
      textFormat: Text.PlainText
      color: Color.popups.text
      opacity: 0.6
      font.family: edgeDock.dock.bar ? edgeDock.dock.bar.fontFamily : "monospace"
      font.pixelSize: 10
      anchors.horizontalCenter: edgeDock.vertical ? parent.horizontalCenter : undefined
      anchors.bottom: edgeDock.vertical ? parent.bottom : undefined
      anchors.bottomMargin: 3
      anchors.right: edgeDock.vertical ? undefined : parent.right
      anchors.rightMargin: 6
      anchors.verticalCenter: edgeDock.vertical ? undefined : parent.verticalCenter
    }
  }
}
