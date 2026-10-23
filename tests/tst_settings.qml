import QtQuick
import QtTest
import "../bar/"

// The tests of the settings of the bar.
//
// The settings are a plain object without any I/O, so the way a command
// line is split and the way a value is stored can be tested without a bar
// and without a file.
TestCase {
    name: "Settings"

    function test_a_command_line_is_split_into_arguments() {
        compare(Settings.command("rofi -show drun"), ["rofi", "-show", "drun"])
    }

    function test_a_quoted_part_stays_one_argument() {
        compare(Settings.command('notify-send "Hello World" -u critical'),
            ["notify-send", "Hello World", "-u", "critical"])
    }

    function test_a_single_quoted_part_stays_one_argument() {
        compare(Settings.command("sh -c 'ls -la'"), ["sh", "-c", "ls -la"])
    }

    function test_an_empty_command_line_has_no_arguments() {
        compare(Settings.command(""), [])
        compare(Settings.command("   "), [])
    }

    function test_a_value_that_was_never_stored_has_its_default() {
        compare(Settings.value("aSettingNobodyStored", 42), 42)
    }

    function test_a_stored_value_is_the_value_of_the_setting() {
        Settings.set("aTestSetting", 42)
        compare(Settings.value("aTestSetting", 0), 42)
        compare(Settings.stored.aTestSetting, 42)
    }

    function test_the_value_of_a_setting_follows_the_store() {
        Settings.set("aTestSetting", 42)
        compare(Settings.cpuWarning, 75)
        Settings.set("cpuWarning", 80)
        compare(Settings.cpuWarning, 80)
    }

    function test_reduced_motion_shortens_the_animations() {
        compare(Settings.motion(150), 150)

        Settings.set("reducedMotion", true)
        compare(Settings.motion(150), 0)

        Settings.set("reducedMotion", false)
        compare(Settings.motion(150), 150)
    }

    function test_the_default_outputs_show_every_output() {
        compare(Settings.outputs, "")
    }

    function test_the_sections_name_the_settings_of_the_page() {
        // every entry of the page names a setting that exists
        for (let i = 0; i < Settings.sections.length; i++) {
            const entries = Settings.sections[i].entries
            for (let j = 0; j < entries.length; j++)
                verify(entries[j].key in Settings, entries[j].key + " is not a setting")
        }
    }
}
