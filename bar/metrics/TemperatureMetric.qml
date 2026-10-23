import QtQuick
import "../"

// TemperatureMetric — the metric of the temperature.
//
// The waybar config reads thermal zone 1 and marks the module critical from
// 194°F (90°C) on, which also switches the label to the critical icon.
//
// The value of the metric is the temperature in the unit the module is
// displayed in, so the thresholds and the scale of the glyphs speak the
// same unit.
Metric {
    // The unit the temperature is shown in: "F" or "C".
    property string unit: "F"

    // The thermal zone the temperature is read from.
    property int thermalZone: 1

    // The temperature that is critical, in degrees Celsius.
    property real criticalCelsius: 90

    // The command that reads the value.
    readonly property var command: ["sh", "-c",
        "cat /sys/class/thermal/thermal_zone" + thermalZone
        + "/temp 2>/dev/null | head -1"]

    // How often the command runs, in milliseconds.
    property int interval: 10000

    // critical-threshold (in the unit of the value)
    criticalThreshold: unit === "C" ? criticalCelsius : criticalCelsius * 1.8 + 32

    // the thermal zone reports millidegrees of Celsius
    parse: output => {
        const value = parseInt(output)
        if (isNaN(value))
            return null
        const celsius = value / 1000
        return unit === "C" ? Math.round(celsius) : Math.round(celsius * 1.8 + 32)
    }

    // the scale of the icons covers the critical threshold
    scaleMax: criticalThreshold
    glyphs: Icons.temperature

    // The unit of the value, shown next to it.
    readonly property string unitLabel: unit === "C" ? "°C" : "°F"

    // The name of the unit, shown in the tooltip.
    readonly property string unitName: unit === "C" ? "Celsius" : "Fahrenheit"

    // The tooltip of the module.
    readonly property string tip: "Temperature in " + unitName + ": " + value + unitLabel
}
