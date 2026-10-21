import QtQuick
import Quickshell
import Quickshell.Io
import "../"

// Updates — port of the waybar "custom/update" module.
//
// Counts the pending system updates once an hour and opens the update
// helper when clicked.
Module {
    id: root

    bg: Theme.tray
    // #custom-update { padding: 0 8px 0 2px; }
    padLeft: 2
    padRight: 8
    minChars: 1
    dimOnHover: true

    property int count: 0
    readonly property bool visibleCount: count > 0

    onClicked: Quickshell.execDetached(["kitty", "-T", "Updates", "yay", "-Syua"])

    iconText: Icons.update
    labelText: root.count + ""

    Process {
        id: updateProc
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text.trim())
                root.count = isNaN(value) ? 0 : value
            }
        }
    }

    Timer {
        interval: 3600000
        running: true
        repeat: true
        onTriggered: updateProc.running = true
    }
}
