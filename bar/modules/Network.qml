import QtQuick
import Quickshell.Io
import "../"

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

    // "wifi", "ethernet" or "none"
    property string connection: "none"

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

    Process {
        id: netProc
        command: ["sh", "-c",
            "nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null | grep -v '^lo' | head -1"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(":")
                const type = parts[1] || ""
                const state = parts[2] || ""
                if (state !== "connected")
                    root.connection = "none"
                else if (type === "wifi")
                    root.connection = "wifi"
                else if (type === "ethernet")
                    root.connection = "ethernet"
                else
                    root.connection = "none"
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: netProc.running = true
    }
}
