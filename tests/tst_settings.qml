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

    function test_quoted_arguments_data() {
        return [
            { tag: "double quote inline", line: 'kitty --title="My Terminal"',
                args: ["kitty", "--title=My Terminal"] },
            { tag: "single quote inline", line: "kitty --title='My Terminal'",
                args: ["kitty", "--title=My Terminal"] },
            { tag: "unquoted and quoted parts", line: 'cmd pre"fix suffix"',
                args: ["cmd", "prefix suffix"] },
            { tag: "quoted parts next to each other", line: 'cmd "a""b"',
                args: ["cmd", "ab"] },
            { tag: "empty double quoted argument", line: 'cmd ""',
                args: ["cmd", ""] },
            { tag: "empty single quoted argument", line: "cmd ''",
                args: ["cmd", ""] },
            { tag: "empty quoted part in a word", line: 'cmd a""b',
                args: ["cmd", "ab"] },
            { tag: "escaped space", line: "cmd hello\\ world",
                args: ["cmd", "hello world"] },
            { tag: "escaped quote outside quotes", line: 'cmd \\"quoted\\"',
                args: ["cmd", '"quoted"'] },
            { tag: "escaped quote inside double quotes", line: 'cmd "say \\"hi\\""',
                args: ["cmd", 'say "hi"'] },
            { tag: "escaped backslash inside double quotes", line: 'cmd "a\\\\b"',
                args: ["cmd", "a\\b"] },
            { tag: "backslash is literal in single quotes", line: "cmd 'a\\b'",
                args: ["cmd", "a\\b"] },
            { tag: "tabs and newlines separate arguments", line: "cmd\ta\nb",
                args: ["cmd", "a", "b"] }
        ]
    }

    function test_quoted_arguments(data) {
        compare(Settings.command(data.line), data.args)
        compare(Settings.commandError(data.line), "")
    }

    function test_unmatched_quotes_data() {
        return [
            { tag: "double quote", line: 'cmd "unterminated' },
            { tag: "single quote", line: "cmd 'unterminated" },
            { tag: "quote at the start", line: '"unterminated' },
            { tag: "quote in the middle", line: 'cmd a "b c' }
        ]
    }

    function test_unmatched_quotes(data) {
        compare(Settings.command(data.line), [])
        verify(/quote/.test(Settings.commandError(data.line)),
            Settings.commandError(data.line))
    }

    function test_a_trailing_backslash_is_an_error() {
        compare(Settings.command("cmd foo\\"), [])
        verify(Settings.commandError("cmd foo\\") !== "")
    }

    function test_shell_syntax_is_rejected_data() {
        return [
            { tag: "pipe", line: "ls | grep foo" },
            { tag: "or list", line: "ls || true" },
            { tag: "and list", line: "ls && pwd" },
            { tag: "background", line: "ls &" },
            { tag: "semicolon", line: "ls; pwd" },
            { tag: "output redirection", line: "ls > out" },
            { tag: "input redirection", line: "ls < in" },
            { tag: "backtick substitution", line: "echo `date`" },
            { tag: "dollar substitution", line: "echo $(date)" },
            { tag: "variable", line: "echo $HOME" },
            { tag: "braced variable", line: "echo ${HOME}" },
            { tag: "quoted variable", line: 'echo "$HOME"' },
            { tag: "positional parameter", line: "echo $1" },
            { tag: "leading tilde", line: "ls ~/src" },
            { tag: "tilde after whitespace", line: "ls foo ~/src" },
            { tag: "tilde in an assignment", line: "cmd --prefix=~/bin" }
        ]
    }

    function test_shell_syntax_is_rejected(data) {
        verify(Settings.commandError(data.line) !== "",
            data.tag + " was accepted: " + data.line)
    }

    function test_quoted_shell_characters_are_literal_data() {
        return [
            { tag: "pipe in double quotes", line: 'notify-send "a | b"' },
            { tag: "and list in double quotes", line: 'notify-send "a && b"' },
            { tag: "variable in single quotes", line: "echo '$HOME'" },
            { tag: "escaped variable", line: "echo \\$HOME" },
            { tag: "escaped pipe", line: "echo a \\| b" },
            { tag: "dollar at the end of a quoted word", line: 'echo "cost: $"' }
        ]
    }

    function test_quoted_shell_characters_are_literal(data) {
        compare(Settings.commandError(data.line), "", data.tag)
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

    function test_the_destructive_commands_are_marked_for_confirmation() {
        const entries = {}
        for (let i = 0; i < Settings.sections.length; i++) {
            const section = Settings.sections[i].entries
            for (let j = 0; j < section.length; j++)
                entries[section[j].key] = section[j]
        }

        compare(entries.powerMenuCommand.destructive, true)
        compare(entries.updatesCommand.destructive, true)

        // a launcher is not destructive and must run on the first click
        verify(entries.launcherCommand.destructive === undefined)
    }
}
