import QtQuick
import "../"

// CpuMetric — the metric of the processor.
//
// The usage is derived from the deltas of /proc/stat, exactly like waybar
// does it. The warning and the critical thresholds come from the waybar
// config.
Metric {
    // The command that reads the value. head is run directly, not through
    // a shell, so a poll is one process instead of two.
    readonly property var command: ["head", "-1", "/proc/stat"]

    // How often the command runs, in milliseconds.
    property int interval: 10000

    // The thresholds of the waybar config.
    warningThreshold: 75
    criticalThreshold: 90

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
}
