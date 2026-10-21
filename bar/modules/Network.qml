import QtQuick
import "../"
import "../adapters/"

// Network — port of the waybar "network" module.
//
// Shows the icon of the active connection: wifi, ethernet or the
// disconnected icon when nothing is connected.
Module {
    id: root

    bg: Theme.tray
    // #network { padding: 0 6px 0 4px; }
    padLeft: 4
    padRight: 6
    minChars: 2
    dimOnHover: true

    readonly property Metric metric: Metric {
        parse: output => {
            const parts = output.trim().split(":")
            const type = parts[1] || ""
            const state = parts[2] || ""
            if (state !== "connected")
                return "none"
            if (type === "wifi")
                return "wifi"
            if (type === "ethernet")
                return "ethernet"
            return "none"
        }
    }

    readonly property Poller poller: Poller {
        metric: root.metric
        command: ["sh", "-c",
            "nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null | grep -v '^lo' | head -1"]
        interval: 10000
    }

    // "wifi", "ethernet" or "none"
    readonly property string connection: metric.value

    readonly property string icon: {
        if (root.connection === "wifi")
            return Icons.wifi
        if (root.connection === "ethernet")
            return Icons.ethernet
        return Icons.networkDown
    }

    onClicked: Quickshell.execDetached(["xdg-open",
        "vicinae://launch/@dagimg-dot/store.vicinae.wifi-commander/scan-wifi"])

    iconText: root.icon
}
