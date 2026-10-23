import QtQuick
import Quickshell.Io

// CommandRunner — runs one command test.
//
// The settings page loads this object lazily, because it is the only part
// of the page that imports Quickshell.Io. It runs the argv exactly as the
// preview shows it: Process.exec() takes the argument vector, so there is
// no shell, no word splitting and no expansion here. The runner reports
// the exit code and the two captured streams, and stops a test that runs
// longer than timeoutMs with SIGTERM.
QtObject {
    id: root

    // How long a test may run, in milliseconds.
    property int timeoutMs: 10000

    // The command of the current or last test, kept for the error message
    // of a binary that does not exist.
    property var command: []

    // A test finished. The output is complete when this is emitted.
    signal finished(int exitCode, string output, string error)

    // The test was stopped after timeoutMs.
    signal timedOut()

    // The process could not be started, usually because the binary is not
    // in PATH.
    signal failed(string message)

    // The state of the one process of the runner.
    property bool stopped: false
    property bool reported: false
    property bool sawStarted: false
    property bool exited: false
    property bool stdoutDone: false
    property bool stderrDone: false
    property int exitCode: 0

    // Start the argv of a test. Returns false when the runner is busy or
    // the argv is empty.
    function start(args) {
        if (process.running || !args || args.length === 0)
            return false

        root.stopped = false
        root.reported = false
        root.sawStarted = false
        root.exited = false
        root.stdoutDone = false
        root.stderrDone = false
        root.exitCode = 0
        root.command = args
        process.exec(args)
        return true
    }

    // Stop the running test. SIGTERM is the same signal the timeout uses,
    // so a command that handles it can clean up after itself.
    function cancel() {
        if (!process.running)
            return
        root.stopped = true
        root.timeoutTimer.stop()
        process.signal(15)
    }

    // Report the test once the process exited and both streams are done.
    // The order of those three events is not fixed, so each one calls here.
    function finish() {
        if (root.reported || root.stopped || !root.exited
                || !root.stdoutDone || !root.stderrDone)
            return

        root.reported = true
        if (!root.sawStarted) {
            root.failed("could not start " + root.command[0])
            return
        }
        root.finished(root.exitCode, out.text, err.text)
    }

    // The process of the test. Its command is the exact argv of the
    // preview; nothing is handed to a shell.
    property Process process: Process {
        id: proc

        stdout: StdioCollector {
            id: out
            waitForEnd: true
            onStreamFinished: {
                root.stdoutDone = true
                root.finish()
            }
        }

        stderr: StdioCollector {
            id: err
            waitForEnd: true
            onStreamFinished: {
                root.stderrDone = true
                root.finish()
            }
        }

        onStarted: {
            root.sawStarted = true
            root.timeoutTimer.restart()
        }

        onExited: exitCode => {
            root.timeoutTimer.stop()
            root.exitCode = exitCode
            root.exited = true
            root.finish()
        }

        // A binary that cannot be found makes running go false without a
        // started or exited signal. The warning of Quickshell is not
        // visible in the page, so the page gets a failure instead.
        onRunningChanged: {
            if (proc.running || root.sawStarted || root.exited || root.stopped)
                return
            root.stopped = true
            root.failed("could not start " + root.command[0])
        }
    }

    // SIGTERM after timeoutMs. The exit that follows is ignored because
    // stopped is already true.
    property Timer timeoutTimer: Timer {
        interval: root.timeoutMs
        repeat: false
        onTriggered: {
            if (!proc.running || root.stopped)
                return
            root.stopped = true
            proc.signal(15)
            root.timedOut()
        }
    }
}
