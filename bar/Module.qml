import QtQuick

// Module — base class for every bar module.
//
// A module is a full height rectangle painted with the module background
// colour, the horizontal padding taken from the waybar stylesheet and the
// shared mouse handling (left / middle / right click, wheel, hover tooltip).
//
// The label colour follows the waybar states.css rules:
//   * `dimOnHover` dims the label while the module is hovered
//   * `stateDim` keeps the label dimmed (muted volume, paused player, …)
Rectangle {
    id: root

    // Background of the module (a Theme.* colour).
    property color bg: "transparent"

    // Horizontal padding, ported from the waybar stylesheet.
    property int padLeft: 10
    property int padRight: 10

    // Minimum label width in characters (waybar's "min-length").
    property int minChars: 0

    // Gap between the items inside the module.
    property int contentSpacing: 0

    // Draw a rounded hover background behind the module (the waybar power
    // button has one).
    property bool hoverBackground: false

    // Whether the module reacts to the mouse. Hidden modules of a drawer
    // turn this off so they do not swallow the events of their neighbours.
    property bool interactive: true

    // Tooltip text. Empty disables the tooltip.
    property string tip: ""

    // Base label colour.
    property color fg: Theme.mainFg
    // Dim the label on hover (states.css :hover rules).
    property bool dimOnHover: false
    // Keep the label dimmed regardless of hover (states.css inactive rules).
    property bool stateDim: false

    signal clicked()
    signal middleClicked()
    signal rightClicked()
    signal scrolled(int direction) // +1 = up, -1 = down
    signal hoveredEnter()
    signal hoveredLeave()

    readonly property bool hovered: mouse.containsMouse
    readonly property color labelColor: (stateDim || (dimOnHover && hovered)) ? Theme.hoverFg : fg

    implicitHeight: 31
    implicitWidth: Math.max(contentRow.implicitWidth, minChars > 0 ? Theme.minWidth(minChars) : 0)
        + padLeft + padRight
    color: bg

    // Hover background, painted below the content.
    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.hoverBackground && root.hovered ? Theme.hoverBg : "transparent"
    }

    // Content of the module. Modules add their labels here.
    default property alias content: contentRow.data

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.padLeft
        spacing: root.contentSpacing
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.hoveredEnter()
            if (root.tip !== "")
                Tooltip.show(root, root.tip)
        }
        onExited: {
            root.hoveredLeave()
            Tooltip.hide()
        }

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                root.clicked()
            else if (mouse.button === Qt.MiddleButton)
                root.middleClicked()
            else if (mouse.button === Qt.RightButton)
                root.rightClicked()
        }

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                root.scrolled(1)
            else if (wheel.angleDelta.y < 0)
                root.scrolled(-1)
        }
    }
}
