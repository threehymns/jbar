import QtQuick
import QtTest
import "../bar/"
import "../bar/metrics/"

// The tests of the metric of the brightness.
//
// The metric is a plain object without any I/O, so the parsing of
// brightnessctl can be tested without a bar and without a command.
TestCase {
    name: "BacklightMetric"

    BacklightMetric {
        id: metric
    }

    function test_the_value_is_the_brightness_in_percent() {
        metric.accept("45\n")
        compare(metric.value, 45)
    }

    function test_the_glyph_follows_the_brightness() {
        // the brightness is split into seven steps
        metric.accept("45\n")
        compare(metric.glyph, Icons.backlight[3])

        metric.accept("100\n")
        compare(metric.glyph, Icons.backlight[6])
    }

    function test_the_command_to_set_the_brightness_is_clamped() {
        compare(metric.setCommand(120)[2],
            "brightnessctl set 100% >/dev/null 2>&1")
        compare(metric.setCommand(-10)[2],
            "brightnessctl set 0% >/dev/null 2>&1")
        compare(metric.setCommand(30.4)[2],
            "brightnessctl set 30% >/dev/null 2>&1")
    }

    function test_garbage_keeps_the_value() {
        metric.accept("45\n")
        metric.accept("not a brightness")
        compare(metric.value, 45)
    }
}
