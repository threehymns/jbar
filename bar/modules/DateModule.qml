import QtQuick
import Quickshell
import "../"

// Date — port of the waybar "clock#date" module.
//
// Shows the date and opens the calendar of the waybar config when hovered.
// Clicking the date switches between the year and the month view, which is
// what the waybar "actions" section does.
Module {
    id: root

    bg: Theme.date
    // #clock.date { padding-left: 6px; }
    padLeft: 6
    padRight: 10
    minChars: 8
    dimOnHover: true

    // The bar window, needed to anchor the calendar popup.
    property var barRef: null

    property var now: new Date()
    property bool yearMode: true

    onClicked: root.yearMode = !root.yearMode
    onHoveredEnter: calendarPopup.visible = true
    onHoveredLeave: calendarPopup.visible = false

    Text {
        text: Icons.calendar
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    Text {
        text: root.now ? " " + Qt.formatDate(root.now, "dd-MM") : ""
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    PopupWindow {
        id: calendarPopup
        color: "transparent"
        visible: false
        implicitWidth: calendar.implicitWidth + 20
        implicitHeight: calendar.implicitHeight + 20

        anchor.window: root.barRef
        anchor.rect.x: {
            if (!root.barRef || !root.barRef.contentItem)
                return 0
            const pos = root.mapToItem(root.barRef.contentItem, 0, 0)
            return Math.round(pos.x + root.width / 2 - width / 2)
        }
        anchor.rect.y: root.barRef ? root.barRef.height : 0

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Theme.mainBg
            border.width: 2
            border.color: Theme.mainBr

            Calendar {
                id: calendar
                anchors.centerIn: parent
                currentDate: root.now
                yearMode: root.yearMode
            }
        }
    }
}
