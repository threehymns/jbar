import QtQuick

// SettingNumber — the number of a setting.
//
// The number is changed with the two buttons next to it, the value stays
// between the smallest and the biggest one of the setting.
Item {
    id: root

    // The value of the setting.
    property int value: 0

    // The smallest and the biggest value of the setting.
    property int min: 0
    property int max: 100

    // The unit of the value, shown next to it.
    property string unit: ""

    // The value was changed.
    signal edited(int value)

    implicitHeight: 26
    implicitWidth: 120

    // Change the value by one step.
    function step(direction) {
        let next = root.value + direction
        if (next < root.min)
            next = root.min
        if (next > root.max)
            next = root.max
        if (next !== root.value)
            root.edited(next)
    }

    // The button that lowers the value.
    Rectangle {
        id: minus
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: 6
        color: minusMouse.containsMouse ? Theme.bg2 : Theme.bg1

        Text {
            anchors.centerIn: parent
            text: "−"
            color: Theme.mainFg
            font.family: Theme.fontFamily
            font.pixelSize: 14
        }

        MouseArea {
            id: minusMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.step(-1)
        }
    }

    // The value of the setting.
    Label {
        anchors.centerIn: parent
        text: root.value + root.unit
        color: Theme.mainFg
        pixelSize: 13
    }

    // The button that raises the value.
    Rectangle {
        id: plus
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: 6
        color: plusMouse.containsMouse ? Theme.bg2 : Theme.bg1

        Text {
            anchors.centerIn: parent
            text: "+"
            color: Theme.mainFg
            font.family: Theme.fontFamily
            font.pixelSize: 14
        }

        MouseArea {
            id: plusMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.step(1)
        }
    }
}
