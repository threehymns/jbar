import QtQuick
import "../"
import "../metrics/"

// Updates — port of the waybar "custom/update" module.
//
// The metric of the updates knows the command and the parsing, the module
// only draws it. The metric and its poller are shared by every bar, see
// bar/Metrics.qml.
Module {
    id: root

    bg: Theme.tray
    // #custom-update { padding: 0 8px 0 2px; }
    padLeft: Theme.spaceXs
    padRight: Theme.spaceMd
    minChars: 1
    dimOnHover: true

    readonly property UpdatesMetric metric: Metrics.updates

    onClicked: root.run(Settings.updatesCommand)

    iconText: Icons.update
    labelText: root.metric.value + ""
}
