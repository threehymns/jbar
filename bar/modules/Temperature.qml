import QtQuick
import "../"
import "../adapters/"

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

    readonly property Metric metric: Metric {
        parse: output => {
            const value = parseInt(output)
            return isNaN(value) ? null : value / 1000
        }
        // the scale of the icons covers the critical threshold
        scaleMax: root.criticalThreshold
        glyphs: Icons.temperature
    }

    readonly property Poller poller: Poller {
        metric: root.metric
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone"
            + root.thermalZone + "/temp 2>/dev/null | head -1"]
        interval: 10000
    }

    readonly property real celsius: metric.value
    readonly property int fahrenheit: Math.round(celsius * 1.8 + 32)
    readonly property bool critical: fahrenheit >= criticalThreshold

    fg: critical ? Theme.critical : Theme.mainFg
    tip: "Temperature in Fahrenheit: " + fahrenheit + "°F"

    iconText: critical ? Icons.tempCritical : metric.glyph
    labelText: fahrenheit + "°F"
}
