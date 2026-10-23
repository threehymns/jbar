import QtQuick
import "../"
import "../adapters/"

// Workspaces — port of the waybar "niri/workspaces" module.
//
// Shows one dot per workspace of the current output, the focused one in the
// accent colour. Clicking a workspace focuses it, scrolling moves the focus
// up and down the list.
Rectangle {
    id: root

    // Name of the output this bar lives on; only workspaces of that output
    // are shown (waybar's "all-outputs" is left at its default of false).
    property string outputName: ""

    color: Theme.workspaces
    implicitHeight: Theme.rowHeight
    implicitWidth: row.implicitWidth + 2 * Theme.workspacePadding

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        // #workspaces { padding: 0 1px; }
        anchors.leftMargin: Theme.workspacePadding
        spacing: 0

        Repeater {
            model: Niri.workspaces

            delegate: Item {
                id: ws
                required property var modelData

                readonly property bool active: modelData.isActive || modelData.isFocused
                readonly property bool onThisOutput: outputName === "" || modelData.output === outputName

                visible: onThisOutput
                // A workspace is a square cell as tall as the bar, so the
                // glyph has the same room around it at every font size.
                implicitWidth: Theme.workspaceCell
                implicitHeight: Theme.workspaceCell

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: ws.modelData.isActive ? Icons.workspaceActive : Icons.workspaceDefault
                    font.family: Theme.iconFont
                    font.pixelSize: ws.active ? Theme.workspaceActiveSize : Theme.fontSize
                    color: ws.active ? Theme.accent : Theme.mainFg
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton

                    onClicked: Niri.focusWorkspace(ws.modelData.id)

                    onWheel: wheel => {
                        if (wheel.angleDelta.y > 0)
                            Niri.focusWorkspaceUp()
                        else if (wheel.angleDelta.y < 0)
                            Niri.focusWorkspaceDown()
                    }
                }
            }
        }
    }
}
