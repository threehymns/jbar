import QtQuick
import QtQuick.Controls

// SettingText — the text of a setting.
//
// The value is edited in a field. A setting of a colour shows a swatch of
// the colour next to the field.
Item {
    id: root

    // The value of the setting.
    property string value: ""

    // The hint of the field, shown while it is empty.
    property string hint: ""

    // Whether the value is a colour.
    property bool swatch: false

    // The value was edited.
    signal edited(string text)

    implicitHeight: 26
    implicitWidth: 200

    // The swatch of a colour.
    Rectangle {
        id: swatchBox
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: root.swatch
        width: 16
        height: 16
        radius: 4
        color: root.value
        border.width: 1
        border.color: Theme.bg3
    }

    TextField {
        id: field
        anchors.left: swatchBox.visible ? swatchBox.right : parent.left
        anchors.leftMargin: swatchBox.visible ? 6 : 0
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 26
        text: root.value
        placeholderText: root.hint
        color: Theme.mainFg
        placeholderTextColor: Theme.bg4
        font.family: Theme.fontFamily
        font.pixelSize: 12
        selectByMouse: true
        leftPadding: 6
        rightPadding: 6

        background: Rectangle {
            radius: 6
            color: Theme.bg1
            border.width: 1
            border.color: field.activeFocus ? Theme.accent : Theme.bg3
        }

        onEditingFinished: root.edited(field.text)

        // The field shows the start of the value, not its end.
        Component.onCompleted: field.cursorPosition = 0
    }

    // The setting is the truth, so the field follows it.
    onValueChanged: {
        if (field.text !== root.value) {
            field.text = root.value
            if (!field.activeFocus)
                field.cursorPosition = 0
        }
    }
}
