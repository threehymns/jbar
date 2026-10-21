import QtQuick
import QtTest
import "../bar/"
import "../bar/metrics/"

// The tests of the metric of the network.
//
// The metric is a plain object without any I/O, so the parsing of nmcli can
// be tested without a bar and without a command.
TestCase {
    name: "NetworkMetric"

    NetworkMetric {
        id: metric
    }

    function test_a_connected_wifi_is_wifi() {
        metric.accept("wlan0:wifi:connected")
        compare(metric.connection, "wifi")
        compare(metric.icon, Icons.wifi)
    }

    function test_a_connected_ethernet_is_ethernet() {
        metric.accept("eth0:ethernet:connected")
        compare(metric.connection, "ethernet")
        compare(metric.icon, Icons.ethernet)
    }

    function test_a_disconnected_device_is_no_connection() {
        metric.accept("wlan0:wifi:disconnected")
        compare(metric.connection, "none")
        compare(metric.icon, Icons.networkDown)
    }

    function test_an_unreadable_output_is_no_connection() {
        metric.accept("wlan0:wifi:connected")
        metric.accept("not the output of nmcli")
        compare(metric.connection, "none")
        compare(metric.icon, Icons.networkDown)
    }
}
