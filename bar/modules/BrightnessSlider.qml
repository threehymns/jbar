import QtQuick
import QtQuick.Controls

// BrightnessSlider — a slider that follows a value while it is not dragged.
//
// A Slider writes its own value while the user drags it, which removes a
// plain `value: metric.value` binding for good. The Binding below is off
// while the slider is pressed and comes back when the drag ends, so the
// slider follows the metric again after the drag.
Slider {
    id: root

    // The value the slider follows while it is not dragged.
    property real followValue: 0

    // Whether the user is dragging. It follows the pressed state of the
    // slider; a test can set it without a mouse.
    property bool dragging: root.pressed

    Binding {
        target: root
        property: "value"
        value: root.followValue
        when: !root.dragging
    }
}
