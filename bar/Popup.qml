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
PopupWindow {
    id: popup

    // The bar window the popup belongs to.
    property var barWindow: null

    // The module the popup is anchored to.
    property Item target: null

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

    Rectangle {
        id: frame
        anchors.fill: parent
        radius: popup.radius
        color: Theme.mainBg
        border.width: 2
        border.color: Theme.mainBr
    }
}
