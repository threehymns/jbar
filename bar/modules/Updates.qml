import QtQuick
import "../"
import "../adapters/"
import "../metrics/"

// Updates — port of the waybar "custom/update" module.
//
// The metric of the updates knows the command and the parsing, the module
// only draws it.
Module {
    id: root

    bg: Theme.tray
    // #custom-update { padding: 0 8px 0 2px; }
    padLeft: 2
    padRight: 8
    minChars: 1
    dimOnHover: true

    readonly property UpdatesMetric metric: UpdatesMetric {}

    // The poll that fills the metric.
    readonly property Poller poller: Poller { metric: root.metric }

    onClicked: Quickshell.execDetached(["kitty", "-T", "Updates", "yay", "-Syua"])

    iconText: Icons.update
    labelText: root.metric.value + ""
}
