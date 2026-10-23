import QtQuick
import QtTest
import "../bar/"

// The tests of the state of the Bluetooth module.
//
// The Bluetooth service of Quickshell and the bar module cannot be
// instantiated by qmltestrunner (the Quickshell plugins live in the quickshell
// process), so the icon decision is a plain object. The adapter-off state is
// the regression this file covers.
//
// Offscreen reproduction of the click path: before the fix the module
// declared `property bool enabled`, which shadowed Item.enabled. With the
// adapter off that disabled the module and its MouseArea, so the disabled
// icon was drawn but a click never arrived.
//
// Qt Quick Test cannot load the Quickshell plugins, so the module itself is
// reproduced with Quickshell on a private bus that has no BlueZ adapter:
//
//     dbus-run-session -- env \
//         DBUS_SYSTEM_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
//         QT_QPA_PLATFORM=offscreen quickshell -p <harness>
//
// With the Bluetooth module in a window the harness logs adapterEnabled
// false, the disabled icon, connected false, Item.enabled true and the
// module's MouseArea enabled. The old module logged Item.enabled false with
// the same adapter, which is why Qt Quick dropped every click; the fixed
// module keeps Item.enabled true and onClicked still runs
// Settings.bluetoothManagerCommand.
TestCase {
    name: "BluetoothState"

    BluetoothState {
        id: state
    }

    function test_the_icon_follows_the_state_data() {
        return [
            { tag: "adapter off", adapterEnabled: false, connected: false,
                icon: Icons.bluetoothDisabled },
            { tag: "adapter on", adapterEnabled: true, connected: false,
                icon: Icons.bluetooth },
            { tag: "connected", adapterEnabled: true, connected: true,
                icon: Icons.bluetoothConnected }
        ]
    }

    function test_the_icon_follows_the_state(data) {
        state.adapterEnabled = data.adapterEnabled
        state.connected = data.connected
        compare(state.icon, data.icon)
    }

    function test_a_connected_device_wins_over_the_adapter_icon() {
        state.adapterEnabled = false
        state.connected = true
        compare(state.icon, Icons.bluetoothConnected)
    }
}
