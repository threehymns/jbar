import QtQuick
import QtQuick.Controls
import Quickshell
import "../"
import "../adapters/"
import "../metrics/"

// Backlight — port of the waybar "backlight" module.
//
// The metric of the brightness knows the command, the parsing and the scale
// of the glyphs, the module only draws it and scrolls the brightness.
Module {
    id: root

    bg: Theme.backlight
    minChars: 7

    readonly property BacklightMetric metric: BacklightMetric {}

    // The poll that fills the metric.
    readonly property Poller poller: Poller { metric: root.metric }

    onClicked: root.togglePopup()
    onScrolled: direction => {
        const step = 5
        root.setBrightness(root.metric.value + (direction > 0 ? step : -step))
    }

    function setBrightness(value) {
        Quickshell.execDetached(root.metric.setCommand(value))
    }

    iconText: root.metric.glyph
    labelText: root.metric.value + "%"

    // ── brightness slider ───────────────────────────────────────────────────

    popup: Popup {
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
                value: root.metric.value
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
