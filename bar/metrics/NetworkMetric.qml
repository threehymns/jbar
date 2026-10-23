import QtQuick
import "../"

// NetworkMetric — the metric of the network connection.
//
// The value of this metric is not a number but the kind of the connection:
// "wifi", "ethernet", "vpn" or "none". Every non-loopback device of nmcli is
// considered, not only the first one: a machine can have Ethernet, Wi-Fi and
// a VPN up at the same time, and the first device in the output is not
// necessarily the one that carries the traffic.
Metric {
    // The command that reads the value. The connection name is read as well
    // so the tooltip can name the network the bar is on.
    readonly property var command: ["sh", "-c",
        "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device 2>/dev/null"]

    // How often the command runs, in milliseconds.
    property int interval: 10000

    // The states nmcli reports for an established link. "connected
    // (externally)" is a device NetworkManager does not manage but that is
    // up (a VPN, a bridge, iwd, …). "connecting" is transitional and stays
    // down until the link is up; "disconnected", "unavailable", "unmanaged"
    // and unknown states are down.
    function isConnected(state) {
        return state === "connected" || state === "connected (externally)"
    }

    // The kind of a connection from its nmcli type.
    function connectionKind(type) {
        if (type === "ethernet")
            return "ethernet"
        if (type === "wifi")
            return "wifi"
        // NetworkManager reports WireGuard and tunnel interfaces by their
        // own type names; they are VPNs for the bar as well.
        if (type === "vpn" || type === "wireguard" || type === "tun" || type === "tap")
            return "vpn"
        return "none"
    }

    // The priority of the kinds when several devices are connected:
    // ethernet > wifi > vpn > other. A docked laptop therefore shows its
    // cable rather than its Wi-Fi, and both rather than the VPN on top.
    // "Other" covers bridges, bonds and the like: they are active, but they
    // are not a kind the bar shows, so they never become the connection.
    function connectionRank(kind) {
        if (kind === "ethernet")
            return 3
        if (kind === "wifi")
            return 2
        if (kind === "vpn")
            return 1
        return 0
    }

    // Split one line of nmcli's terse output. nmcli separates fields with
    // ':' and escapes a literal ':' in a value as '\:' (a literal '\' is
    // escaped as '\\'), so only the unescaped colons are separators. Those
    // two escapes are undone here; nmcli does not escape any other
    // character, so any other backslash is kept as written.
    function splitTerse(line) {
        const fields = []
        let field = ""
        for (let i = 0; i < line.length; i++) {
            const c = line[i]
            if (c === "\\" && i + 1 < line.length) {
                const next = line[i + 1]
                if (next === ":" || next === "\\") {
                    field += next
                    i++
                    continue
                }
            }
            if (c === ":") {
                fields.push(field)
                field = ""
            } else {
                field += c
            }
        }
        fields.push(field)
        return fields
    }

    // a sample is the active device with the highest priority, or none
    parse: output => {
        const lines = (output || "").split("\n")
        let best = { kind: "none", device: "", name: "", type: "" }
        let bestRank = 0
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim()
            if (line === "")
                continue
            const fields = splitTerse(line)
            if (fields.length < 3)
                continue
            const device = fields[0]
            const type = fields[1]
            // the loopback device is up without a connection to anything
            if (device === "lo" || type === "loopback")
                continue
            const state = fields[2]
            if (!isConnected(state))
                continue
            const kind = connectionKind(type)
            const rank = connectionRank(kind)
            if (rank <= bestRank)
                continue
            bestRank = rank
            best = {
                kind: kind,
                device: device,
                name: fields[3] || "",
                type: type
            }
        }
        return best
    }

    measure: (sample, previous) => sample.kind

    // The kind of the connection: "wifi", "ethernet", "vpn" or "none".
    readonly property string connection: value

    // The device and the connection name of the chosen connection.
    readonly property string device: sample ? sample.device : ""
    readonly property string connectionName: sample ? sample.name : ""

    // The name of the connection, the device when nmcli has no profile
    // name for it.
    readonly property string label: connectionName !== "" ? connectionName : device

    // The icon of the connection.
    readonly property string icon: {
        if (connection === "wifi")
            return Icons.wifi
        if (connection === "ethernet")
            return Icons.ethernet
        if (connection === "vpn")
            return Icons.vpn
        return Icons.networkDown
    }

    // The tooltip of the module.
    readonly property string tip: {
        if (connection === "wifi")
            return label === "" ? "Wi-Fi" : "Wi-Fi: " + label
        if (connection === "ethernet")
            return label === "" ? "Ethernet" : "Ethernet: " + label
        if (connection === "vpn")
            return label === "" ? "VPN" : "VPN: " + label
        return "Offline"
    }
}
