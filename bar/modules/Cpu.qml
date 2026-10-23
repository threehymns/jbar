import QtQuick
import "../"
import "../adapters/"
import "../metrics/"

// Cpu — port of the waybar "cpu" module.
//
// The metric of the processor knows the command, the parsing and the
// thresholds of the waybar config, the module only draws it.
Module {
    id: root

    bg: Theme.cpu
    minChars: 7

    readonly property CpuMetric metric: CpuMetric {
        warningThreshold: Settings.cpuWarning
        criticalThreshold: Settings.cpuCritical
        interval: Settings.cpuInterval * 1000
    }

    // The poll that fills the metric.
    readonly property Poller poller: Poller { metric: root.metric }

    fg: root.metric.critical ? Theme.critical
        : (root.metric.warning ? Theme.warning : Theme.mainFg)

    iconText: Icons.cpu
    labelText: root.metric.value + "%"
}
