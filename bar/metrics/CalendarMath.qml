import QtQuick

// CalendarMath — the date arithmetic and the fixed size of the calendar.
//
// A plain object without a bar, so the ISO week of a date can be tested
// headlessly. The calendar shows the ISO-8601 week number of the Monday of
// every row of a month: the Monday of the first row can belong to the
// previous month or year, and the Monday of the last row can belong to the
// next one.
QtObject {
    // ── the fixed size of the calendar ─────────────────────────────────────

    // The size of a day cell. A row has seven day cells and the week number;
    // the week cell is wider because the label is three characters.
    readonly property int cellWidth: 16
    readonly property int cellHeight: 14
    readonly property int weekWidth: 22

    // The largest size a month needs: the title (17), the weekday names
    // (13), the two 2 pixel gaps between the three rows and six rows of day
    // cells (6 * 14 + 5 * 1). Six rows is the most a month can need (a 31
    // day month that starts on a Sunday).
    readonly property int monthWidth: 7 * cellWidth + weekWidth
    readonly property int monthHeight: 17 + 13 + 2 * 2 + 6 * cellHeight + 5

    // The fixed preferred size of the calendar. It is the size of the
    // largest year view (three columns and four rows of months), so it does
    // not depend on the view or on the month that is shown. DateModule uses
    // it to size the popup before the lazy content has been built.
    readonly property int columnSpacing: 20
    readonly property int rowSpacing: 10
    readonly property int preferredWidth: 3 * monthWidth + 2 * columnSpacing
    readonly property int preferredHeight: 4 * monthHeight + 3 * rowSpacing

    // ── the ISO week of a date ─────────────────────────────────────────────

    // The ISO-8601 week number of a date. Weeks start on Monday and week 1
    // is the week that contains the first Thursday of the year, so a date in
    // the last days of December can belong to week 1 of the next year.
    function isoWeek(year, month, day) {
        // Work in UTC: a local date can fall into a different week when the
        // clocks change between the date and the Thursday of its week.
        const date = new Date(Date.UTC(year, month, day))

        // The Thursday of the ISO week decides the year of the week.
        date.setUTCDate(date.getUTCDate() - (date.getUTCDay() + 6) % 7 + 3)
        const isoYear = date.getUTCFullYear()

        // The Monday of the week of 4 January is the first Monday of the
        // ISO year.
        const january4 = new Date(Date.UTC(isoYear, 0, 4))
        const week1Monday = Date.UTC(isoYear, 0,
            4 - (january4.getUTCDay() + 6) % 7)

        return 1 + Math.round((date.getTime() - week1Monday) / 604800000)
    }

    // The Monday of a row of a month. The rows of a month start on the
    // Monday of the week that holds the first day of the month.
    function mondayOfRow(year, month, row) {
        const firstWeekday = (new Date(year, month, 1).getDay() + 6) % 7
        return new Date(year, month, 1 - firstWeekday + row * 7)
    }

    // The ISO week number of the Monday of a row of a month.
    function isoWeekOfRow(year, month, row) {
        const monday = mondayOfRow(year, month, row)
        return isoWeek(monday.getFullYear(), monday.getMonth(), monday.getDate())
    }

    // The label of a week number: Wnn, two digits.
    function weekLabel(week) {
        return "W" + (week < 10 ? "0" : "") + week
    }
}
