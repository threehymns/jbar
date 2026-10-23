import QtQuick
import "../"
import "../adapters/"
import "../metrics/"

// Temperature — port of the waybar "temperature" module.
//
// The metric of the temperature knows the command, the parsing, the unit
// and the thresholds of the waybar config, the module only draws it.
Module {
    id: root

    bg: Theme.temperature
    minChars: 8

    readonly property TemperatureMetric metric: TemperatureMetric {
        unit: Settings.temperatureUnit
        thermalZone: Settings.thermalZone
        criticalCelsius: Settings.temperatureCritical
        interval: Settings.temperatureInterval * 1000
    }

    // The poll that fills the metric.
    readonly property Poller poller: Poller { metric: root.metric }

    fg: root.metric.critical ? Theme.critical : Theme.mainFg
    tip: root.metric.tip

    iconText: root.metric.critical ? Icons.tempCritical : root.metric.glyph
    labelText: root.metric.value + root.metric.unitLabel
}
