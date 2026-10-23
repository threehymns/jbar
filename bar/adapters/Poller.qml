import QtQuick
import Quickshell.Io

// Poller — reads the value of a metric with a command.
//
// The poll runs the command every now and then and hands the output to the
// metric, which turns it into the value. The poll is the only part of a
// metric that touches the system, the metric itself holds the arithmetic.
QtObject {
    id: root

    // The metric the poll fills.
    property var metric: null

    // The command that reads the value. The metric of a system knows its
    // own command, so a module only hands the metric over.
    property var command: root.metric && root.metric.command
        ? root.metric.command : []

    // How often the command runs, in milliseconds.
    property int interval: root.metric && root.metric.interval
        ? root.metric.interval : 10000

    // A plain object has no default property for children, so the process
    // and the timer are held by a property.
    property Process process: Process {
        id: proc

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.metric)
                    root.metric.accept(text)
            }
        }

        // A missing sensor or command is not a failure of the bar: the
        // metric keeps its last value. Collect stderr so a poll that cannot
        // read its system does not spam the log every interval.
        stderr: StdioCollector {}
    }

    property Timer timer: Timer {
        interval: root.interval
        running: root.command.length > 0
        repeat: true
        onTriggered: root.start()
    }

    // The metric can be handed over after the poller is created (the
    // Metrics singleton loads its pollers), so the first poll is started
    // here instead of by a binding on Process.running. A running binding
    // that turns true before the command arrives would start an empty
    // process and then never poll again.
    //
    // The start is deferred by one event loop turn: a process started while
    // the poller is still being created does not deliver its started/exited
    // signals in Quickshell 0.3.
    Component.onCompleted: Qt.callLater(root.start)
    onCommandChanged: Qt.callLater(root.start)

    // Run the command once, with the command as it is now. exec() takes the
    // current command, so a poll that is triggered while a setting changes
    // cannot run the previous one. A poll that is still running is left
    // alone, like the old `running = true` that was a no-op while running.
    function start() {
        if (root.command.length === 0 || proc.running)
            return
        proc.exec(root.command)
    }
}
