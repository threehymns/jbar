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

    property var now: new Date()
    property bool yearMode: true

    onClicked: root.yearMode = !root.yearMode
    onHoveredEnter: root.openPopup()

    iconText: Icons.calendar
    labelText: root.now ? Qt.formatDate(root.now, "dd-MM") : ""

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    popup: Popup {
        implicitWidth: calendar.implicitWidth + 20
        implicitHeight: calendar.implicitHeight + 20

        Calendar {
            id: calendar
            anchors.centerIn: parent
            currentDate: root.now
            yearMode: root.yearMode
        }
    }
}
