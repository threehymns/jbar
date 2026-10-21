import QtQuick
import QtTest
import "../bar/metrics/"

// The tests of the metric of the memory.
//
// The metric is a plain object without any I/O, so the arithmetic of the
// usage can be tested without a bar and without a command.
TestCase {
    name: "MemoryMetric"

    MemoryMetric {
        id: metric
    }

    function test_the_usage_is_the_share_of_the_used_memory() {
        // 16 GiB of memory, 8 GiB of it used
        metric.accept("16777216 8388608")
        compare(metric.value, 50)
    }

    function test_a_high_usage_is_warning() {
        // 16 GiB of memory, 13 GiB of it used
        metric.accept("16777216 4194304")
        compare(metric.value, 75)
        compare(metric.warning, true)
        compare(metric.critical, false)
    }

    function test_a_very_high_usage_is_critical() {
        // 16 GiB of memory, 15 GiB of it used
        metric.accept("16777216 1048576")
        compare(metric.value, 94)
        compare(metric.warning, true)
        compare(metric.critical, true)
    }

    function test_the_tooltip_shows_the_memory_in_gib() {
        metric.accept("16777216 8388608")
        compare(metric.tip, "Memory Used: 8.0/16.0 GiB")
    }

    function test_garbage_keeps_the_value() {
        metric.accept("16777216 8388608")
        metric.accept("not the output of the command")
        compare(metric.value, 50)
    }
}
