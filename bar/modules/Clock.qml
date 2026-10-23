import QtQuick
import "../"

// Clock — port of the waybar "clock#time" module.
//
// Displays the time and toggles between the 24 hour and the 12 hour format
// when clicked, the same way the waybar clock-toggle.sh script does. The
// choice is a setting of the bar, so it is remembered.
Module {
    id: root

    bg: Theme.time
    // #clock.time { padding-right: 6px; padding-left: 6px; }
    padLeft: Theme.px(6)
    padRight: Theme.px(6)
    minChars: 5

    property bool twentyFourHour: Settings.clock24Hour
    property var now: new Date()

    // The waybar tooltip shows the time in the other format.
    tip: !root.now ? "" : (root.twentyFourHour
        ? "Standard Time: " + Qt.formatTime(root.now, "h:mm AP").toLowerCase()
        : "24 Hour Time: " + Qt.formatTime(root.now, "HH:mm"))

    onClicked: toggleFormat()

    function toggleFormat() {
        Settings.set("clock24Hour", !Settings.clock24Hour)
    }

    labelText: !root.now ? "" : (root.twentyFourHour
        ? Qt.formatTime(root.now, "HH:mm")
        : Qt.formatTime(root.now, "h:mm AP"))

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
