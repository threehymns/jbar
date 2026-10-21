import QtQuick
import QtQuick.Layouts
import "../"

// Calendar — the year / month view of the waybar clock calendar tooltip.
//
// The year view shows the twelve months in three columns, the month view
// shows the current month only.
Item {
    id: calendarRoot

    property var currentDate: new Date()
    property bool yearMode: true

    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight

    GridLayout {
        id: grid
        columns: calendarRoot.yearMode ? 3 : 1
        columnSpacing: 20
        rowSpacing: 10

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
