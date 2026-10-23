import QtQuick
import QtTest
import "../bar"

// The tests of the merge of the config file.
//
// The adapter reads the file, merges the values of the settings with it and
// writes it back. The merge is a plain object without a bar or a file, so
// the read, merge and write scenarios are tested here.
TestCase {
    name: "ConfigMerge"

    function test_a_config_file_is_read() {
        const result = ConfigMerge.read('{"cpuWarning": 80, "outputs": "eDP-1"}')
        compare(result.error, "")
        compare(result.values.cpuWarning, 80)
        compare(result.values.outputs, "eDP-1")
    }

    function test_an_empty_config_file_has_no_values() {
        compare(ConfigMerge.read("").error, "")
        compare(Object.keys(ConfigMerge.read("   ").values).length, 0)
    }

    function test_a_broken_config_file_is_an_error() {
        verify(ConfigMerge.read("{ not json").error !== "")
    }

    function test_a_config_file_that_is_not_an_object_is_an_error() {
        verify(ConfigMerge.read("[1, 2]").error !== "")
        verify(ConfigMerge.read("42").error !== "")
        verify(ConfigMerge.read("null").error !== "")
    }

    function test_a_write_can_be_read_back() {
        const text = ConfigMerge.write({ cpuWarning: 80, outputs: "" })
        compare(text.charAt(text.length - 1), "\n")

        const result = ConfigMerge.read(text)
        compare(result.error, "")
        compare(result.values.cpuWarning, 80)
        compare(result.values.outputs, "")
    }

    function test_only_the_changed_keys_are_taken_from_memory() {
        const disk = { cpuWarning: 75, fontSize: 16, outputs: "eDP-1" }
        const memory = { cpuWarning: 80, fontSize: 12, outputs: "eDP-1" }
        const merged = ConfigMerge.merge(disk, memory, ["cpuWarning"])
        compare(merged.cpuWarning, 80)
        compare(merged.fontSize, 16)
        compare(merged.outputs, "eDP-1")
    }

    function test_a_value_edited_on_disk_survives_a_ui_change() {
        // the file was edited after the last read, only the key the page
        // changed is taken from memory
        const disk = { cpuWarning: 75, fontSize: 20 }
        const memory = { cpuWarning: 80, fontSize: 16 }
        const merged = ConfigMerge.merge(disk, memory, ["cpuWarning"])
        compare(merged.cpuWarning, 80)
        compare(merged.fontSize, 20)
    }

    function test_an_external_change_keeps_a_dirty_key() {
        // a hand edit arrives while the page holds a change that is not
        // written yet
        const disk = { cpuWarning: 75, fontSize: 20 }
        const memory = { cpuWarning: 80, fontSize: 16 }
        const merged = ConfigMerge.merge(disk, memory, ["cpuWarning"])
        compare(merged.cpuWarning, 80)
        compare(merged.fontSize, 20)
    }

    function test_a_new_key_is_written() {
        const merged = ConfigMerge.merge({ cpuWarning: 75 }, { cpuWarning: 75, fontSize: 18 }, ["fontSize"])
        compare(merged.cpuWarning, 75)
        compare(merged.fontSize, 18)
    }

    function test_an_empty_write_is_an_empty_object() {
        compare(ConfigMerge.write({}), "{}\n")
    }

    function test_an_error_of_the_file_view_has_a_name() {
        compare(ConfigMerge.errorName(2), "FileNotFound")
        compare(ConfigMerge.errorName(3), "PermissionDenied")
        compare(ConfigMerge.errorName(4), "NotAFile")
        compare(ConfigMerge.errorName("PermissionDenied"), "PermissionDenied")
    }
}
