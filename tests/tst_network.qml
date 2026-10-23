import QtQuick
import QtTest
import "../bar/"
import "../bar/metrics/"

// The tests of the metric of the network.
//
// The metric is a plain object without any I/O, so the parsing of nmcli can
// be tested without a bar and without a command. The tables cover every
// state nmcli reports, the devices of a machine that has more than one, and
// the priority of the active connection.
TestCase {
    name: "NetworkMetric"

    NetworkMetric {
        id: metric
    }

    function test_the_connection_data() {
        return [
            {
                tag: "single wifi",
                output: "wlan0:wifi:connected:Home\n",
                connection: "wifi",
                device: "wlan0",
                icon: Icons.wifi,
                tip: "Wi-Fi: Home"
            },
            {
                tag: "single ethernet",
                output: "eth0:ethernet:connected:Wired\n",
                connection: "ethernet",
                device: "eth0",
                icon: Icons.ethernet,
                tip: "Ethernet: Wired"
            },
            {
                tag: "single vpn",
                output: "vpn0:vpn:connected:Work\n",
                connection: "vpn",
                device: "vpn0",
                icon: Icons.vpn,
                tip: "VPN: Work"
            },
            {
                tag: "wireguard is a vpn",
                output: "wg0:wireguard:connected:wg0\n",
                connection: "vpn",
                device: "wg0",
                icon: Icons.vpn,
                tip: "VPN: wg0"
            },
            {
                tag: "tunnel is a vpn",
                output: "tailscale0:tun:connected (externally):tailscale0\n",
                connection: "vpn",
                device: "tailscale0",
                icon: Icons.vpn,
                tip: "VPN: tailscale0"
            },
            {
                tag: "connected externally wifi",
                output: "wlan0:wifi:connected (externally):Home\n",
                connection: "wifi",
                device: "wlan0",
                icon: Icons.wifi,
                tip: "Wi-Fi: Home"
            },
            {
                tag: "connected externally ethernet",
                output: "eth0:ethernet:connected (externally):Wired\n",
                connection: "ethernet",
                device: "eth0",
                icon: Icons.ethernet,
                tip: "Ethernet: Wired"
            },
            {
                tag: "ethernet wins over wifi",
                output: "eth0:ethernet:connected:Wired\nwlan0:wifi:connected:Home\n",
                connection: "ethernet",
                device: "eth0",
                icon: Icons.ethernet,
                tip: "Ethernet: Wired"
            },
            {
                tag: "ethernet wins in the other order",
                output: "wlan0:wifi:connected:Home\neth0:ethernet:connected:Wired\n",
                connection: "ethernet",
                device: "eth0",
                icon: Icons.ethernet,
                tip: "Ethernet: Wired"
            },
            {
                tag: "ethernet wins over vpn",
                output: "vpn0:vpn:connected:Work\neth0:ethernet:connected:Wired\n",
                connection: "ethernet",
                device: "eth0",
                icon: Icons.ethernet,
                tip: "Ethernet: Wired"
            },
            {
                tag: "wifi wins over vpn",
                output: "vpn0:vpn:connected:Work\nwlan0:wifi:connected:Home\n",
                connection: "wifi",
                device: "wlan0",
                icon: Icons.wifi,
                tip: "Wi-Fi: Home"
            },
            {
                tag: "wifi wins over vpn in the other order",
                output: "wlan0:wifi:connected:Home\nvpn0:vpn:connected:Work\n",
                connection: "wifi",
                device: "wlan0",
                icon: Icons.wifi,
                tip: "Wi-Fi: Home"
            },
            {
                tag: "all three kinds in yet another order",
                output: "vpn0:vpn:connected:Work\nwlan0:wifi:connected:Home\n"
                    + "eth0:ethernet:connected:Wired\n",
                connection: "ethernet",
                device: "eth0",
                icon: Icons.ethernet,
                tip: "Ethernet: Wired"
            },
            {
                tag: "connecting is not connected",
                output: "wlan0:wifi:connecting:Home\n",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            },
            {
                tag: "connecting does not hide a connected device",
                output: "wlan0:wifi:connecting:Home\neth0:ethernet:connected:Wired\n",
                connection: "ethernet",
                device: "eth0",
                icon: Icons.ethernet,
                tip: "Ethernet: Wired"
            },
            {
                tag: "disconnected is not connected",
                output: "wlan0:wifi:disconnected:Home\n",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            },
            {
                tag: "disconnected does not hide a connected device",
                output: "wlan0:wifi:disconnected:Home\nvpn0:vpn:connected:Work\n",
                connection: "vpn",
                device: "vpn0",
                icon: Icons.vpn,
                tip: "VPN: Work"
            },
            {
                tag: "unavailable is not connected",
                output: "eth0:ethernet:unavailable:\n",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            },
            {
                tag: "unmanaged is not connected",
                output: "eth0:ethernet:unmanaged:\n",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            },
            {
                tag: "unknown state is not connected",
                output: "wlan0:wifi:connectedness:Home\n",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            },
            {
                tag: "unknown state does not hide a connected device",
                output: "wlan0:wifi:connectedness:Home\neth0:ethernet:connected:Wired\n",
                connection: "ethernet",
                device: "eth0",
                icon: Icons.ethernet,
                tip: "Ethernet: Wired"
            },
            {
                tag: "loopback only",
                output: "lo:loopback:connected (externally):lo\n",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            },
            {
                tag: "loopback under another name",
                output: "lo0:loopback:connected (externally):lo0\n",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            },
            {
                tag: "loopback does not hide a connected device",
                output: "lo:loopback:connected (externally):lo\nwlan0:wifi:connected:Home\n",
                connection: "wifi",
                device: "wlan0",
                icon: Icons.wifi,
                tip: "Wi-Fi: Home"
            },
            {
                tag: "an active device of an unknown kind is not a known connection",
                output: "br0:bridge:connected (externally):br0\n",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            },
            {
                tag: "an active device of an unknown kind does not hide ethernet",
                output: "br0:bridge:connected (externally):br0\neth0:ethernet:connected:Wired\n",
                connection: "ethernet",
                device: "eth0",
                icon: Icons.ethernet,
                tip: "Ethernet: Wired"
            },
            {
                tag: "a connection name without a profile falls back to the device",
                output: "wlan0:wifi:connected\n",
                connection: "wifi",
                device: "wlan0",
                icon: Icons.wifi,
                tip: "Wi-Fi: wlan0"
            },
            {
                tag: "an escaped colon in the connection name",
                output: "wlan0:wifi:connected:Home\\:Guest\n",
                connection: "wifi",
                device: "wlan0",
                icon: Icons.wifi,
                tip: "Wi-Fi: Home:Guest"
            },
            {
                tag: "empty output",
                output: "",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            },
            {
                tag: "unreadable output",
                output: "not the output of nmcli\n",
                connection: "none",
                device: "",
                icon: Icons.networkDown,
                tip: "Offline"
            }
        ]
    }

    function test_the_connection(data) {
        metric.accept(data.output)
        compare(metric.connection, data.connection)
        compare(metric.device, data.device)
        compare(metric.icon, data.icon)
        compare(metric.tip, data.tip)
    }

    function test_a_changed_output_replaces_the_previous_connection() {
        metric.accept("wlan0:wifi:connected:Home\n")
        compare(metric.connection, "wifi")

        metric.accept("wlan0:wifi:disconnected:\n")
        compare(metric.connection, "none")
        compare(metric.icon, Icons.networkDown)
    }
}
