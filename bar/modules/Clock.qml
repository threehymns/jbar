import QtQuick
import Quickshell
import Quickshell.Io
import "../"

// Clock — port of the waybar "clock#time" module.
//
// Displays the time and toggles between the 24 hour and the 12 hour format
// when clicked, the same way the waybar clock-toggle.sh script does. The
// choice is stored in the quickshell state directory.
Module {
    id: root

    bg: Theme.time
    // #clock.time { padding-right: 6px; padding-left: 6px; }
    padLeft: 6
    padRight: 6
    minChars: 5

    property bool twentyFourHour: true
    property var now: new Date()

    readonly property string stateFile: Quickshell.statePath("clock-format")

    // The waybar tooltip shows the time in the other format.
    tip: !root.now ? "" : (root.twentyFourHour
        ? "Standard Time: " + Qt.formatTime(root.now, "h:mm AP").toLowerCase()
        : "24 Hour Time: " + Qt.formatTime(root.now, "HH:mm"))

    onClicked: toggleFormat()

    function toggleFormat() {
        root.twentyFourHour = !root.twentyFourHour
        Quickshell.execDetached(["sh", "-c",
            "mkdir -p \"$(dirname " + root.stateFile + ")\" && echo "
            + (root.twentyFourHour ? "24" : "12") + " > " + root.stateFile])
    }

    Text {
        text: !root.now ? "" : (root.twentyFourHour
            ? Qt.formatTime(root.now, "HH:mm")
            : Qt.formatTime(root.now, "h:mm AP"))
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    // Restore the previously chosen format.
    Process {
        id: stateProc
        command: ["sh", "-c", "cat " + root.stateFile + " 2>/dev/null"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim()
                if (value === "12" || value === "24")
                    root.twentyFourHour = value === "24"
            }
        }
    }
}
