import QtQuick

// PopupState — when a popup is open and when its pending close fires.
//
// Popup.qml draws and animates the window, but the close delay is a state
// machine of its own. Opening cancels a close that is already pending, so a
// popup reopened within the delay stays open. Hiding cancels the pending
// close as well, so a timer from the old open cannot hide the popup after
// it is shown again. The pointer over the module or over the popup keeps it
// open. None of this needs a window, so it is a plain object and can be
// tested headlessly.
QtObject {
    id: root

    // The popup should be open. It becomes false when the close delay
    // expires or when hide() is called.
    property bool open: false

    // The pointer is over the popup.
    property bool pointerInside: false

    // The pointer is over the module the popup belongs to.
    property bool pointerOverTarget: false

    // How long the pointer may be over neither the module nor the popup
    // before the popup closes, in milliseconds.
    property int closeDelay: 150

    // Whether a close is waiting for the delay to expire.
    readonly property bool closePending: closeTimer.running

    // The delay expired: the owner closes the popup.
    signal closeRequested()

    // Keep the popup open. A close that is still pending is cancelled, so
    // reopening within the delay does not let the old timer hide it.
    function show() {
        closeTimer.stop()
        root.open = true
    }

    // Close the popup now. The pending close is cancelled too, so a timer
    // from the old open cannot hide the popup after it is shown again.
    function hide() {
        closeTimer.stop()
        root.open = false
    }

    // Start the close delay when the pointer is over neither the module nor
    // the popup. A pointer that comes back cancels a close that is pending.
    function closeWhenIdle() {
        if (!root.open || root.pointerInside || root.pointerOverTarget) {
            closeTimer.stop()
            return
        }
        closeTimer.restart()
    }

    onPointerInsideChanged: root.closeWhenIdle()
    onPointerOverTargetChanged: root.closeWhenIdle()

    onOpenChanged: {
        if (!root.open)
            closeTimer.stop()
    }

    property Timer closeTimer: Timer {
        id: closeTimer
        interval: root.closeDelay
        onTriggered: {
            root.open = false
            root.closeRequested()
        }
    }
}
