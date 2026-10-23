import QtQuick
import Quickshell
import "../"
import "../metrics/"

// Date — port of the waybar "clock#date" module.
//
// Shows the date and opens the calendar of the waybar config when hovered.
// Clicking the date switches between the year and the month view, which is
// what the waybar "actions" section does.
//
// The calendar is built when the popup is opened for the first time and then
// kept: a closed calendar is more than a thousand text objects, and a
// retained one opens without building them again.
Module {
    id: root

    bg: Theme.date
    // #clock.date { padding-left: 6px; }
    padLeft: Theme.px(6)
    padRight: Theme.px(10)
    minChars: 8
    dimOnHover: true

    property var now: new Date()
    property bool yearMode: true

    CalendarMath {
        id: calendarMath
    }

    onClicked: root.yearMode = !root.yearMode
    onHoveredEnter: {
        calendarContent.activate()
        root.openPopup()
    }

    iconText: Icons.calendar
    labelText: root.now ? Qt.formatDate(root.now, Settings.dateFormat) : ""

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    popup: Popup {
        // The calendar has a fixed preferred size, so the popup knows its
        // size before the lazy content exists and does not resize when the
        // view or the month changes.
        contentWidth: calendarMath.preferredWidth + 20
        contentHeight: calendarMath.preferredHeight + 20

        LazyContent {
            id: calendarContent
            anchors.centerIn: parent
            width: calendarMath.preferredWidth
            height: calendarMath.preferredHeight

            content: Component {
                Calendar {
                    currentDate: root.now
                    yearMode: root.yearMode
                }
            }
        }
    }
}
