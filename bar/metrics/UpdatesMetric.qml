import QtQuick
import "../"

// UpdatesMetric — the metric of the pending system updates.
//
// The count of the updates is read once an hour, the waybar config does it.
Metric {
    // The command that counts the pending updates.
    property string checkCommand: "checkupdates"

    // The command that reads the value. This one keeps its shell: the
    // check command is a command line from the settings and may use shell
    // syntax (see README.md).
    readonly property var command: ["sh", "-c",
        checkCommand + " 2>/dev/null | wc -l"]

    // How often the command runs, in milliseconds.
    property int interval: 3600000

    parse: output => {
        const value = parseInt(output.trim())
        return isNaN(value) ? null : value
    }
}
