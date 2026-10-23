import QtQuick
import Quickshell
import Quickshell.Wayland._IdleInhibitor
import "../"

// IdleToggle — the switch of the idle inhibitor.
//
// It is the port of the waybar "group/idle_inhibitor" module. It holds the
// idle timer of the compositor while it is on.
Module {
    id: root

    bg: Theme.mainBg
    minChars: 3
    stateDim: !root.active

    property bool active: false

    onClicked: root.active = !root.active

    iconText: root.active ? Icons.idleActive : Icons.idleInactive

    IdleInhibitor {
        id: inhibitor
        window: root.barWindow
        enabled: root.active
    }
}
