import QtQuick

// SettingRow — a row of the settings page.
//
// The row names a setting of the bar and shows its value. The control
// depends on the type of the value: a field for a string, a stepper for a
// number, a switch for a boolean and a row of buttons for a choice.
Item {
    id: root

    // The name of the setting, the key of its value in the settings.
    property string key: ""

    // The name of the setting that is shown.
    property string label: ""

    // The kind of the value: "text", "color", "command", "number",
    // "toggle" or "choice".
    property string type: "text"

    // The smallest and the biggest value of a number.
    property int min: 0
    property int max: 100

    // The unit of a number, shown next to it.
    property string unit: ""

    // The values that can be chosen and the names that are shown for them.
    property var choices: []
    property var labels: []

    // The hint of a field, shown while it is empty.
    property string hint: ""

    // Whether a test of this command needs a confirmation.
    property bool destructive: false

    // The value of the setting.
    readonly property var value: root.key === "" ? undefined : Settings[root.key]

    // A command row carries the argument preview, the test action and the
    // result below its field, so it is as tall as its content. The other
    // rows keep the fixed height of the page.
    implicitHeight: root.type === "command" ? command.implicitHeight + 4 : 28

    // Write a new value to the setting.
    function store(val) {
        if (root.key !== "")
            Settings.set(root.key, val)
    }

    // The name of the setting. A command row is taller than its field, so
    // its label lines up with the field instead of the middle of the row.
    Label {
        anchors.left: parent.left
        width: parent.width * 0.45
        y: root.type === "command" ? 7 : (root.height - implicitHeight) / 2
        text: root.label
        color: Theme.fg3
        pixelSize: 12
        elide: Text.ElideRight
    }

    // The field of a string.
    SettingText {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.type === "text" || root.type === "color"
        width: parent.width * 0.5
        value: root.value === undefined ? "" : String(root.value)
        hint: root.hint
        swatch: root.type === "color"
        onEdited: text => root.store(text)
    }

    // The field, the argument preview and the test action of a command.
    SettingCommand {
        id: command
        anchors.right: parent.right
        anchors.top: parent.top
        visible: root.type === "command"
        width: parent.width * 0.5
        value: root.value === undefined ? "" : String(root.value)
        hint: root.hint
        destructive: root.destructive
        onEdited: text => root.store(text)
    }

    // The stepper of a number.
    SettingNumber {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.type === "number"
        width: 120
        value: root.value === undefined ? 0 : Number(root.value)
        min: root.min
        max: root.max
        unit: root.unit
        onEdited: value => root.store(value)
    }

    // The switch of a boolean.
    SettingToggle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.type === "toggle"
        value: root.value === undefined ? false : Boolean(root.value)
        onEdited: value => root.store(value)
    }

    // The buttons of a choice.
    SettingChoice {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        visible: root.type === "choice"
        width: parent.width * 0.5
        value: root.value
        choices: root.choices
        labels: root.labels
        onEdited: value => root.store(value)
    }
}
