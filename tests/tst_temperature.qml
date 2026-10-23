import QtQuick
import QtTest
import "../bar/"
import "../bar/metrics/"

// The tests of the metric of the temperature.
//
// The metric is a plain object without any I/O, so the conversion of the
// thermal zone into degrees and the switch between the units can be tested
// without a bar and without a command.
TestCase {
    name: "TemperatureMetric"

    TemperatureMetric {
        id: metric
    }

    // Every test starts in the default unit and with a fresh sample.
    function init() {
        metric.unit = "F"
        metric.criticalCelsius = 90
        metric.celsius = 0
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

    function test_the_parse_stores_celsius_in_every_unit() {
        // the sample does not depend on the unit the value is shown in
        metric.unit = "C"
        compare(metric.parse("50000"), 50)
        metric.unit = "F"
        compare(metric.parse("50000"), 50)
    }

    function test_fahrenheit_converts_to_celsius() {
        compare(metric.toCelsius(194, "F"), 90)
        compare(metric.toCelsius(32, "F"), 0)
        compare(metric.toCelsius(50, "C"), 50)
    }

    function test_celsius_converts_to_fahrenheit() {
        compare(metric.toDisplay(90, "F"), 194)
        compare(metric.toDisplay(0, "F"), 32)
        compare(metric.toDisplay(90, "C"), 90)
    }

    function test_a_unit_switch_converts_the_visible_value_at_once() {
        metric.accept("50000")
        compare(metric.value, 122)

        metric.unit = "C"
        // the value, the label and the tooltip all move to Celsius in the
        // same update, so the old number is never shown with the new label
        compare(metric.value, 50)
        compare(metric.unitLabel, "°C")
        compare(metric.tip, "Temperature in Celsius: 50°C")

        metric.unit = "F"
        compare(metric.value, 122)
        compare(metric.unitLabel, "°F")
        compare(metric.tip, "Temperature in Fahrenheit: 122°F")
    }

    function test_the_critical_threshold_follows_the_unit() {
        metric.accept("90000")

        compare(metric.unit, "F")
        compare(metric.criticalThreshold, 194)
        compare(metric.critical, true)

        metric.unit = "C"
        compare(metric.criticalThreshold, 90)
        compare(metric.value, 90)
        compare(metric.critical, true)
    }

    function test_the_next_poll_after_a_switch_does_not_drift() {
        metric.accept("50000")
        metric.unit = "C"
        compare(metric.value, 50)

        // a new sample of the same temperature reports the same value
        metric.accept("50000")
        compare(metric.value, 50)

        metric.unit = "F"
        compare(metric.value, 122)
        metric.accept("50000")
        compare(metric.value, 122)
    }
}
