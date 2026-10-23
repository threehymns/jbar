import QtQuick
import QtTest
import "../bar/"

// The tests of the reconnection policy of the niri event stream.
//
// The policy is a plain object without a process and without a timer, so
// an exit, the retry delays, a recovery and the fallback can be tested
// without niri.
TestCase {
    name: "NiriReconnect"

    NiriReconnect {
        id: policy
    }

    function init() {
        policy.reset()
    }

    function test_the_fallback_polls_until_the_stream_starts() {
        compare(policy.streamAlive, false)
        compare(policy.polling, true)

        policy.streamStarted()
        compare(policy.streamAlive, true)
        compare(policy.polling, false)
    }

    function test_an_exit_starts_the_fallback_and_returns_the_first_delay() {
        compare(policy.streamExited(), 500)
        compare(policy.streamAlive, false)
        compare(policy.polling, true)
        compare(policy.attempts, 1)
        compare(policy.delay, 1000)
    }

    function test_the_retry_delay_doubles_after_every_exit() {
        compare(policy.streamExited(), 500)
        compare(policy.streamExited(), 1000)
        compare(policy.streamExited(), 2000)
        compare(policy.streamExited(), 4000)
        compare(policy.attempts, 4)
    }

    function test_the_retry_delay_is_capped() {
        compare(policy.streamExited(), 500)
        compare(policy.streamExited(), 1000)
        compare(policy.streamExited(), 2000)
        compare(policy.streamExited(), 4000)
        compare(policy.streamExited(), 8000)
        compare(policy.streamExited(), 16000)
        compare(policy.streamExited(), 30000)
        compare(policy.streamExited(), 30000)
        compare(policy.delay, 30000)
    }

    function test_a_started_stream_stops_the_fallback_but_keeps_the_backoff() {
        policy.streamExited()
        policy.streamExited()
        compare(policy.delay, 2000)

        policy.streamStarted()
        compare(policy.polling, false)
        compare(policy.attempts, 2)
        compare(policy.delay, 2000)
    }

    function test_a_healthy_read_resets_the_backoff_and_keeps_the_fallback_off() {
        policy.streamExited()
        policy.streamExited()
        compare(policy.polling, true)

        policy.streamRead()
        compare(policy.streamAlive, true)
        compare(policy.polling, false)
        compare(policy.attempts, 0)
        compare(policy.delay, 500)
    }

    function test_the_fallback_returns_after_a_recovered_stream_exits_again() {
        policy.streamExited()
        policy.streamRead()
        compare(policy.polling, false)

        compare(policy.streamExited(), 500)
        compare(policy.polling, true)
    }
}
