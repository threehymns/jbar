import QtQuick
import Quickshell.Io
import "../"

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

    property real totalBytes: 0
    property real usedBytes: 0

    readonly property int percentage: totalBytes > 0 ? Math.round(100 * usedBytes / totalBytes) : 0
    readonly property bool warning: percentage >= warningThreshold
    readonly property bool critical: percentage >= criticalThreshold

    fg: critical ? Theme.critical : (warning ? Theme.warning : Theme.mainFg)
    tip: "Memory Used: " + (usedBytes / 1073741824).toFixed(1) + "/"
        + (totalBytes / 1073741824).toFixed(1) + " GiB"

    // the waybar config swaps the icon for the warning/critical variants
    iconText: root.warning ? Icons.memoryWarning : Icons.memory
    labelText: root.percentage + "%"

    Process {
        id: memProc
        command: ["sh", "-c", "awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{print t, a}' /proc/meminfo"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                const total = parseInt(parts[0])
                const available = parseInt(parts[1])
                if (isNaN(total) || isNaN(available))
                    return
                root.totalBytes = total * 1024
                root.usedBytes = (total - available) * 1024
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: memProc.running = true
    }
}
