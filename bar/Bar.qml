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

    // The names of the connected screens.
    readonly property var connectedOutputs: {
        const names = []
        for (let i = 0; i < Quickshell.screens.length; i++)
            names.push(Quickshell.screens[i].name)
        return names
    }

    // waybar's "output" option: the bar is only shown on these outputs.
    // The outputs are a setting of the bar; an empty list shows the bar on
    // every output, and a list that matches no connected screen falls back
    // to every output so the settings stay reachable.
    readonly property var outputPlan: BarOutputs.plan(Settings.outputs,
        root.connectedOutputs)

    readonly property string outputName: screen ? screen.name : ""

    // The tooltip of the bar. Every output gets its own tooltip, the
    // modules ask the bar for it, so the tooltip of one output never shows
    // up on another.
    readonly property var tooltipPopup: tipPopup

    // The module popup that is open, if any. A module asks the bar before
    // it shows its tooltip, so a tip never draws over an open popup. A
    // tooltip does not claim this layer itself.
    property var activePopup: null

    anchors {
        left: true
        top: true
        right: true
    }

    implicitHeight: 31
    exclusiveZone: visible ? 31 : 0
    aboveWindows: true
    color: "transparent"

    visible: BarOutputs.shows(root.outputPlan, root.outputName)

    onOutputPlanChanged: BarOutputs.warn(root.outputPlan)
    Component.onCompleted: BarOutputs.warn(root.outputPlan)

    Rectangle {
        anchors.fill: parent
        color: Theme.mainBg

        Item {
            id: barContent
            anchors.fill: parent

            // ── tooltip ──────────────────────────────────────────────────────
            // A single popup is shared by every module of this bar.

            TooltipPopup {
                id: tipPopup
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
                DateModule {}
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
                Backlight {}
                Battery {}
            }
        }
    }
}
