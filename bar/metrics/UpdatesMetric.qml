import QtQuick
import "../"

// UpdatesMetric — the metric of the pending system updates.
//
// The count of the updates is read once an hour, the waybar config does it.
Metric {
    // The command that reads the value.
    readonly property var command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]

    // How often the command runs, in milliseconds.
    readonly property int interval: 3600000

    parse: output => {
        const value = parseInt(output.trim())
        return isNaN(value) ? null : value
    }
}
