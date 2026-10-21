import QtQuick
import Quickshell

// Popup — a popup of the bar.
//
// A popup has to live inside a window, so the module that shows it owns it
// and hands the bar window to it. The popup knows how to anchor itself
// below its module and how it looks, so a module only has to fill it with
// content.
//
//     Popup {
//         barWindow: root.barRef
//         target: root
//         implicitWidth: 200
//         implicitHeight: 100
//         Text { anchors.centerIn: parent }
//     }
//
// The popup is a window of its own below the bar, so the pointer has to
// travel from the module into the popup: the module loses the hover before
// the popup gets it. A popup that closed on that would vanish before the
// pointer could reach it, so the popup stays open while the pointer is over
// the module or over the popup and closes when it is over neither.
PopupWindow {
    id: popup

    // The bar window the popup belongs to.
    property var barWindow: null

    // The module the popup is anchored to.
    property Module target: null

    // The radius of the frame around the content.
    property int radius: 12

    // The content of the popup.
    default property alias content: frame.data

    color: "transparent"
    visible: false

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

    // The popup is closed when the pointer is over neither the module nor
    // the popup. The pointer needs a moment to travel from the module into
    // the popup, so the close is delayed.
    function closeWhenIdle() {
        if (pointerInside || pointerOverTarget)
            return
        closeTimer.restart()
    }

    // The pointer left the module.
    onPointerOverTargetChanged: {
        if (!pointerOverTarget)
            closeWhenIdle()
    }

    // The pointer entered or left the popup.
    onPointerInsideChanged: {
        if (pointerInside)
            closeTimer.stop()
        else
            closeWhenIdle()
    }

    Timer {
        id: closeTimer
        interval: 150
        onTriggered: popup.visible = false
    }

    Rectangle {
        id: frame
        anchors.fill: parent
        radius: popup.radius
        color: Theme.mainBg
        border.width: 2
        border.color: Theme.mainBr
    }

    // The pointer inside the popup. The handler only watches the pointer, it
    // does not take the mouse away from the content of the popup.
    HoverHandler {
        id: pointer
        blocking: false
    }
}
