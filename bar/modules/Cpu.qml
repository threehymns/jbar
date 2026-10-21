import QtQuick
import "../"
import "../adapters/"

// Cpu — port of the waybar "cpu" module.
//
// Usage is derived from the deltas of /proc/stat, exactly like waybar does
// it. The warning and critical thresholds come from the waybar config.
Module {
    id: root

    bg: Theme.cpu
    minChars: 7

    property int warningThreshold: 75
    property int criticalThreshold: 90

    readonly property Metric metric: Metric {
        // a sample of /proc/stat is the idle and the total of the counters
        parse: output => {
            const parts = output.trim().split(/\s+/)
            const user = parseInt(parts[1]) || 0
            const nice = parseInt(parts[2]) || 0
            const system = parseInt(parts[3]) || 0
            const idle = parseInt(parts[4]) || 0
            const iowait = parseInt(parts[5]) || 0
            const irq = parseInt(parts[6]) || 0
            const softirq = parseInt(parts[7]) || 0
            const steal = parseInt(parts[8]) || 0

            return {
                idle: idle + iowait,
                total: user + nice + system + idle + iowait + irq + softirq + steal
            }
        }
        // the usage is the share of the counters that was not idle
        measure: (sample, previous) => {
            if (!previous)
                return null
            const diffTotal = sample.total - previous.total
            const diffIdle = sample.idle - previous.idle
            if (diffTotal <= 0)
                return null
            return Math.round((1 - diffIdle / diffTotal) * 100)
        }
        warningThreshold: root.warningThreshold
        criticalThreshold: root.criticalThreshold
    }

    readonly property Poller poller: Poller {
        metric: root.metric
        command: ["sh", "-c", "head -1 /proc/stat"]
        interval: 10000
    }

    readonly property int usage: metric.value
    readonly property bool warning: metric.warning
    readonly property bool critical: metric.critical

    fg: critical ? Theme.critical : (warning ? Theme.warning : Theme.mainFg)

    iconText: Icons.cpu
    labelText: root.usage + "%"
}
