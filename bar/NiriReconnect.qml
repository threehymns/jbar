import QtQuick

// NiriReconnect — the reconnection policy of the niri event stream.
//
// `niri msg event-stream` can exit at any time (niri restarts, the socket
// closes). The policy decides how long to wait before the stream is
// started again and whether the fallback poller has to run. It is a plain
// object without a process or a timer, so the policy can be tested without
// niri and the adapter only wires it to one Process and one Timer.
QtObject {
    id: root

    // The first delay after the stream exits, in milliseconds.
    property int baseDelay: 500

    // The longest delay between two attempts. A broken niri is retried
    // every 30 seconds instead of spinning.
    property int maxDelay: 30000

    // How many times the stream has exited since it last delivered an
    // event.
    property int attempts: 0

    // The delay of the next restart, in milliseconds.
    property int delay: root.baseDelay

    // Whether the event stream is up.
    property bool streamAlive: false

    // The fallback poller runs only while the stream is unavailable.
    readonly property bool polling: !root.streamAlive

    // The stream process started. It counts as up, so the fallback stops,
    // but the backoff is not reset until it actually delivers an event: a
    // process that dies immediately is still a failure.
    function streamStarted() {
        root.streamAlive = true
    }

    // The stream delivered an event. This is a healthy connection, so the
    // next failure starts at the base delay again.
    function streamRead() {
        root.streamAlive = true
        root.attempts = 0
        root.delay = root.baseDelay
    }

    // The stream exited. Return the delay before the next restart and
    // double the delay for the attempt after it, up to the cap.
    function streamExited() {
        root.streamAlive = false
        root.attempts += 1
        const wait = root.delay
        root.delay = Math.min(root.maxDelay, root.delay * 2)
        return wait
    }

    // Put the policy back into its initial state (the adapter starts with
    // no stream, so the fallback polls until it is up).
    function reset() {
        root.streamAlive = false
        root.attempts = 0
        root.delay = root.baseDelay
    }
}
