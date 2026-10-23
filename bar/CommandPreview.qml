import QtQuick

// CommandPreview — the state of a command test, without any I/O.
//
// The settings page shows the argv of a command before it is run. This
// object owns the rest of that story: the parsed line, the two-step
// confirmation of a destructive command, the state of a test and the
// output it produced. It never starts a process itself, so the tests can
// drive it without a bar and without a shell; the runtime runner reports
// back through accept(), fail(), timeout() and cancel().
QtObject {
    id: root

    // The command line of the setting.
    property string line: ""

    // Whether running the command has a side effect the user should
    // confirm. The power menu and the update installer are destructive.
    property bool destructive: false

    // How long the confirmation of a destructive command stays armed.
    property int confirmMs: 5000

    // The timeout of a test. The runner enforces it; the value is here so
    // the page can say how long a test may take.
    property int timeoutMs: 10000

    // How much of a stream is shown in the page: at most this many lines
    // and this many characters of each stream. The full text stays in
    // stdout and stderr, the summary is only for the page.
    property int summaryLines: 3
    property int summaryChars: 160

    // idle, running, succeeded, failed, timed out or cancelled.
    property string status: "idle"

    // The exit code of the last finished test, and the full output it
    // captured. A command that could not be started has the code -1.
    property int exitCode: 0
    property string stdout: ""
    property string stderr: ""

    // Why the test failed before it could report an exit code, if it did.
    property string message: ""

    // A destructive command waits for its second click while this is true.
    property bool armed: false

    // The reason the line cannot run, empty when it can.
    readonly property string error: Settings.commandError(root.line)

    // The arguments that will be passed to the process.
    readonly property var args: Settings.command(root.line)

    // Whether the line can be tested. An empty line has no arguments and
    // is not an error, but there is nothing to run either.
    readonly property bool valid: root.error === "" && root.args.length > 0

    // The vector the user can compare with what they wrote. JSON quotes
    // every argument, so a space or an empty argument is visible.
    readonly property string preview: root.error !== ""
        ? root.error : "runs " + JSON.stringify(root.args)

    // Whether a test is running.
    readonly property bool running: root.status === "running"

    // The one-line state of the test.
    readonly property string statusText: {
        if (root.status === "running")
            return "running…"
        if (root.status === "succeeded")
            return "succeeded, exit 0"
        if (root.status === "failed") {
            if (root.message !== "")
                return "failed: " + root.message
            return "failed, exit " + root.exitCode
        }
        if (root.status === "timed out")
            return "timed out after " + Math.max(1, Math.round(root.timeoutMs / 1000)) + " s"
        if (root.status === "cancelled")
            return "cancelled"
        return ""
    }

    // The captured output, trimmed to the summary rule above.
    readonly property string outputSummary: {
        const out = root.summarize(root.stdout)
        const err = root.summarize(root.stderr)
        const parts = []
        if (out !== "")
            parts.push("stdout: " + out)
        if (err !== "")
            parts.push("stderr: " + err)
        return parts.join("\n")
    }

    // Whether the summary left something out.
    readonly property bool outputTruncated: root.isTruncated(root.stdout)
        || root.isTruncated(root.stderr)

    // A test was requested. The runtime runner starts exactly these
    // arguments; this object only changes its own state.
    signal runRequested(var args)

    // The running test has to be stopped.
    signal cancelRequested()

    // The confirmation window of a destructive command.
    property Timer armTimer: Timer {
        interval: root.confirmMs
        repeat: false
        onTriggered: root.armed = false
    }

    // The line changed, so a confirmation or a result of the old line no
    // longer applies. A test of the old line is stopped, so its process
    // cannot outlive the line it was started for.
    onLineChanged: {
        if (root.running)
            root.cancel()
        root.reset()
    }

    // Turning the destructive flag off always disarms.
    onDestructiveChanged: root.disarm()

    // Arm a destructive command for a second click, or start the test.
    // Returns true when the test was started, false when the line is not
    // runnable, a test is already running, or the first click only armed
    // the confirmation.
    function run() {
        if (root.running || !root.valid)
            return false

        if (root.destructive && !root.armed) {
            root.armed = true
            root.armTimer.restart()
            return false
        }

        root.disarm()
        root.status = "running"
        root.exitCode = 0
        root.stdout = ""
        root.stderr = ""
        root.message = ""
        root.runRequested(root.args)
        return true
    }

    // A test finished with an exit code and the two streams. Late reports
    // of a cancelled or timed out test are ignored.
    function accept(code, out, err) {
        if (!root.running)
            return false
        root.exitCode = Number(code)
        root.stdout = out === undefined || out === null ? "" : String(out)
        root.stderr = err === undefined || err === null ? "" : String(err)
        root.status = root.exitCode === 0 ? "succeeded" : "failed"
        return true
    }

    // The test could not be started at all.
    function fail(reason) {
        if (!root.running)
            return false
        root.status = "failed"
        root.exitCode = -1
        root.message = reason === undefined || reason === null || reason === ""
            ? "the command could not be started" : String(reason)
        root.stdout = ""
        root.stderr = ""
        return true
    }

    // The runner stopped the test after its timeout.
    function timeout() {
        if (!root.running)
            return false
        root.status = "timed out"
        return true
    }

    // The user stopped the test.
    function cancel() {
        if (!root.running)
            return false
        root.status = "cancelled"
        root.armTimer.stop()
        root.cancelRequested()
        return true
    }

    // Back to the idle state, without touching the line or the flags.
    function reset() {
        root.armTimer.stop()
        root.armed = false
        root.status = "idle"
        root.exitCode = 0
        root.stdout = ""
        root.stderr = ""
        root.message = ""
    }

    // Disarm the confirmation of a destructive command.
    function disarm() {
        root.armTimer.stop()
        root.armed = false
    }

    // The lines of a stream, without the empty line a trailing newline
    // leaves behind.
    function textLines(text) {
        let value = text === undefined || text === null ? "" : String(text)
        value = value.replace(/\r\n/g, "\n")
        while (value.length > 0 && value.charAt(value.length - 1) === "\n")
            value = value.substring(0, value.length - 1)
        return value === "" ? [] : value.split("\n")
    }

    // Whether a stream is longer than the summary rule allows.
    function isTruncated(text) {
        const lines = root.textLines(text)
        return lines.length > root.summaryLines
            || lines.join("\n").length > root.summaryChars
    }

    // A stream cut to the summary rule. The ellipsis says that the full
    // text is longer than what the page shows.
    function summarize(text) {
        let lines = root.textLines(text)
        if (lines.length === 0)
            return ""

        let clipped = false
        if (lines.length > root.summaryLines) {
            lines = lines.slice(0, root.summaryLines)
            clipped = true
        }

        let shown = lines.join("\n")
        if (shown.length > root.summaryChars) {
            shown = shown.substring(0, root.summaryChars)
            clipped = true
        }
        return clipped ? shown + " …" : shown
    }
}
