import QtQuick

// SettingCommand — a command line of a setting.
//
// The field edits the line, the text below it shows the exact argument
// vector the bar will run. Seeing the split is the point: a quote that
// starts inside an argument stays with that argument, while shell syntax
// is refused and its error is shown instead.
Item {
    id: root

    // The command line of the setting.
    property string value: ""

    // The hint of the field, shown while it is empty.
    property string hint: ""

    // The command line was edited.
    signal edited(string text)

    // The reason the line cannot run, empty when it can.
    readonly property string error: Settings.commandError(root.value)

    // The arguments that will be passed to the process.
    readonly property var args: Settings.command(root.value)

    // The vector the user can compare with what they wrote. JSON quotes
    // every argument, so a space or an empty argument is visible.
    readonly property string preview: root.error !== ""
        ? root.error : "runs " + JSON.stringify(root.args)

    implicitHeight: 42
    implicitWidth: 200

    SettingText {
        id: field
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        value: root.value
        hint: root.hint
        onEdited: text => root.edited(text)
    }

    Text {
        id: preview
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: field.bottom
        anchors.topMargin: 2
        text: root.preview
        color: root.error !== "" ? Theme.critical : Theme.fg3
        font.family: Theme.fontFamily
        font.pixelSize: 10
        elide: Text.ElideRight
    }
}
