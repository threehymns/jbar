import QtQuick
import Quickshell.Io
import "../"

// Temperature — port of the waybar "temperature" module.
//
// The waybar config reads thermal zone 1 and marks the module critical from
// 194°F (90°C) on, which also switches the label to the critical icon.
Module {
    id: root

    bg: Theme.temperature
    minChars: 8

    // thermal-zone
    property int thermalZone: 1
    // critical-threshold (°F, the unit the module is displayed in)
    property int criticalThreshold: 194

    property real celsius: 0
    readonly property int fahrenheit: Math.round(celsius * 1.8 + 32)
    readonly property bool critical: fahrenheit >= criticalThreshold

    // waybar picks the icon from the temperature thresholds, using the
    // critical threshold as the upper bound of the scale.
    readonly property string icon: {
        const scale = Icons.temperature
        const divisor = Math.max(1, Math.floor(criticalThreshold / scale.length))
        const index = Math.max(0, Math.min(scale.length - 1, Math.floor(celsius / divisor)))
        return scale[index]
    }

    fg: critical ? Theme.critical : Theme.mainFg
    tip: "Temperature in Fahrenheit: " + fahrenheit + "°F"

    Text {
        text: root.critical ? Icons.tempCritical : root.icon
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    Text {
        text: " " + root.fahrenheit + "°F"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    Process {
        id: tempProc
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone" + root.thermalZone + "/temp 2>/dev/null | head -1"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text)
                if (!isNaN(value))
                    root.celsius = value / 1000
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: tempProc.running = true
    }
}
