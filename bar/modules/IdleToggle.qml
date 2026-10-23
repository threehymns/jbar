import QtQuick
import Quickshell.Wayland
import "../"

// IdleToggle — the switch of the idle inhibitor.
//
// It is the port of the waybar "group/idle_inhibitor" module. It holds the
// idle timer of the compositor while it is on.
//
// IdleInhibitor is part of the public Quickshell.Wayland module in
// Quickshell 0.3.1, whose qmldir re-exports the private implementation. Do
// not import Quickshell.Wayland._IdleInhibitor directly: the underscore
// modules are private and may change between Quickshell releases.
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
