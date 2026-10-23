import QtQuick
import QtTest
import "../bar/metrics/"

// The tests of the debounce of the brightness writes.
//
// The writer is a plain object with a timer, so the coalescing of a drag
// can be tested without a bar and without brightnessctl.
TestCase {
    name: "BrightnessWriter"

    BrightnessWriter {
        id: writer
        delay: 250
    }

    SignalSpy {
        id: settled
        target: writer
        signalName: "settled"
    }

    function init() {
        writer.timer.stop()
        writer.delay = 250
        writer.pendingValue = 0
        settled.clear()
    }

    function test_a_burst_is_written_once_with_the_last_value() {
        writer.request(10)
        writer.request(20)
        writer.request(30)

        // nothing is written while the value is still changing
        compare(settled.count, 0)

        tryCompare(settled, "count", 1, 1000)
        compare(settled.signalArguments[0][0], 30)
    }

    function test_every_request_restarts_the_delay() {
        writer.request(10)
        wait(100)
        compare(settled.count, 0)

        writer.request(20)
        wait(100)
        compare(settled.count, 0)

        tryCompare(settled, "count", 1, 1000)
        compare(settled.signalArguments[0][0], 20)
    }

    function test_a_settled_value_is_written_once() {
        writer.request(42)
        tryCompare(settled, "count", 1, 1000)

        // the timer does not repeat
        wait(350)
        compare(settled.count, 1)
    }

    function test_a_new_value_after_a_write_is_written_again() {
        writer.request(42)
        tryCompare(settled, "count", 1, 1000)

        writer.request(43)
        tryCompare(settled, "count", 2, 1000)
        compare(settled.signalArguments[1][0], 43)
    }
}
