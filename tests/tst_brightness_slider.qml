import QtQuick
import QtTest
import "../bar/modules/"

// The tests of the brightness slider.
//
// A Slider drops a binding on its value as soon as it is dragged, so the
// slider restores the binding explicitly while it is not pressed. The
// tests cover both the binding and a real drag.
TestCase {
    name: "BrightnessSlider"
    when: windowShown
    visible: true
    width: 400
    height: 80

    BrightnessSlider {
        id: slider
        anchors.fill: parent
        from: 0
        to: 100
        stepSize: 1
    }

    function init() {
        // Put the value and the binding back into a known state. Setting
        // `dragging` directly drops its binding to `pressed`, so the mouse
        // test gets it back afterwards.
        slider.dragging = true
        slider.value = 0
        slider.followValue = 0
        slider.dragging = false
        slider.dragging = Qt.binding(() => slider.pressed)
    }

    function test_the_value_follows_the_metric_while_not_dragged() {
        slider.followValue = 40
        compare(slider.value, 40)

        slider.followValue = 55
        compare(slider.value, 55)
    }

    function test_a_drag_keeps_the_value_it_was_given() {
        slider.followValue = 40
        slider.dragging = true
        slider.value = 80
        compare(slider.value, 80)

        // a metric that changes during the drag does not fight the drag
        slider.followValue = 50
        compare(slider.value, 80)
    }

    function test_the_value_follows_the_metric_again_after_the_drag() {
        slider.followValue = 40
        slider.dragging = true
        slider.value = 80
        slider.followValue = 50
        slider.dragging = false

        compare(slider.value, 50)
    }

    function test_a_mouse_drag_follows_the_pointer_and_then_the_metric() {
        compare(slider.value, 0)

        mousePress(slider, slider.width * 0.8, slider.height / 2)
        compare(slider.dragging, true)

        mouseMove(slider, slider.width * 0.9, slider.height / 2)
        verify(slider.value > 80)

        mouseRelease(slider, slider.width * 0.9, slider.height / 2)
        compare(slider.dragging, false)
        compare(slider.value, 0)

        slider.followValue = 45
        compare(slider.value, 45)
    }
}
