import QtQuick
import Quickshell.Io
import "../"

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

    property int usage: 0
    readonly property bool warning: usage >= warningThreshold
    readonly property bool critical: usage >= criticalThreshold

    fg: critical ? Theme.critical : (warning ? Theme.warning : Theme.mainFg)

    Text {
        text: Icons.cpu
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    Text {
        text: " " + root.usage + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    // Previous sample of /proc/stat, used to compute the deltas.
    property real previousIdle: 0
    property real previousTotal: 0

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                const user = parseInt(parts[1]) || 0
                const nice = parseInt(parts[2]) || 0
                const system = parseInt(parts[3]) || 0
                const idle = parseInt(parts[4]) || 0
                const iowait = parseInt(parts[5]) || 0
                const irq = parseInt(parts[6]) || 0
                const softirq = parseInt(parts[7]) || 0
                const steal = parseInt(parts[8]) || 0

                const totalIdle = idle + iowait
                const total = user + nice + system + idle + iowait + irq + softirq + steal

                if (root.previousTotal > 0) {
                    const diffTotal = total - root.previousTotal
                    const diffIdle = totalIdle - root.previousIdle
                    if (diffTotal > 0)
                        root.usage = Math.round((1 - diffIdle / diffTotal) * 100)
                }
                root.previousIdle = totalIdle
                root.previousTotal = total
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: cpuProc.running = true
    }
}
