import QtQuick
import "../"
import "../metrics/"

// Cpu — port of the waybar "cpu" module.
//
// The metric of the processor knows the command, the parsing and the
// thresholds of the waybar config, the module only draws it. The metric and
// its poller are shared by every bar, see bar/Metrics.qml.
Module {
    id: root

    bg: Theme.cpu
    minChars: 7

    readonly property CpuMetric metric: Metrics.cpu

    fg: root.metric.critical ? Theme.critical
        : (root.metric.warning ? Theme.warning : Theme.mainFg)

    iconText: Icons.cpu
    labelText: root.metric.value + "%"
}
