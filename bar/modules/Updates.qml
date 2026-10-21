import QtQuick
import "../"
import "../adapters/"

// Updates — port of the waybar "custom/update" module.
//
// Counts the pending system updates once an hour and opens the update
// helper when clicked.
Module {
    id: root

    bg: Theme.tray
    // #custom-update { padding: 0 8px 0 2px; }
    padLeft: 2
    padRight: 8
    minChars: 1
    dimOnHover: true

    readonly property Metric metric: Metric {
        parse: output => {
            const value = parseInt(output.trim())
            return isNaN(value) ? null : value
        }
    }

    readonly property Poller poller: Poller {
        metric: root.metric
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        interval: 3600000
    }

    readonly property int count: metric.value
    readonly property bool visibleCount: count > 0

    onClicked: Quickshell.execDetached(["kitty", "-T", "Updates", "yay", "-Syua"])

    iconText: Icons.update
    labelText: root.count + ""
}
