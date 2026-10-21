import QtQuick
import QtTest
import "../bar/metrics/"

// The tests of the metric of the pending updates.
//
// The metric is a plain object without any I/O, so the count of the
// updates can be tested without a bar and without a command.
TestCase {
    name: "UpdatesMetric"

    UpdatesMetric {
        id: metric
    }

    function test_the_value_is_the_count_of_the_updates() {
        metric.accept("3\n")
        compare(metric.value, 3)
    }

    function test_no_updates_is_zero() {
        metric.accept("0\n")
        compare(metric.value, 0)
    }

    function test_garbage_keeps_the_value() {
        metric.accept("3\n")
        metric.accept("not a count")
        compare(metric.value, 3)
    }
}
