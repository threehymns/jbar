import QtQuick
import QtQuick.Layouts
import "../"
import "../metrics/"

// Calendar — the year / month view of the waybar clock calendar.
//
// The year view shows the twelve months in three columns, the month view
// shows the current month only, centred in the same space. The preferred
// size is the one of the largest year view and does not depend on the view
// or on the month, so the popup keeps one size while its content changes.
Item {
    id: calendarRoot

    property var currentDate: new Date()
    property bool yearMode: true

    CalendarMath {
        id: calendarMath
    }

    implicitWidth: calendarMath.preferredWidth
    implicitHeight: calendarMath.preferredHeight

    GridLayout {
        id: grid
        anchors.centerIn: parent
        columns: calendarRoot.yearMode ? 3 : 1
        columnSpacing: calendarMath.columnSpacing
        rowSpacing: calendarMath.rowSpacing

        Repeater {
            model: calendarRoot.yearMode ? 12 : 1
            delegate: MonthView {
                required property int index
                year: calendarRoot.currentDate.getFullYear()
                month: calendarRoot.yearMode ? index : calendarRoot.currentDate.getMonth()
                todayDay: calendarRoot.currentDate.getDate()
                currentMonth: calendarRoot.yearMode ? index === calendarRoot.currentDate.getMonth() : true
            }
        }
    }
}
