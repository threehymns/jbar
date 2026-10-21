import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../"

// Bluetooth — port of the waybar "bluetooth" module.
//
// The icon reflects the state of the adapter: connected, enabled or off.
Module {
    id: root

    bg: Theme.tray
    // #bluetooth { padding: 0 5px; }
    padLeft: 5
    padRight: 5
    minChars: 2
    dimOnHover: true

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter !== null && adapter.enabled
    readonly property bool connected: {
        const devices = Bluetooth.devices.values
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                return true
        }
        return false
    }

    readonly property string icon: {
        if (root.connected)
            return Icons.bluetoothConnected
        if (root.enabled)
            return Icons.bluetooth
        return Icons.bluetoothDisabled
    }

    onClicked: Quickshell.execDetached(["xdg-open",
        "vicinae://launch/@Gelei/store.vicinae.bluetooth/devices"])

    iconText: root.icon
}
