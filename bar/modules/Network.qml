import QtQuick
import "../"
import "../metrics/"

// Network — port of the waybar "network" module.
//
// The metric of the network knows the command and the parsing of nmcli, the
// module only draws it. The metric and its poller are shared by every bar,
// see bar/Metrics.qml.
Module {
    id: root

    bg: Theme.tray
    // #network { padding: 0 6px 0 4px; }
    padLeft: Theme.spaceSm
    padRight: Theme.px(6)
    minChars: 2
    dimOnHover: true

    readonly property NetworkMetric metric: Metrics.network

    onClicked: root.run(Settings.networkManagerCommand)

    tip: root.metric.tip

    iconText: root.metric.icon
}
