import QtQuick
import QtTest
import "../bar/"
import "../bar/metrics/"

// The tests of the metric of the temperature.
//
// The metric is a plain object without any I/O, so the conversion of the
// thermal zone into degrees can be tested without a bar and without a
// command.
TestCase {
    name: "TemperatureMetric"

    TemperatureMetric {
        id: metric
    }

    function test_the_value_is_the_temperature_in_fahrenheit() {
        // the thermal zone reports millidegrees of Celsius
        metric.accept("50000")
        compare(metric.value, 122)
    }

    function test_the_critical_threshold_is_the_waybar_one() {
        // 90°C are 194°F, the critical threshold of the waybar config
        metric.accept("90000")
        compare(metric.value, 194)
        compare(metric.critical, true)
    }

    function test_a_cold_temperature_is_not_critical() {
        metric.accept("20000")
        compare(metric.value, 68)
        compare(metric.warning, false)
        compare(metric.critical, false)
    }

    function test_the_glyph_follows_the_temperature() {
        // the scale of the glyphs covers the critical threshold
        metric.accept("50000")
        compare(metric.glyph, Icons.temperature[1])
    }

    function test_the_tooltip_shows_the_temperature_in_fahrenheit() {
        metric.accept("50000")
        compare(metric.tip, "Temperature in Fahrenheit: 122°F")
    }

    function test_garbage_keeps_the_value() {
        metric.accept("50000")
        metric.accept("not a temperature")
        compare(metric.value, 122)
    }
}
