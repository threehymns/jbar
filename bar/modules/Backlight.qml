import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"

// Backlight — port of the waybar "backlight" module.
//
// Shows the screen brightness and opens a slider when clicked. Scrolling
// changes the brightness in steps of 5%, like the waybar backlight script.
Module {
    id: root

    bg: Theme.backlight
    minChars: 7

    // The bar window, needed to anchor the slider popup.
    property var barRef: null

    property int percent: 0

    readonly property string icon: {
        // waybar splits the brightness into seven steps
        const index = Math.min(Icons.backlight.length - 1, Math.floor(root.percent / 14))
        return Icons.backlight[index]
    }

    onClicked: sliderPopup.visible = !sliderPopup.visible
    onHoveredLeave: sliderPopup.visible = false
    onScrolled: direction => {
        const step = 5
        setBrightness(root.percent + (direction > 0 ? step : -step))
    }

    function setBrightness(value) {
        const clamped = Math.max(0, Math.min(100, Math.round(value)))
        Quickshell.execDetached(["sh", "-c",
            "brightnessctl set " + clamped + "% >/dev/null 2>&1"])
    }

    Text {
        text: root.icon
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    Text {
        text: " " + root.percent + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    // ── brightness slider ───────────────────────────────────────────────────

    PopupWindow {
        id: sliderPopup
        color: "transparent"
        visible: false
        implicitWidth: 300
        implicitHeight: 48

        anchor.window: root.barRef
        anchor.rect.x: {
            if (!root.barRef || !root.barRef.contentItem)
                return 0
            const pos = root.mapToItem(root.barRef.contentItem, 0, 0)
            return Math.round(pos.x + root.width / 2 - width / 2)
        }
        anchor.rect.y: root.barRef ? root.barRef.height : 0

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Theme.mainBg
            border.width: 2
            border.color: Theme.mainBr

            Row {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.icon
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: Theme.mainFg
                }

                Slider {
                    id: slider
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 30
                    from: 0
                    to: 100
                    stepSize: 1
                    value: root.percent
                    onMoved: root.setBrightness(value)

                    handle: Rectangle {
                        x: slider.leftPadding + slider.visualPosition
                            * (slider.availableWidth - width)
                        y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: 6
                        color: Theme.accent
                    }

                    background: Rectangle {
                        x: slider.leftPadding
                        y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        width: slider.availableWidth
                        height: 8
                        radius: 4
                        color: Theme.bg3

                        Rectangle {
                            width: slider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: Theme.accent
                        }
                    }
                }
            }
        }
    }

    // ── polling ─────────────────────────────────────────────────────────────

    Process {
        id: backlightProc
        command: ["sh", "-c", "brightnessctl -m 2>/dev/null | grep -oE '[0-9]+%' | tr -d '%' | head -1"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text.trim())
                if (!isNaN(value))
                    root.percent = value
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: backlightProc.running = true
    }
}
