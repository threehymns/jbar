import QtQuick
import QtTest
import "../bar/metrics/"

// The tests of the metric of the processor.
//
// The metric is a plain object without any I/O, so the arithmetic of the
// usage can be tested without a bar and without a command.
TestCase {
    name: "CpuMetric"

    CpuMetric {
        id: metric
    }

    // A metric that no other test touches.
    CpuMetric {
        id: fresh
    }

    function test_the_first_sample_says_nothing() {
        fresh.accept("cpu  100 0 0 800 0 0 0 0 0 0")
        compare(fresh.value, 0)
    }

    function test_the_usage_is_the_share_of_the_counters_that_were_not_idle() {
        metric.accept("cpu  100 0 0 800 0 0 0 0 0 0")
        // 1000 counters in total, 800 of them idle
        metric.accept("cpu  300 0 0 1600 0 0 0 0 0 0")
        compare(metric.value, 20)
    }

    function test_a_high_usage_is_warning() {
        metric.accept("cpu  100 0 0 800 0 0 0 0 0 0")
        // 1000 counters in total, 200 of them idle
        metric.accept("cpu  900 0 0 1000 0 0 0 0 0 0")
        compare(metric.value, 80)
        compare(metric.warning, true)
        compare(metric.critical, false)
    }

    function test_a_very_high_usage_is_critical() {
        metric.accept("cpu  100 0 0 800 0 0 0 0 0 0")
        // 1000 counters in total, 50 of them idle
        metric.accept("cpu  1050 0 0 850 0 0 0 0 0 0")
        compare(metric.value, 95)
        compare(metric.warning, true)
        compare(metric.critical, true)
    }

    function test_garbage_keeps_the_value() {
        metric.accept("cpu  100 0 0 800 0 0 0 0 0 0")
        metric.accept("cpu  300 0 0 1600 0 0 0 0 0 0")
        metric.accept("not a line of /proc/stat")
        compare(metric.value, 20)
    }
}
