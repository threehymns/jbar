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

    function test_the_value_is_the_percent_field_of_brightnessctl() {
        // device,class,current,percent%,max
        metric.accept("intel_backlight,backlight,480,48%,1000\n")
        compare(metric.value, 48)
    }

    function test_the_glyph_follows_the_brightness() {
        // the brightness is split into seven steps
        metric.accept("intel_backlight,backlight,450,45%,1000\n")
        compare(metric.glyph, Icons.backlight[3])

        metric.accept("intel_backlight,backlight,1000,100%,1000\n")
        compare(metric.glyph, Icons.backlight[6])
    }

    function test_the_poll_does_not_use_a_shell() {
        compare(metric.command, ["brightnessctl", "-m"])
    }

    function test_the_command_to_set_the_brightness_is_an_argument_vector() {
        compare(metric.setCommand(30), ["brightnessctl", "set", "30%"])
    }

    function test_the_command_to_set_the_brightness_is_clamped() {
        compare(metric.setCommand(120), ["brightnessctl", "set", "100%"])
        compare(metric.setCommand(-10), ["brightnessctl", "set", "0%"])
        compare(metric.setCommand(30.4), ["brightnessctl", "set", "30%"])
    }

    function test_garbage_keeps_the_value() {
        metric.accept("intel_backlight,backlight,450,45%,1000\n")
        metric.accept("not a brightness")
        compare(metric.value, 45)
    }

    function test_an_empty_output_keeps_the_value() {
        metric.accept("intel_backlight,backlight,450,45%,1000\n")
        metric.accept("")
        compare(metric.value, 45)
    }
}
