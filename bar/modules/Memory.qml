import QtQuick
import "../"
import "../adapters/"
import "../metrics/"

// Memory — port of the waybar "memory" module.
//
// The metric of the memory knows the command, the parsing and the
// thresholds of the waybar config, the module only draws it.
Module {
    id: root

    bg: Theme.memory
    minChars: 7

    readonly property MemoryMetric metric: MemoryMetric {
        warningThreshold: Settings.memoryWarning
        criticalThreshold: Settings.memoryCritical
        interval: Settings.memoryInterval * 1000
    }

    // The poll that fills the metric.
    readonly property Poller poller: Poller { metric: root.metric }

    fg: root.metric.critical ? Theme.critical
        : (root.metric.warning ? Theme.warning : Theme.mainFg)
    tip: root.metric.tip

    // the waybar config swaps the icon for the warning/critical variants
    iconText: root.metric.warning ? Icons.memoryWarning : Icons.memory
    labelText: root.metric.value + "%"
}
