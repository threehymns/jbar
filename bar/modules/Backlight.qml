import QtQuick
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

    readonly property BacklightMetric metric: BacklightMetric {
        interval: Settings.backlightInterval * 1000
    }

    // The poll that fills the metric.
    readonly property Poller poller: Poller { metric: root.metric }

    // A drag emits a value per step; the writer turns the burst into one
    // write when the value settles.
    readonly property BrightnessWriter brightnessWriter: BrightnessWriter {
        delay: 150
        onSettled: value => Quickshell.execDetached(root.metric.setCommand(value))
    }

    onClicked: root.togglePopup()
    onScrolled: direction => {
        const step = 5
        root.setBrightness(root.metric.value + (direction > 0 ? step : -step))
    }

    // Show the value at once and write it when the user stops moving. The
    // next poll confirms the value the system reports.
    function setBrightness(value) {
        const clamped = root.metric.clamp(value)
        root.metric.value = clamped
        root.brightnessWriter.request(clamped)
    }

    iconText: root.metric.glyph
    labelText: root.metric.value + "%"

    // ── brightness slider ───────────────────────────────────────────────────

    popup: Popup {
        radius: 16
        contentWidth: 300
        contentHeight: 48

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

            BrightnessSlider {
                id: slider
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 30
                from: 0
                to: 100
                stepSize: 1
                followValue: root.metric.value
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
