import QtQuick
import "../"

// MemoryMetric — the metric of the memory.
//
// Percentage of used memory (MemTotal - MemAvailable) with the warning and
// critical thresholds of the waybar config.
Metric {
    // The command that reads the value.
    readonly property var command: ["sh", "-c",
        "awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print t, a}' /proc/meminfo"]

    // How often the command runs, in milliseconds.
    property int interval: 10000

    // The thresholds of the waybar config.
    warningThreshold: 75
    criticalThreshold: 90

    // a sample is the total and the used memory in bytes
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

    // The used and the total memory in GiB.
    readonly property real usedGiB: sample ? sample.used / 1073741824 : 0
    readonly property real totalGiB: sample ? sample.total / 1073741824 : 0

    // The tooltip of the module.
    readonly property string tip: "Memory Used: " + usedGiB.toFixed(1) + "/"
        + totalGiB.toFixed(1) + " GiB"
}
