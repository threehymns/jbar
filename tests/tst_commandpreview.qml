import QtQuick
import QtTest
import "../bar"

// The tests of the command preview and its test state.
//
// CommandPreview is a plain object without any I/O: it parses the line with
// the settings, owns the confirmation of a destructive command and records
// the result the runner reports. Nothing here starts a process, so the
// states, the exit code, the timeout and the truncation rule are all
// deterministic.
TestCase {
    name: "CommandPreview"

    CommandPreview {
        id: preview
    }

    SignalSpy {
        id: runSpy
        target: preview
        signalName: "runRequested"
    }

    SignalSpy {
        id: cancelSpy
        target: preview
        signalName: "cancelRequested"
    }

    function init() {
        preview.destructive = false
        preview.confirmMs = 5000
        preview.timeoutMs = 10000
        preview.line = "echo hello"
        preview.reset()
        runSpy.clear()
        cancelSpy.clear()
    }

    function cleanup() {
        preview.reset()
        preview.destructive = false
    }

    function test_the_preview_is_the_exact_argv() {
        preview.line = 'kitty --title="My Terminal"'
        compare(preview.error, "")
        compare(preview.args, ["kitty", "--title=My Terminal"])
        compare(preview.preview, 'runs ["kitty","--title=My Terminal"]')
        verify(preview.valid)
    }

    function test_an_empty_line_has_nothing_to_run() {
        preview.line = "   "
        compare(preview.error, "")
        compare(preview.args, [])
        compare(preview.preview, "runs []")
        verify(!preview.valid)
        compare(preview.run(), false)
        compare(preview.status, "idle")
        compare(runSpy.count, 0)
    }

    function test_an_invalid_line_shows_the_error_and_is_not_run() {
        preview.line = "ls | grep foo"
        verify(preview.error.indexOf("pipes") >= 0, preview.error)
        compare(preview.preview, preview.error)
        verify(!preview.valid)
        compare(preview.run(), false)
        compare(preview.status, "idle")
        compare(runSpy.count, 0)
    }

    function test_a_quoted_shell_line_is_an_explicit_shell() {
        preview.line = "sh -c 'ls | grep foo'"
        compare(preview.error, "")
        compare(preview.args, ["sh", "-c", "ls | grep foo"])
        verify(preview.valid)
    }

    function test_a_destructive_command_needs_a_second_click() {
        preview.destructive = true
        preview.line = "wlogout"

        compare(preview.run(), false)
        verify(preview.armed)
        compare(preview.status, "idle")
        compare(runSpy.count, 0)

        compare(preview.run(), true)
        verify(!preview.armed)
        compare(preview.status, "running")
        compare(runSpy.count, 1)
        compare(runSpy.signalArguments[0][0], ["wlogout"])
    }

    function test_the_destructive_confirmation_expires() {
        preview.confirmMs = 50
        preview.destructive = true
        preview.line = "wlogout"

        compare(preview.run(), false)
        verify(preview.armed)
        wait(120)
        verify(!preview.armed)

        // the next click arms again instead of running the command
        compare(preview.run(), false)
        verify(preview.armed)
        compare(runSpy.count, 0)
    }

    function test_editing_the_line_disarms_the_confirmation() {
        preview.destructive = true
        preview.line = "wlogout"
        compare(preview.run(), false)
        verify(preview.armed)

        preview.line = "wlogout --now"
        verify(!preview.armed)
        compare(preview.status, "idle")
    }

    function test_a_plain_command_runs_on_the_first_click() {
        preview.destructive = false
        compare(preview.run(), true)
        compare(preview.status, "running")
        compare(preview.statusText, "running…")
        compare(runSpy.count, 1)
    }

    function test_a_run_can_succeed() {
        compare(preview.run(), true)
        compare(preview.accept(0, "hello\n", ""), true)
        compare(preview.status, "succeeded")
        compare(preview.statusText, "succeeded, exit 0")
        compare(preview.exitCode, 0)
        compare(preview.stdout, "hello\n")
        compare(preview.stderr, "")
        compare(preview.outputSummary, "stdout: hello")
        compare(preview.outputTruncated, false)
    }

    function test_a_run_can_fail_with_its_exit_code() {
        compare(preview.run(), true)
        compare(preview.accept(2, "", "no such thing\n"), true)
        compare(preview.status, "failed")
        compare(preview.statusText, "failed, exit 2")
        compare(preview.exitCode, 2)
        compare(preview.outputSummary, "stderr: no such thing")
    }

    function test_a_run_can_time_out() {
        compare(preview.run(), true)
        compare(preview.timeout(), true)
        compare(preview.status, "timed out")
        compare(preview.statusText, "timed out after 10 s")

        // a late exit of the killed process must not replace the timeout
        preview.accept(143, "late", "")
        compare(preview.status, "timed out")
    }

    function test_a_run_can_be_cancelled() {
        compare(preview.run(), true)
        compare(preview.cancel(), true)
        compare(preview.status, "cancelled")
        compare(preview.statusText, "cancelled")
        compare(cancelSpy.count, 1)

        // a late exit of the killed process must not replace the cancel
        preview.accept(0, "late", "")
        compare(preview.status, "cancelled")
    }

    function test_a_command_that_cannot_start_is_a_failure() {
        compare(preview.run(), true)
        compare(preview.fail("could not start no-such-command"), true)
        compare(preview.status, "failed")
        compare(preview.statusText, "failed: could not start no-such-command")
        compare(preview.exitCode, -1)
    }

    function test_the_output_is_truncated_to_a_short_summary() {
        compare(preview.run(), true)
        const long = "a".repeat(500)
        preview.accept(1, long, "")
        compare(preview.stdout, long)
        verify(preview.outputTruncated)
        verify(preview.outputSummary.length < 200,
            "the summary is " + preview.outputSummary.length + " characters")
        verify(preview.outputSummary.indexOf("…") >= 0, preview.outputSummary)
    }

    function test_the_summary_keeps_a_few_lines_of_each_stream() {
        compare(preview.run(), true)
        preview.accept(0, "one\ntwo\nthree\nfour\nfive\n", "")
        compare(preview.outputSummary, "stdout: one\ntwo\nthree …")
        verify(preview.outputTruncated)
    }

    function test_the_summary_names_stdout_and_stderr() {
        compare(preview.run(), true)
        preview.accept(1, "out\n", "err\n")
        compare(preview.outputSummary, "stdout: out\nstderr: err")
        compare(preview.outputTruncated, false)
    }

    function test_editing_the_line_clears_the_result() {
        compare(preview.run(), true)
        preview.accept(0, "hello\n", "")
        compare(preview.status, "succeeded")

        preview.line = "echo bye"
        compare(preview.status, "idle")
        compare(preview.exitCode, 0)
        compare(preview.outputSummary, "")
        compare(preview.statusText, "")
    }

    function test_editing_the_line_cancels_a_running_test() {
        compare(preview.run(), true)
        compare(preview.status, "running")

        preview.line = "echo bye"
        compare(preview.status, "idle")
        compare(cancelSpy.count, 1)
    }
}
