import QtQuick
import QtQml

// BluetoothState — the icon of the Bluetooth module.
//
// The adapter state and the connected device are handed in by the module, so
// the icon decision is a plain object and can be tested without the Bluetooth
// service of Quickshell.
QtObject {
    id: root

    // Whether the Bluetooth adapter is on.
    property bool adapterEnabled: false

    // Whether a device is connected.
    property bool connected: false

    // The icon of the state: connected, enabled or off.
    readonly property string icon: {
        if (root.connected)
            return Icons.bluetoothConnected
        if (root.adapterEnabled)
            return Icons.bluetooth
        return Icons.bluetoothDisabled
    }
}
