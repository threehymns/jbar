import QtQuick
import Quickshell

// Module — base class for every bar module.
//
// A module is a full height rectangle painted with the module background
// colour, the horizontal padding taken from the waybar stylesheet and the
// shared mouse handling (left / middle / right click, wheel, hover tooltip).
//
// The label colour follows the waybar states.css rules:
//   * `dimOnHover` dims the label while the module is hovered
//   * `stateDim` keeps the label dimmed (muted volume, paused player, …)
//
// The typography lives here as well: a module names its glyph and its value
// and the module draws them, so no module spells out a font again.
//
// A module owns its popup as well: it finds the window of the bar on its
// own, so a module that opens a popup is not handed the bar.
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

    // ── the window of the bar ──────────────────────────────────────────────

    // The window the module lives in. The module finds it on its own, so a
    // module does not have to be handed the bar.
    readonly property var barWindow: root.QsWindow.window

    // The tooltip popup of the bar. The bar owns one per output, the
    // module asks the bar for it.
    readonly property var tipPopup: root.barWindow
        ? root.barWindow.tooltipPopup : null

    // ── the popup of the module ────────────────────────────────────────────

    // The popup of this module. A module that wants one assigns it, the
    // base anchors it to the module and opens and closes it.
    property var popup: null

    // Whether the popup of this module is on screen, including the exit
    // animation. The tooltip stays away while it is.
    readonly property bool popupOpen: root.popup !== null && root.popup.visible

    onPopupChanged: {
        if (root.popup)
            root.popup.target = root
    }

    // ── the content of the module ─────────────────────────────────────────
    // The glyph of the module, drawn in the Nerd Font.
    property string iconText: ""
    // An image drawn in the icon slot instead of a glyph (the icon of the
    // focused window, the cover art of the player).
    property string iconImage: ""
    // The value of the module, drawn in the bar font.
    property string labelText: ""
    // The size of the icon slot in pixels.
    property int iconPixelSize: Theme.fontSize
    // The size of the value in pixels.
    property int labelPixelSize: Theme.fontSize
    // Elide the value after this many characters. 0 keeps it whole.
    property int labelMaxChars: 0

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

    // Content of the module. Modules that need more than the icon and the
    // value add their own items here.
    default property alias content: contentRow.data

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.padLeft
        spacing: root.contentSpacing

        // The icon and the value. The waybar formats separate the two with
        // a space, so the gap between them is the width of one.
        Row {
            id: labelRow
            visible: root.iconText !== "" || root.iconImage !== "" || root.labelText !== ""
            spacing: Theme.labelSpacing

            // The icon slot: a glyph, or an image.
            Item {
                id: iconSlot
                visible: root.iconText !== "" || root.iconImage !== ""
                width: root.iconImage !== "" ? root.iconPixelSize : iconLabel.width
                height: root.iconImage !== "" ? root.iconPixelSize : iconLabel.height

                Label {
                    id: iconLabel
                    anchors.centerIn: parent
                    visible: root.iconText !== ""
                    text: root.iconText
                    glyph: true
                    pixelSize: root.iconPixelSize
                    color: root.labelColor
                }

                Image {
                    anchors.centerIn: parent
                    visible: root.iconImage !== ""
                    source: root.iconImage
                    width: root.iconPixelSize
                    height: root.iconPixelSize
                    sourceSize.width: root.iconPixelSize * 3
                    sourceSize.height: root.iconPixelSize * 3
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    // the art changes while the url stays the same
                    cache: false
                    asynchronous: true
                }
            }

            // The value of the module.
            Label {
                id: valueLabel
                visible: root.labelText !== ""
                text: root.labelText
                pixelSize: root.labelPixelSize
                maxChars: root.labelMaxChars
                color: root.labelColor
            }
        }
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
            // the popup of a module and a tooltip must never share the
            // layer in front of the bar
            if (root.tip !== "" && !root.popupOpen)
                root.showTip()
        }
        onExited: {
            root.hoveredLeave()
            root.hideTip()
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

    // ── the tip of the module ──────────────────────────────────────────────

    // Show the tip of the module in the tooltip of the bar.
    function showTip() {
        if (root.popupOpen)
            return

        // Another module of this bar may own the open popup. The tooltip is
        // one window per bar, so it would draw over that popup.
        const window = root.barWindow
        if (window && window.activePopup !== undefined && window.activePopup !== null)
            return

        const popup = root.tipPopup
        if (!popup)
            return
        popup.target = root
        popup.tipText = root.tip
        popup.show()
    }

    // Hide the tip of the module.
    function hideTip() {
        const popup = root.tipPopup
        if (popup)
            popup.hide()
    }

    // ── the popup of the module ────────────────────────────────────────────

    // Open the popup of the module.
    function openPopup() {
        // the tip and the popup of a module would show up on top of
        // each other
        root.hideTip()
        if (root.popup)
            root.popup.show()
    }

    // Close the popup of the module.
    function closePopup() {
        if (root.popup)
            root.popup.hide()
    }

    // Open the popup of the module, or close it if it is open.
    function togglePopup() {
        if (root.popup && root.popup.visible)
            root.closePopup()
        else
            root.openPopup()
    }

    // Run a command line, the way it is written in the settings. A line
    // with shell syntax is refused: it would run as a pile of literal
    // arguments instead of the pipeline or variable expansion the user
    // wrote, so the error is logged and the command is not started.
    function run(line) {
        const error = Settings.commandError(line)
        if (error !== "") {
            console.warn("[command] " + error + ": " + line)
            return
        }
        const args = Settings.command(line)
        if (args.length === 0)
            return
        Quickshell.execDetached(args)
    }
}
