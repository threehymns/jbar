import QtQuick

// BrightnessWriter — coalesces the values of a drag into one write.
//
// A slider emits a value for every step of a drag, and starting a process
// for every one of them is expensive. The writer keeps only the latest
// value and emits it once the value has settled, so a drag writes once.
QtObject {
    id: root

    // How long a value has to stay unchanged before it is written, in
    // milliseconds.
    property int delay: 150

    // The value that will be written when the delay runs out.
    property real pendingValue: 0

    // The value settled; the module connects this to the write command.
    signal settled(real value)

    // Ask for a value to be written. A newer request replaces the one
    // before it and restarts the delay.
    function request(value) {
        root.pendingValue = value
        timer.restart()
    }

    // A plain object has no default property for children, so the timer is
    // held by a property.
    property Timer timer: Timer {
        interval: root.delay
        repeat: false
        onTriggered: root.settled(root.pendingValue)
    }
}
