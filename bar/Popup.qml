import QtQuick
import Quickshell

// Popup — a popup of the bar.
//
// A popup has to live inside a window, so the module that shows it owns it
// and the popup finds the window through the module it is anchored to. The
// popup knows how to anchor itself below its module and how it looks, so a
// module only has to fill it with content:
//
//     Popup {
//         contentWidth: 200
//         contentHeight: 100
//         Text { anchors.centerIn: parent }
//     }
//
// The popup is opened with show() and closed with hide(), never by setting
// its visibility: a popup grows out of the bar when it opens and shrinks
// back into it when it closes. A popup that should not animate, a tooltip,
// has a duration of zero.
//
// The popup is a window of its own below the bar, so the pointer has to
// travel from the module into the popup: the module loses the hover before
// the popup gets it. A popup that closed on that would vanish before the
// pointer could reach it, so the popup stays open while the pointer is over
// the module or over the popup and closes when it is over neither.
PopupWindow {
    id: popup

    // The window the popup belongs to. The popup takes it from the module
    // it is anchored to, so a module does not have to hand it over.
    readonly property var barWindow: target ? target.QsWindow.window : null

    // The module the popup is anchored to.
    property Module target: null

    // A tooltip is shown above the bar on its own; it does not own the
    // popup layer, so it does not keep the tooltip of another module away.
    property bool isTooltip: false

    // The close delay and the reopen transitions.
    readonly property PopupState state: popupState

    // The radius of the frame around the content.
    property int radius: 12

    // The size of the content of the popup.
    property int contentWidth: 0
    property int contentHeight: 0

    // How long the popup takes to open and to close, in milliseconds.
    property int duration: 150

    // How far the popup is open, from 0 (closed) to 1 (open). The frame
    // grows from the middle of its top edge, the place the popup is
    // anchored to.
    property real progress: 0

    // The content of the popup.
    default property alias content: holder.data

    color: "transparent"
    visible: false

    // The size of the popup. It never changes while the popup is open, a
    // window that is resized is drawn again from scratch and that looks
    // like a flicker.
    implicitWidth: popup.contentWidth
    implicitHeight: popup.contentHeight

    Behavior on progress {
        Motion { time: popup.duration }
    }

    // Open the popup. A close that is still waiting for its delay is
    // cancelled, so reopening a popup within the delay keeps it open.
    function show() {
        exitTimer.stop()
        popupState.show()
        popup.claimLayer()
        popup.visible = true
        popup.progress = 1
    }

    // Close the popup. The popup shrinks back into the bar and the window is
    // hidden when it has shrunk. A popup that does not animate its exit, or
    // does not animate at all, is hidden at once.
    function hide() {
        popupState.hide()
        if (!Settings.popupExitAnimation || popup.duration <= 0) {
            exitTimer.stop()
            popup.visible = false
            popup.progress = 0
            popup.releaseLayer()
            return
        }
        popup.progress = 0
        exitTimer.restart()
    }

    // Tell the bar that a module popup owns the layer in front of it. The
    // tooltip asks the bar before it shows, so a tip never draws over an
    // open popup, even when the pointer moves back over the module.
    function claimLayer() {
        if (popup.isTooltip)
            return
        const window = popup.barWindow
        if (window && window.activePopup !== undefined)
            window.activePopup = popup
    }

    // The popup no longer covers the layer. Only the popup that owns the
    // layer clears it, so the exit of an old popup cannot hide the tip of a
    // popup that opened after it.
    function releaseLayer() {
        if (popup.isTooltip)
            return
        const window = popup.barWindow
        if (window && window.activePopup === popup)
            window.activePopup = null
    }

    // The close delay expired: close the popup.
    PopupState {
        id: popupState
        closeDelay: 150
        onCloseRequested: popup.hide()
    }

    // The popup has shrunk back into the bar.
    Timer {
        id: exitTimer
        interval: Settings.motion(popup.duration)
        onTriggered: {
            popup.visible = false
            popup.releaseLayer()
        }
    }

    anchor.window: barWindow
    anchor.rect.x: {
        if (!target || !barWindow || !barWindow.contentItem)
            return 0
        const pos = target.mapToItem(barWindow.contentItem, 0, 0)
        return Math.round(pos.x + target.width / 2 - width / 2)
    }
    anchor.rect.y: barWindow ? barWindow.height : 0

    // The pointer is over the popup.
    readonly property bool pointerInside: pointer.hovered

    // The pointer is over the module the popup belongs to.
    readonly property bool pointerOverTarget: target !== null && target.hovered

    // The state machine closes the popup when the pointer is over neither
    // the module nor the popup. The pointer needs a moment to travel from
    // the module into the popup, so the close is delayed.
    onPointerOverTargetChanged: popupState.pointerOverTarget = pointerOverTarget
    onPointerInsideChanged: popupState.pointerInside = pointerInside

    Component.onCompleted: {
        popupState.pointerOverTarget = popup.pointerOverTarget
        popupState.pointerInside = popup.pointerInside
    }

    // The frame around the content. It grows out of the bar when the popup
    // opens and shrinks back into it when the popup closes, the same way the
    // drawers of the bar do.
    Rectangle {
        id: frame
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: popup.contentWidth * popup.progress
        height: popup.contentHeight * popup.progress
        radius: popup.radius
        color: Theme.mainBg
        border.width: 2
        border.color: Theme.mainBr
        clip: true

        // The content keeps its size while the frame grows, so it does not
        // reflow while the popup opens.
        Item {
            id: holder
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: popup.contentWidth
            height: popup.contentHeight
        }
    }

    // The pointer inside the popup. The handler only watches the pointer, it
    // does not take the mouse away from the content of the popup.
    HoverHandler {
        id: pointer
        blocking: false
    }
}
