import QtQuick
import "../"
import "../metrics/"

// Temperature — port of the waybar "temperature" module.
//
// The metric of the temperature knows the command, the parsing, the unit
// and the thresholds of the waybar config, the module only draws it. The
// metric and its poller are shared by every bar, see bar/Metrics.qml.
Module {
    id: root

    bg: Theme.temperature
    minChars: 8

    readonly property TemperatureMetric metric: Metrics.temperature

    fg: root.metric.critical ? Theme.critical : Theme.mainFg
    tip: root.metric.tip

    iconText: root.metric.critical ? Icons.tempCritical : root.metric.glyph
    labelText: root.metric.value + root.metric.unitLabel
}
