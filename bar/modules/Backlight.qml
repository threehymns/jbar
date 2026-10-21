import QtQuick
import QtQuick.Controls
import Quickshell
import "../"
import "../adapters/"

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

    readonly property Metric metric: Metric {
        parse: output => {
            const value = parseInt(output.trim())
            return isNaN(value) ? null : value
        }
        // waybar splits the brightness into seven steps
        glyphs: Icons.backlight
        scaleMax: 100
    }

    readonly property Poller poller: Poller {
        metric: root.metric
        command: ["sh", "-c",
            "brightnessctl -m 2>/dev/null | grep -oE '[0-9]+%' | tr -d '%' | head -1"]
        interval: 2000
    }

    readonly property int percent: metric.value

    onClicked: sliderPopup.visible = !sliderPopup.visible
    onScrolled: direction => {
        const step = 5
        setBrightness(root.percent + (direction > 0 ? step : -step))
    }

    function setBrightness(value) {
        const clamped = Math.max(0, Math.min(100, Math.round(value)))
        Quickshell.execDetached(["sh", "-c",
            "brightnessctl set " + clamped + "% >/dev/null 2>&1"])
    }

    iconText: metric.glyph
    labelText: root.percent + "%"

    // ── brightness slider ───────────────────────────────────────────────────

    Popup {
        id: sliderPopup
        barWindow: root.barRef
        target: root
        radius: 16
        implicitWidth: 300
        implicitHeight: 48

        Row {
                anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 10

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: root.metric.glyph
                glyph: true
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
