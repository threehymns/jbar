import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.UPower
import "../"
import "../metrics/"

// Battery — port of the waybar "battery" module.
//
// Shows the charge level of the battery and opens the power profile menu
// when clicked. The waybar "events" section is reproduced with
// notifications.
Module {
    id: root

    bg: Theme.battery
    minChars: 7

    property int warningThreshold: Settings.batteryWarning
    property int criticalThreshold: Settings.batteryCritical

    // The value comes from the device, the metric owns the states and the
    // glyphs of it.
    readonly property Metric metric: Metric {
        value: root.percentage
        // waybar splits the charge into ten steps
        glyphs: Icons.battery
        scaleMax: 100
        warningThreshold: root.warningThreshold
        criticalThreshold: root.criticalThreshold
        // the battery is bad when it is empty, not when it is full
        highIsBad: false
    }

    // UPower names the battery of the system in displayDevice, a peripheral
    // battery is only the fallback. The selection is a plain object so it can
    // be tested without UPower.
    readonly property BatteryDevice batteryDevice: BatteryDevice {}

    readonly property var device: batteryDevice.select(
        UPower.devices ? UPower.devices.values : [],
        UPower.displayDevice,
        UPowerDeviceType.Battery)

    readonly property bool present: device !== null

    // UPower reports a percentage of its own, which is not the charge level
    // of the battery, so the level is calculated from the energy like the
    // waybar battery module does.
    function chargeLevel() {
        const current = root.device
        if (!current)
            return 0
        if (current.energyCapacity > 0)
            return Math.round(100 * current.energy / current.energyCapacity)
        return Math.round(current.percentage)
    }

    readonly property int percentage: root.chargeLevel()

    readonly property bool charging: device !== null
        && device.state === UPowerDeviceState.Charging
    readonly property bool full: device !== null
        && device.state === UPowerDeviceState.FullyCharged
    readonly property bool discharging: device !== null
        && device.state === UPowerDeviceState.Discharging

    readonly property bool warning: !charging && metric.warning
    readonly property bool critical: !charging && metric.critical

    readonly property string icon: {
        if (root.charging)
            return Icons.batteryCharging
        return root.metric.glyph
    }

    fg: root.critical ? Theme.critical : (root.warning ? Theme.warning
        : (root.charging ? Theme.charging : Theme.mainFg))

    tip: "<b>" + root.batteryState.status + "</b>"
        + (root.timeLeft === "" ? "" : ": " + root.timeLeft)

    readonly property string timeLeft: {
        if (!device)
            return ""
        // a full battery has no time to empty, it is either still charging or
        // already fully charged
        const seconds = root.charging || root.batteryState.isFull
            ? device.timeToFull : device.timeToEmpty
        if (!seconds)
            return ""
        const minutes = Math.round(seconds / 60)
        return Math.floor(minutes / 60) + "h " + (minutes % 60) + "min"
    }

    onClicked: root.togglePopup()

    visible: root.device !== null

    iconText: root.charging ? Icons.batteryCharging : root.icon
    labelText: root.percentage + "%"

    // ── power profile menu ──────────────────────────────────────────────────

    popup: Popup {
        contentWidth: 180
        contentHeight: 120

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
                            root.closePopup()
                        }
                    }
                }
            }
        }
    }

    // ── notifications (waybar "events") ──────────────────────────────────────

    // The state machine owns the warning thresholds and the re-arming, the
    // module only turns its events into notifications.
    readonly property BatteryState batteryState: BatteryState {
        warningThreshold: root.warningThreshold
        criticalThreshold: root.criticalThreshold

        onLow: root.notify("Battery Low (" + root.warningThreshold + "%)",
            "critical", "battery-020")
        onCritical: root.notify("Battery Critical (" + root.criticalThreshold
            + "%)", "critical", "battery-010")
        onFullCharge: root.notify("Battery Full (100%)", "normal",
            "battery-100-charged")
    }

    Component.onCompleted: root.checkEvents()

    onDeviceChanged: checkEvents()
    onPercentageChanged: checkEvents()
    onChargingChanged: checkEvents()
    onFullChanged: checkEvents()
    onDischargingChanged: checkEvents()
    onWarningThresholdChanged: checkEvents()
    onCriticalThresholdChanged: checkEvents()

    function checkEvents() {
        if (!present)
            return
        // read the device itself: the bindings above may still hold the value
        // of the previous device while the properties update one by one
        const current = root.device
        batteryState.update(root.chargeLevel(),
            current.state === UPowerDeviceState.Charging,
            current.state === UPowerDeviceState.FullyCharged,
            current.state === UPowerDeviceState.Discharging)
    }

    function notify(summary, urgency, icon) {
        Quickshell.execDetached(["notify-send", summary, "-u", urgency, "-i", icon,
            "-h", "string:x-canonical-private-synchronous:battery"])
    }
}
