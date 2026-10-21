import QtQuick
import "../"
import "../adapters/"
import "../metrics/"

// Network — port of the waybar "network" module.
//
// The metric of the network knows the command and the parsing of nmcli, the
// module only draws it.
Module {
    id: root

    bg: Theme.tray
    // #network { padding: 0 6px 0 4px; }
    padLeft: 4
    padRight: 6
    minChars: 2
    dimOnHover: true

    readonly property NetworkMetric metric: NetworkMetric {}

    // The poll that fills the metric.
    readonly property Poller poller: Poller { metric: root.metric }

    onClicked: Quickshell.execDetached(["xdg-open",
        "vicinae://launch/@dagimg-dot/store.vicinae.wifi-commander/scan-wifi"])

    iconText: root.metric.icon
}
