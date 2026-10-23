import QtQuick
import Quickshell.Bluetooth
import "../"

// Bluetooth — port of the waybar "bluetooth" module.
//
// The icon reflects the state of the adapter: connected, enabled or off. The
// module stays interactive with the adapter off, a click still opens the
// Bluetooth manager where the adapter can be turned on.
Module {
    id: root

    bg: Theme.tray
    // #bluetooth { padding: 0 5px; }
    padLeft: 5
    padRight: 5
    minChars: 2
    dimOnHover: true

    readonly property var adapter: Bluetooth.defaultAdapter
    // The state of the adapter. This is not Item.enabled: the module has to
    // stay clickable while the adapter is off.
    readonly property bool adapterEnabled: root.adapter !== null && root.adapter.enabled
    readonly property bool connected: {
        const devices = Bluetooth.devices.values
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                return true
        }
        return false
    }

    readonly property BluetoothState bluetoothState: BluetoothState {
        adapterEnabled: root.adapterEnabled
        connected: root.connected
    }

    readonly property string icon: root.bluetoothState.icon

    onClicked: root.run(Settings.bluetoothManagerCommand)

    iconText: root.icon
}
