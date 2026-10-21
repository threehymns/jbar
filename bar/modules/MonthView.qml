import QtQuick
import QtQuick.Layouts
import "../"

// MonthView — a single month of the waybar clock calendar.
//
// The colours are the ones of the theme of the bar.
ColumnLayout {
    id: monthRoot

    property int year: 2024
    property int month: 0 // zero based
    property int todayDay: 0
    property bool currentMonth: false

    spacing: 2

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"]
    readonly property var weekdayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    function firstWeekday(y, m) {
        // JS months are zero based, getDay() is zero based on sunday.
        return (new Date(y, m, 1).getDay() + 6) % 7
    }

    function daysInMonth(y, m) {
        return new Date(y, m + 1, 0).getDate()
    }

    // Flat list of the cells of the month: seven day cells per row followed
    // by the week number of that row ("weeks-pos": "right").
    readonly property var cells: {
        const result = []
        const blanks = firstWeekday(year, month)
        const days = daysInMonth(year, month)
        const rows = Math.ceil((blanks + days) / 7)

        for (let row = 0; row < rows; row++) {
            for (let column = 0; column < 7; column++) {
                const index = row * 7 + column
                const day = index < blanks ? 0 : index - blanks + 1
                result.push({ day: day > days ? 0 : day, week: 0 })
            }
            result.push({ day: 0, week: row + 1 })
        }
        return result
    }

    Label {
        text: monthRoot.monthNames[monthRoot.month]
        color: Theme.mainFg
        pixelSize: 13
        font.bold: true
    }

    RowLayout {
        spacing: 0

        Repeater {
            model: monthRoot.weekdayNames
            delegate: Label {
                required property string modelData
                text: modelData
                color: Theme.yellow
                pixelSize: 10
                Layout.preferredWidth: 16
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    GridLayout {
        columns: 8
        columnSpacing: 0
        rowSpacing: 1

        Repeater {
            model: monthRoot.cells
            delegate: Item {
                id: cell
                required property var modelData

                implicitWidth: 16
                implicitHeight: 14

                readonly property bool isToday: cell.modelData.day === monthRoot.todayDay
                    && monthRoot.currentMonth

                Label {
                    anchors.centerIn: parent
                    visible: cell.modelData.day > 0
                    text: cell.modelData.day
                    color: cell.isToday ? Theme.purple : Theme.fg2
                    pixelSize: 10
                    font.underline: cell.isToday
                    font.bold: cell.isToday
                }

                Label {
                    anchors.centerIn: parent
                    visible: cell.modelData.week > 0
                    text: cell.modelData.week
                    color: Theme.aqua
                    pixelSize: 9
                }
            }
        }
    }
}
