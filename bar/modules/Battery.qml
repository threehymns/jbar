import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import "../"

// Battery — port of the waybar "battery" module.
//
// Shows the charge level of the battery and opens the power profile menu
// when clicked. The waybar "events" section is reproduced with
// notifications.
Module {
    id: root

    bg: Theme.battery
    minChars: 7

    // The bar window, needed to anchor the profile menu.
    property var barRef: null

    property int warningThreshold: 20
    property int criticalThreshold: 10

    readonly property var device: {
        if (!UPower.devices)
            return null
        const devices = UPower.devices.values
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].type === UPowerDeviceType.Battery)
                return devices[i]
        }
        return null
    }

    readonly property bool present: device !== null

    // UPower reports a percentage of its own, which is not the charge level
    // of the battery, so the level is calculated from the energy like the
    // waybar battery module does.
    readonly property int percentage: {
        if (!device)
            return 0
        if (device.energyCapacity > 0)
            return Math.round(100 * device.energy / device.energyCapacity)
        return Math.round(device.percentage)
    }

    readonly property bool charging: device !== null
        && device.state === UPowerDeviceState.Charging
    readonly property bool full: device !== null
        && device.state === UPowerDeviceState.FullyCharged
    readonly property bool discharging: device !== null
        && device.state === UPowerDeviceState.Discharging

    readonly property bool warning: !charging && percentage <= warningThreshold
    readonly property bool critical: !charging && percentage <= criticalThreshold

    readonly property string icon: {
        if (root.charging)
            return Icons.batteryCharging
        // waybar splits the charge into ten steps
        const index = Math.min(Icons.battery.length - 1, Math.floor(root.percentage / 10))
        return Icons.battery[index]
    }

    fg: root.critical ? Theme.critical : (root.warning ? Theme.warning
        : (root.charging ? Theme.charging : Theme.mainFg))

    tip: root.charging
        ? "<b>Charging</b>: " + root.timeLeft
        : "<b>Discharging</b>: " + root.timeLeft

    readonly property string timeLeft: {
        if (!device)
            return ""
        const seconds = root.charging ? device.timeToFull : device.timeToEmpty
        if (!seconds)
            return ""
        const minutes = Math.round(seconds / 60)
        return Math.floor(minutes / 60) + "h " + (minutes % 60) + "min"
    }

    onClicked: profileMenu.visible = !profileMenu.visible
    onHoveredLeave: profileMenu.visible = false

    visible: present

    iconText: root.charging ? Icons.batteryCharging : root.icon
    labelText: root.percentage + "%"

    // ── power profile menu ──────────────────────────────────────────────────

    PopupWindow {
        id: profileMenu
        color: "transparent"
        visible: false
        implicitWidth: 180
        implicitHeight: 120

        anchor.window: root.barRef
        anchor.rect.x: {
            if (!root.barRef || !root.barRef.contentItem)
                return 0
            const pos = root.mapToItem(root.barRef.contentItem, 0, 0)
            return Math.round(pos.x + root.width / 2 - width / 2)
        }
        anchor.rect.y: root.barRef ? root.barRef.height : 0

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Theme.mainBg
            border.width: 2
            border.color: Theme.mainBr

            Column {
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: [
                        { label: "Performance", profile: PowerProfile.Performance },
                        { label: "Balanced", profile: PowerProfile.Balanced },
                        { label: "Power Saver", profile: PowerProfile.PowerSaver }
                    ]

                    delegate: Rectangle {
                        id: entry
                        required property var modelData
                        readonly property bool current: PowerProfiles.profile === modelData.profile

                        width: 168
                        height: 30
                        radius: 8
                        color: entryMouse.containsMouse ? Theme.hoverBg : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: (entry.current ? "✓ " : "  ") + entry.modelData.label
                            color: entry.current ? Theme.mainFg : Theme.fg3
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: entryMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                PowerProfiles.profile = entry.modelData.profile
                                profileMenu.visible = false
                            }
                        }
                    }
                }
            }
        }
    }

    // ── notifications (waybar "events") ──────────────────────────────────────

    property bool warned: false
    property bool criticalNotified: false
    property bool chargedNotified: false

    onPercentageChanged: checkEvents()
    onChargingChanged: checkEvents()

    function checkEvents() {
        if (!present)
            return
        if (discharging && percentage <= criticalThreshold && !criticalNotified) {
            criticalNotified = true
            warned = true
            notify("Battery Critical (" + criticalThreshold + "%)", "critical", "battery-010")
        } else if (discharging && percentage <= warningThreshold && !warned) {
            warned = true
            notify("Battery Low (" + warningThreshold + "%)", "critical", "battery-020")
        } else if (charging && percentage >= 100 && !chargedNotified) {
            chargedNotified = true
            notify("Battery Full (100%)", "normal", "battery-100-charged")
        }
    }

    function notify(summary, urgency, icon) {
        Quickshell.execDetached(["notify-send", summary, "-u", urgency, "-i", icon,
            "-h", "string:x-canonical-private-synchronous:battery"])
    }
}
