import QtQuick

// SettingToggle — the switch of a setting.
//
// The switch is on when the value of the setting is true.
Item {
    id: root

    // The value of the setting.
    property bool value: false

    // The value was changed.
    signal edited(bool value)

    implicitHeight: 22
    implicitWidth: 38

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.value ? Theme.accent : Theme.bg2

        // The knob of the switch.
        Rectangle {
            width: track.height - 6
            height: width
            radius: width / 2
            color: Theme.mainBg
            x: root.value ? track.width - width - 3 : 3
            y: 3

            Behavior on x {
                Motion { time: 120 }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.edited(!root.value)
        }
    }
}
