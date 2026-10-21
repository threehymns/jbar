import QtQuick
import QtTest
import "../bar"

// The tests of the headless modules.
//
// A metric is a plain object without any I/O, so it can be tested without a
// bar and without a command: the arithmetic of a metric and the states of a
// value are the interface, and this is where they are checked.
TestCase {
    name: "Metric"

    // A metric that reads a number.
    Metric {
        id: polled
        parse: output => {
            const value = parseInt(output.trim())
            return isNaN(value) ? null : value
        }
    }

    // A metric whose value is measured from a sample and the one before it.
    Metric {
        id: measured
        parse: output => {
            const parts = output.trim().split(/\s+/)
            return { a: parseInt(parts[0]), b: parseInt(parts[1]) }
        }
        measure: (sample, previous) => previous ? sample.b - previous.b : null
    }

    // A metric whose value is given from the outside.
    Metric {
        id: plain
        value: 50
        warningThreshold: 75
        criticalThreshold: 90
    }

    // A metric that is bad when it is low.
    Metric {
        id: empty
        value: 50
        warningThreshold: 20
        criticalThreshold: 10
        highIsBad: false
    }

    // A metric with a scale of glyphs.
    Metric {
        id: scaled
        value: 42
        glyphs: ["a", "b", "c"]
        scaleMax: 100
    }

    function test_reads_the_value() {
        polled.accept("42")
        compare(polled.value, 42)
    }

    function test_keeps_the_value_when_the_output_is_garbage() {
        polled.accept("42")
        polled.accept("not a number")
        compare(polled.value, 42)
    }

    function test_measures_the_value_from_two_samples() {
        // without a sample before it there is nothing to measure
        measured.accept("1 2")
        compare(measured.value, 0)

        measured.accept("3 5")
        compare(measured.value, 3)
    }

    function test_a_high_value_is_warning() {
        compare(plain.warning, false)
        compare(plain.critical, false)

        plain.value = 80
        compare(plain.warning, true)
        compare(plain.critical, false)

        plain.value = 95
        compare(plain.critical, true)
    }

    function test_a_low_value_is_warning() {
        compare(empty.warning, false)
        compare(empty.critical, false)

        empty.value = 15
        compare(empty.warning, true)
        compare(empty.critical, false)

        empty.value = 5
        compare(empty.critical, true)
    }

    function test_the_glyph_follows_the_value() {
        // the scale of three glyphs covers 0..100 in steps of 33
        compare(scaled.glyph, "b")

        scaled.value = 0
        compare(scaled.glyph, "a")

        scaled.value = 99
        compare(scaled.glyph, "c")
    }

    function test_a_metric_without_glyphs_has_none() {
        compare(plain.glyph, "")
    }
}
