import QtQuick
import QtTest
import "../bar/"

// The tests of the layout of the bar.
//
// The bar is designed for 16 px text and the font size setting accepts 8 to
// 48 px. Every height, padding and character width is derived from the one
// scale of the theme, so these tests pin the scale and check that a row is
// still taller than the text it holds at both ends of the range.
TestCase {
    name: "BarLayout"

    // A run of the bar font at the current size, the tallest text a row of
    // the bar has to hold.
    Text {
        id: sample
        text: "Workspaces 194°F"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    function init() {
        Settings.set("fontSize", 16)
    }

    function cleanup() {
        Settings.set("fontSize", 16)
    }

    function test_the_default_font_keeps_the_waybar_metrics() {
        compare(Theme.fontSize, 16)
        compare(Theme.scale, 1)
        compare(Theme.rowHeight, 31)
        compare(Theme.rowPadding, 8)
        compare(Theme.modulePadding, 10)
        compare(Theme.workspaceCell, 31)
        verify(Math.abs(Theme.charWidth - 7.2) < 0.0001,
            "the default character width is " + Theme.charWidth)
    }

    function test_the_scale_follows_the_font_size() {
        const sizes = [8, 16, 48]
        for (let i = 0; i < sizes.length; i++) {
            Settings.set("fontSize", sizes[i])
            compare(Theme.fontSize, sizes[i])
            verify(Math.abs(Theme.scale - sizes[i] / 16) < 0.0001,
                "the scale of " + sizes[i] + " px is " + Theme.scale)
        }
    }

    function test_the_row_grows_with_the_font_size() {
        const sizes = [8, 16, 48]
        let previous = 0
        for (let i = 0; i < sizes.length; i++) {
            Settings.set("fontSize", sizes[i])
            verify(Theme.rowHeight > previous,
                "the row of " + sizes[i] + " px is " + Theme.rowHeight)
            previous = Theme.rowHeight
        }
    }

    function test_the_row_holds_its_text_at_the_extremes() {
        const sizes = [8, 16, 48]
        for (let i = 0; i < sizes.length; i++) {
            Settings.set("fontSize", sizes[i])
            verify(Theme.rowHeight >= Theme.fontSize + Theme.rowPadding,
                "the row of " + sizes[i] + " px has no padding")
            verify(Theme.rowHeight >= sample.implicitHeight,
                "the row of " + sizes[i] + " px clips the "
                    + sample.implicitHeight + " px text")
        }
    }

    function test_the_character_width_is_positive_and_monotonic() {
        const sizes = [8, 16, 48]
        let previous = 0
        for (let i = 0; i < sizes.length; i++) {
            Settings.set("fontSize", sizes[i])
            verify(Theme.charWidth > 0,
                "the character width of " + sizes[i] + " px is " + Theme.charWidth)
            verify(Theme.charWidth > previous,
                "the character width of " + sizes[i] + " px did not grow")
            previous = Theme.charWidth
        }
    }

    function test_the_workspace_cells_are_square() {
        const sizes = [8, 16, 48]
        for (let i = 0; i < sizes.length; i++) {
            Settings.set("fontSize", sizes[i])
            compare(Theme.workspaceCell, Theme.rowHeight)
            verify(Theme.workspaceCell > 0,
                "the workspace cell of " + sizes[i] + " px is empty")
        }
    }

    function test_the_drawer_rows_are_not_smaller_than_their_text() {
        // DrawerGroup and Module both use Theme.rowHeight, so a drawer row
        // cannot be shorter than the module and the text it holds.
        const sizes = [8, 16, 48]
        for (let i = 0; i < sizes.length; i++) {
            Settings.set("fontSize", sizes[i])
            verify(Theme.rowHeight >= sample.implicitHeight,
                "the drawer row of " + sizes[i] + " px is "
                    + Theme.rowHeight + " px for " + sample.implicitHeight + " px text")
        }
    }
}
