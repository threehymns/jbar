import QtQuick
import QtQuick.Window
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
            id: barContent
            anchors.fill: parent

            // ── tooltip ──────────────────────────────────────────────────────
            // A single popup is shared by every module of this bar.

            Popup {
                id: tipPopup
                barWindow: bar
                property string tipText: ""

                implicitWidth: tipLabel.implicitWidth + 20
                implicitHeight: tipLabel.implicitHeight + 14

                Text {
                    id: tipLabel
                    anchors.centerIn: parent
                    text: tipPopup.tipText
                    color: Theme.mainFg
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
            }

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

    // The window of the bar. It is not known while the bar is built, so the
    // tooltip is registered as soon as it shows up. Every bar has its own
    // tooltip, so the tooltip of one output does not show up on another.
    readonly property var barWindow: barContent.Window.window
    property var registeredWindow: null

    onBarWindowChanged: {
        if (bar.registeredWindow)
            Tooltip.unregister(bar.registeredWindow)
        bar.registeredWindow = bar.barWindow
        if (bar.barWindow)
            Tooltip.register(bar.barWindow, tipPopup)
    }

    Component.onDestruction: {
        if (bar.registeredWindow)
            Tooltip.unregister(bar.registeredWindow)
    }



}
