import QtQuick

// SettingChoice — the choice of a setting.
//
// The choices are shown as buttons, the one of the value of the setting is
// the one that is picked.
Item {
    id: root

    // The value of the setting.
    property var value: ""

    // The values that can be chosen.
    property var choices: []

    // The names that are shown for the choices.
    property var labels: []

    // The value was changed.
    signal edited(var value)

    implicitHeight: 26
    implicitWidth: 160

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: root.choices

            delegate: Rectangle {
                id: choice
                required property var modelData
                required property int index

                readonly property bool current: root.value === choice.modelData
                readonly property string name: root.labels.length === root.choices.length
                    ? root.labels[choice.index] : String(choice.modelData)

                width: choiceLabel.implicitWidth + 18
                height: 26
                radius: 6
                color: choice.current ? Theme.accent
                    : (choiceMouse.containsMouse ? Theme.bg2 : Theme.bg1)

                Label {
                    id: choiceLabel
                    anchors.centerIn: parent
                    text: choice.name
                    color: choice.current ? Theme.mainBg : Theme.mainFg
                    pixelSize: 12
                }

                MouseArea {
                    id: choiceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.edited(choice.modelData)
                }
            }
        }
    }
}
