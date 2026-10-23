import QtQuick
import "../"

// NetworkMetric — the metric of the network connection.
//
// The value of this metric is not a number but the kind of the connection:
// "wifi", "ethernet" or "none".
Metric {
    // The command that reads the value.
    readonly property var command: ["sh", "-c",
        "nmcli -t -f DEVICE,TYPE,STATE device 2>/dev/null | grep -v '^lo' | head -1"]

    // How often the command runs, in milliseconds.
    property int interval: 10000

    // a sample is the kind of the connection
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

    measure: (sample, previous) => sample

    // The kind of the connection: "wifi", "ethernet" or "none".
    readonly property string connection: value

    // The icon of the connection.
    readonly property string icon: {
        if (connection === "wifi")
            return Icons.wifi
        if (connection === "ethernet")
            return Icons.ethernet
        return Icons.networkDown
    }
}
