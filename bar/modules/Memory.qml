import QtQuick
import "../"
import "../adapters/"

// Memory — port of the waybar "memory" module.
//
// Percentage of used memory (MemTotal - MemAvailable) with the warning and
// critical thresholds of the waybar config.
Module {
    id: root

    bg: Theme.memory
    minChars: 7

    property int warningThreshold: 75
    property int criticalThreshold: 90

    readonly property Metric metric: Metric {
        parse: output => {
            const parts = output.trim().split(/\s+/)
            const total = parseInt(parts[0])
            const available = parseInt(parts[1])
            if (isNaN(total) || isNaN(available))
                return null
            return { total: total * 1024, used: (total - available) * 1024 }
        }
        measure: (sample, previous) => sample.total > 0
            ? Math.round(100 * sample.used / sample.total)
            : null
        warningThreshold: root.warningThreshold
        criticalThreshold: root.criticalThreshold
    }

    readonly property Poller poller: Poller {
        metric: root.metric
        command: ["sh", "-c",
            "awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print t, a}' /proc/meminfo"]
        interval: 10000
    }

    readonly property real totalBytes: metric.sample ? metric.sample.total : 0
    readonly property real usedBytes: metric.sample ? metric.sample.used : 0

    readonly property int percentage: metric.value
    readonly property bool warning: metric.warning
    readonly property bool critical: metric.critical

    fg: critical ? Theme.critical : (warning ? Theme.warning : Theme.mainFg)
    tip: "Memory Used: " + (usedBytes / 1073741824).toFixed(1) + "/"
        + (totalBytes / 1073741824).toFixed(1) + " GiB"

    // the waybar config swaps the icon for the warning/critical variants
    iconText: root.warning ? Icons.memoryWarning : Icons.memory
    labelText: root.percentage + "%"
}
