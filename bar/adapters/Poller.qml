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
        command: root.command
        running: root.command.length > 0

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.metric)
                    root.metric.accept(text)
            }
        }
    }

    property Timer timer: Timer {
        interval: root.interval
        running: root.command.length > 0
        repeat: true
        onTriggered: proc.running = true
    }
}
