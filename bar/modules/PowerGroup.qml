import QtQuick
import Quickshell
import Quickshell.Wayland._IdleInhibitor
import "../"

// PowerGroup — port of the waybar "group/idle_inhibitor" module.
//
// The group holds the power button and the idle inhibitor.
//
// The group uses the waybar "drawer" option: the idle inhibitor is hidden
// under the power button and slides out to the left while the group is
// hovered. The power button itself keeps its place.
DrawerGroup {
    id: root

    // Power button
    Module {
        id: power

        bg: "transparent"
        // #custom-power { padding: 0 19px 0 16px; font-size: 18px; }
        padLeft: 16
        padRight: 19
        hoverBackground: true
        fg: Theme.accent

        onClicked: Quickshell.execDetached(["wlogout"])

        iconText: Icons.power
        iconPixelSize: 18
    }

    // The idle inhibitor slides out of the group.
    hidden: Module {
        id: idle

        bg: Theme.mainBg
        minChars: 3
        stateDim: !idle.active

        property bool active: false

        onClicked: idle.active = !idle.active

        iconText: idle.active ? Icons.idleActive : Icons.idleInactive

        IdleInhibitor {
            id: inhibitor
            window: idle.barWindow
            enabled: idle.active
        }
    }
}
