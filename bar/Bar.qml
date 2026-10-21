import QtQuick
import Quickshell
import "modules/"

// Bar — the panel itself.
//
// Layout mirrors the waybar config:
//   modules-left   : workspaces, window title
//   modules-center : temperature, memory, cpu, distro, clock, date,
//                    network, bluetooth, updates
//   modules-right  : album art, mpris, volume, backlight, battery,
//                    idle inhibitor, power
PanelWindow {
    id: bar

    // waybar's "output" option: the bar is only shown on these outputs.
    property var outputs: ["eDP-1", "HDMI-A-1", "DP-2"]

    readonly property string outputName: screen ? screen.name : ""

    anchors {
        left: true
        top: true
        right: true
    }

    implicitHeight: 31
    exclusiveZone: visible ? 31 : 0
    aboveWindows: true
    color: "transparent"

    visible: outputs.length === 0 || outputs.indexOf(outputName) !== -1

    Rectangle {
        anchors.fill: parent
        color: Theme.mainBg

        Item {
            anchors.fill: parent

            // ── modules-left ────────────────────────────────────────────────
            Row {
                id: leftRow
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Workspaces {
                    outputName: bar.outputName
                }

                WindowTitle {}
            }

            // ── modules-center ─────────────────────────────────────────────
            Row {
                id: centerRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Temperature {}
                Memory {}
                Cpu {}
                Distro {}
                Clock {}
                DateModule {
                    barRef: bar
                }
                Network {}
                Bluetooth {}
                Updates {}
            }

            // ── modules-right ──────────────────────────────────────────────
            Row {
                id: rightRow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                AlbumArt {}
                Mpris {}
                Volume {}
                Backlight {
                    barRef: bar
                }
                Battery {
                    barRef: bar
                }
                PowerGroup {
                    barRef: bar
                }
            }
        }
    }

    // ── tooltip ────────────────────────────────────────────────────────────
    // A single popup is shared by every module.

    PopupWindow {
        id: tipPopup
        color: "transparent"
        visible: false

        // The module the tooltip belongs to.
        property Item target: null
        property string tipText: ""

        implicitWidth: tipLabel.implicitWidth + 20
        implicitHeight: tipLabel.implicitHeight + 14

        anchor.window: bar
        anchor.rect.x: {
            if (!tipPopup.target)
                return 0
            const pos = tipPopup.target.mapToItem(bar.contentItem, 0, 0)
            return Math.round(pos.x + tipPopup.target.width / 2 - width / 2)
        }
        anchor.rect.y: bar.height + 4

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Theme.mainBg
            border.width: 2
            border.color: Theme.mainBr

            Text {
                id: tipLabel
                anchors.centerIn: parent
                text: tipPopup.tipText
                color: Theme.mainFg
                font.family: Theme.fontFamily
                font.pixelSize: 13
            }
        }
    }

    Component.onCompleted: {
        Tooltip.popup = tipPopup
        Tooltip.host = bar
    }

}
