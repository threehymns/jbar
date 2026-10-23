import QtQuick
import Quickshell
import "./"

// SettingsWindow — the settings in a window of their own.
//
// The page is the same one the popup of the bar shows, but the window does
// not belong to a bar: it can be opened while the bar is hidden or while no
// bar is running at all (settings.qml). The shell keeps one instance and
// only shows it again, so asking for the settings twice never creates a
// second window.
FloatingWindow {
    id: root

    // The size the page was designed for. The minimum keeps the header and
    // the rows of the page usable when the compositor lets the user resize
    // the window.
    implicitWidth: 520
    implicitHeight: 640
    minimumSize: Qt.size(360, 320)

    title: "jbar settings"
    color: Theme.mainBg
    visible: false

    // Show the window. A window that is already open is only asked to take
    // focus again; it is never created twice.
    function open() {
        if (!root.visible)
            root.visible = true
        root.activate()
    }

    // Close the window. The shell keeps the instance, so opening it again
    // shows the same window with the page in the state it was left in.
    function close() {
        root.visible = false
    }

    // Open the window when it is closed and close it when it is open.
    function toggle() {
        if (root.visible)
            root.close()
        else
            root.open()
    }

    // Focus the window and ask the compositor to raise it. Wayland may
    // ignore the activation request, but a compositor that grants it brings
    // the one settings window to the front.
    function activate() {
        // the frame exists before the window is exposed; ask for the focus
        // on the next frame, when the window can take it
        Qt.callLater(root.focus)
    }

    function focus() {
        if (!root.visible)
            return
        frame.forceActiveFocus()
        const window = frame.Window.window
        if (window)
            window.requestActivate()
    }

    // The compositor closed the window. The instance is kept for the next
    // open, only its visibility changed.
    onClosed: root.visible = false

    Rectangle {
        id: frame
        anchors.fill: parent
        color: Theme.mainBg
        border.width: 1
        border.color: Theme.mainBr

        // Escape closes the window. The handler sits on the frame so a
        // control that does not use Escape leaves the key to the window.
        focus: true
        Keys.onEscapePressed: root.close()

        Rectangle {
            id: header
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 40
            color: Theme.bg1

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "jbar settings"
                color: Theme.mainFg
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            // The close button. A window without a decoration has no other
            // way to be closed with the mouse.
            Rectangle {
                id: closeButton
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 24
                radius: 6
                color: closeMouse.containsMouse ? Theme.bg2 : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: closeMouse.containsMouse ? Theme.mainFg : Theme.fg3
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.close()
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            height: 1
            color: Theme.bg3
        }

        SettingsPage {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
        }
    }
}
