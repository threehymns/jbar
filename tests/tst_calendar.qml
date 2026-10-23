import QtQuick
import QtTest
import "../bar/"
import "../bar/metrics/"
import "../bar/modules/"

// The tests of the calendar.
//
// The ISO week arithmetic is a plain object, the month cells and the fixed
// size only need Qt Quick, and LazyContent keeps the year view (more than a
// thousand text objects) and the settings page (34 rows) out of the bar
// until their popups are opened for the first time.
TestCase {
    name: "Calendar"

    CalendarMath {
        id: math
    }

    Calendar {
        id: calendar
        currentDate: new Date(2024, 0, 15)
        yearMode: true
    }

    MonthView {
        id: december2025
        year: 2025
        month: 11
        todayDay: 1
        currentMonth: false
    }

    MonthView {
        id: january2021
        year: 2021
        month: 0
        todayDay: 1
        currentMonth: false
    }

    LazyContent {
        id: closedCalendar
        width: math.preferredWidth
        height: math.preferredHeight

        content: Component {
            Calendar {
                currentDate: new Date(2024, 0, 15)
            }
        }
    }

    LazyContent {
        id: openedCalendar
        width: math.preferredWidth
        height: math.preferredHeight

        content: Component {
            Calendar {
                currentDate: new Date(2024, 0, 15)
            }
        }
    }

    LazyContent {
        id: retainedCalendar
        width: math.preferredWidth
        height: math.preferredHeight

        content: Component {
            Calendar {
                currentDate: new Date(2024, 0, 15)
            }
        }
    }

    LazyContent {
        id: closedSettings
        width: 400
        height: 520

        content: Component {
            SettingsPage {
            }
        }
    }

    LazyContent {
        id: openedSettings
        width: 400
        height: 520

        content: Component {
            SettingsPage {
            }
        }
    }

    function countTexts(item) {
        if (!item)
            return 0

        let count = 0
        for (let i = 0; i < item.children.length; i++) {
            const child = item.children[i]
            if (child.text !== undefined && child.font !== undefined)
                count++
            count += countTexts(child)
        }
        return count
    }

    function countSettingRows(item) {
        if (!item)
            return 0

        let count = 0
        for (let i = 0; i < item.children.length; i++) {
            const child = item.children[i]
            if (child.key !== undefined && child.type !== undefined)
                count++
            count += countSettingRows(child)
        }
        return count
    }

    function weekCells(monthView) {
        const weeks = []
        for (let i = 0; i < monthView.cells.length; i++) {
            const cell = monthView.cells[i]
            if (cell.day === 0 && cell.week > 0)
                weeks.push(cell.week)
        }
        return weeks
    }

    function weekLabels(item) {
        if (!item)
            return []

        let labels = []
        for (let i = 0; i < item.children.length; i++) {
            const child = item.children[i]
            if (child.text !== undefined && child.font !== undefined
                    && /^W\d\d$/.test(String(child.text)))
                labels.push(String(child.text))
            labels = labels.concat(weekLabels(child))
        }
        return labels
    }

    function expectedSettingRows() {
        let count = 0
        for (let i = 0; i < Settings.sections.length; i++)
            count += Settings.sections[i].entries.length
        return count
    }

    function test_the_iso_week_at_a_year_boundary_data() {
        return [
            { tag: "last Monday of 2024", year: 2024, month: 11, day: 30, week: 1 },
            { tag: "first day of 2025", year: 2025, month: 0, day: 1, week: 1 },
            { tag: "first day of 2026", year: 2026, month: 0, day: 1, week: 1 },
            { tag: "W42", year: 2025, month: 9, day: 13, week: 42 },
            { tag: "Sunday of week 52", year: 2024, month: 11, day: 29, week: 52 },
            { tag: "last week of 2020", year: 2021, month: 0, day: 1, week: 53 },
            { tag: "Monday of week 53 of 2020", year: 2020, month: 11, day: 28, week: 53 },
            { tag: "first week of 2021", year: 2021, month: 0, day: 4, week: 1 },
            { tag: "leap day", year: 2024, month: 1, day: 29, week: 9 }
        ]
    }

    function test_the_iso_week_at_a_year_boundary(data) {
        compare(math.isoWeek(data.year, data.month, data.day), data.week)
    }

    function test_the_week_label_has_two_digits() {
        compare(math.weekLabel(1), "W01")
        compare(math.weekLabel(9), "W09")
        compare(math.weekLabel(10), "W10")
        compare(math.weekLabel(42), "W42")
        compare(math.weekLabel(53), "W53")
    }

    function test_a_row_uses_the_iso_week_of_its_monday_data() {
        return [
            { tag: "first row of December 2025", year: 2025, month: 11, row: 0, week: 49 },
            { tag: "last row of December 2025", year: 2025, month: 11, row: 4, week: 1 },
            { tag: "first row of January 2021", year: 2021, month: 0, row: 0, week: 53 },
            { tag: "second row of January 2021", year: 2021, month: 0, row: 1, week: 1 }
        ]
    }

    function test_a_row_uses_the_iso_week_of_its_monday(data) {
        compare(math.isoWeekOfRow(data.year, data.month, data.row), data.week)
    }

    function test_the_monday_of_the_first_row_can_be_in_the_previous_year() {
        const monday = math.mondayOfRow(2021, 0, 0)

        compare(monday.getFullYear(), 2020)
        compare(monday.getMonth(), 11)
        compare(monday.getDate(), 28)
    }

    function test_every_week_row_of_a_month_is_labelled() {
        // December 2025 starts on a Monday and ends in the first week of
        // 2026; January 2021 starts in the last week of 2020.
        compare(weekCells(december2025), [49, 50, 51, 52, 1])
        compare(weekCells(january2021), [53, 1, 2, 3, 4])
        compare(weekLabels(december2025), ["W49", "W50", "W51", "W52", "W01"])
        compare(december2025.cells.length % 8, 0)
        compare(january2021.cells.length % 8, 0)
    }

    function test_the_calendar_size_does_not_follow_the_view_or_the_month() {
        calendar.currentDate = new Date(2024, 0, 15)
        calendar.yearMode = true

        const width = calendar.implicitWidth
        const height = calendar.implicitHeight
        compare(width, math.preferredWidth)
        compare(height, math.preferredHeight)

        calendar.yearMode = false
        compare(calendar.implicitWidth, width)
        compare(calendar.implicitHeight, height)

        calendar.currentDate = new Date(2026, 11, 1)
        compare(calendar.implicitWidth, width)
        compare(calendar.implicitHeight, height)
    }

    function test_the_month_view_is_centred_in_the_fixed_size() {
        calendar.width = calendar.implicitWidth
        calendar.height = calendar.implicitHeight
        calendar.currentDate = new Date(2024, 0, 15)
        calendar.yearMode = true
        wait(0)

        const grid = calendar.children[0]
        compare(grid.columns, 3)
        compare(Math.round(grid.x + grid.width / 2), Math.round(calendar.width / 2))
        compare(Math.round(grid.y + grid.height / 2), Math.round(calendar.height / 2))

        calendar.yearMode = false
        wait(0)
        compare(grid.columns, 1)
        compare(Math.round(grid.x + grid.width / 2), Math.round(calendar.width / 2))
        compare(Math.round(grid.y + grid.height / 2), Math.round(calendar.height / 2))
    }

    function test_the_year_view_fits_the_preferred_size_data() {
        return [
            { tag: "2020", year: 2020 },
            { tag: "2021", year: 2021 },
            { tag: "2024", year: 2024 },
            { tag: "2026", year: 2026 },
            { tag: "2027", year: 2027 }
        ]
    }

    function test_the_year_view_fits_the_preferred_size(data) {
        calendar.currentDate = new Date(data.year, 0, 15)
        calendar.yearMode = true
        wait(0)

        const grid = calendar.children[0]
        verify(grid.implicitWidth <= math.preferredWidth,
            data.year + " is too wide: " + grid.implicitWidth)
        verify(grid.implicitHeight <= math.preferredHeight,
            data.year + " is too tall: " + grid.implicitHeight)
    }

    function test_a_closed_calendar_builds_no_text_objects() {
        compare(closedCalendar.loaded, false)
        compare(countTexts(closedCalendar), 0)
    }

    function test_the_calendar_is_built_on_first_activation() {
        compare(openedCalendar.loaded, false)

        const started = Date.now()
        openedCalendar.activate()
        const elapsed = Date.now() - started

        compare(openedCalendar.loaded, true)
        // the year view of 2024: twelve months of titles, weekdays and cells
        verify(countTexts(openedCalendar) > 1000)
        verify(elapsed < 2000, "the first open took " + elapsed + "ms")
    }

    function test_a_closed_settings_popup_builds_no_rows() {
        compare(closedSettings.loaded, false)
        compare(countSettingRows(closedSettings), 0)
    }

    function test_the_settings_are_built_on_first_activation() {
        compare(openedSettings.loaded, false)

        openedSettings.activate()

        compare(openedSettings.loaded, true)
        compare(countSettingRows(openedSettings), expectedSettingRows())
    }

    function test_activation_keeps_the_content() {
        retainedCalendar.activate()
        const before = retainedCalendar.item

        verify(before !== null)
        retainedCalendar.activate()

        compare(retainedCalendar.item, before)
    }
}
