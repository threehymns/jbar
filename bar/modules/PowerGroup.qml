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
Item {
    id: root

    property int duration: 150

    // The bar window, needed to anchor the idle inhibitor.
    property var barRef: null

    // The group is open while one of its modules is hovered.
    readonly property bool open: power.hovered || idle.hovered

    implicitWidth: power.width + (open ? idle.width : 0)
    implicitHeight: 31

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.OutCubic
        }
    }

    // Power button
    Module {
        id: power
        x: root.width - power.width

        bg: "transparent"
        // #custom-power { padding: 0 19px 0 16px; font-size: 18px; }
        padLeft: 16
        padRight: 19
        hoverBackground: true
        fg: Theme.accent

        onClicked: Quickshell.execDetached(["wlogout"])

        Text {
            text: Icons.power
            font.family: Theme.iconFont
            font.pixelSize: 18
            color: power.labelColor
        }
    }

    // The drawer the idle inhibitor slides out of.
    Item {
        id: drawer
        x: 0
        width: root.open ? idle.width : 0
        height: 31
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.OutCubic
            }
        }

        // Idle inhibitor
        Module {
            id: idle
            x: 0

            bg: Theme.mainBg
            minChars: 3
            stateDim: !idle.active
            interactive: root.open
            visible: root.open

            property bool active: false

            onClicked: idle.active = !idle.active

            Text {
                text: idle.active ? Icons.idleActive : Icons.idleInactive
                font.family: Theme.iconFont
                font.pixelSize: Theme.fontSize
                color: idle.labelColor
            }

            IdleInhibitor {
                id: inhibitor
                window: root.barRef
                enabled: idle.active
            }
        }
    }
}
