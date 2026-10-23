import QtQuick
import "../"

// TemperatureMetric — the metric of the temperature.
//
// The waybar config reads thermal zone 1 and marks the module critical from
// 194°F (90°C) on, which also switches the label to the critical icon.
//
// The thermal zone reports millidegrees of Celsius, so Celsius is the value
// the metric keeps: the unit is only the way the value is displayed. Parsing
// the sample once and converting it on read means a unit switch converts the
// value that is already on the bar at once, and the next poll stores the
// same Celsius value again instead of converting a converted value.
Metric {
    id: root

    // The unit the temperature is shown in: "F" or "C".
    property string unit: "F"

    // The thermal zone the temperature is read from.
    property int thermalZone: 1

    // The temperature that is critical, in degrees Celsius.
    property real criticalCelsius: 90

    // The raw temperature of the last sample, in degrees Celsius. It is the
    // source of truth: the value, the threshold, the scale of the glyphs and
    // the tooltip are all derived from it, so they switch unit together.
    property real celsius: 0

    // The command that reads the value.
    readonly property var command: ["sh", "-c",
        "cat /sys/class/thermal/thermal_zone" + thermalZone
        + "/temp 2>/dev/null | head -1"]

    // How often the command runs, in milliseconds.
    property int interval: 10000

    // The value in the unit of the module. It is a binding, not a stored
    // sample: a unit change re-evaluates it at once. accept() writes the raw
    // sample to `celsius`, so nothing overwrites the binding.
    value: Math.round(root.toDisplay(root.celsius, root.unit))

    // Convert a temperature in Celsius to a display unit.
    function toDisplay(degreesCelsius, targetUnit) {
        return targetUnit === "C" ? degreesCelsius
            : degreesCelsius * 9 / 5 + 32
    }

    // Convert a temperature in a display unit to Celsius.
    function toCelsius(degrees, sourceUnit) {
        return sourceUnit === "C" ? degrees
            : (degrees - 32) * 5 / 9
    }

    // critical-threshold (in the unit of the value)
    criticalThreshold: root.toDisplay(root.criticalCelsius, root.unit)

    // the thermal zone reports millidegrees of Celsius, in every unit
    parse: output => {
        const millidegrees = parseInt(output)
        if (isNaN(millidegrees))
            return null
        return millidegrees / 1000
    }

    // Metric.accept() stores the sample in `value`, which is derived here;
    // the sample belongs in `celsius` so the display can follow the unit.
    function accept(output) {
        const parsed = root.parse(output)
        if (parsed === null || parsed === undefined)
            return
        root.previousSample = root.sample
        root.sample = parsed
        const measured = root.measure(root.sample, root.previousSample)
        if (measured === null || measured === undefined)
            return
        root.celsius = measured
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
