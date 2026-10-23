import QtQuick
import QtTest
import "../bar"

// The tests of the popup close delay.
//
// The state machine is a plain object without a window, so the show, hide,
// re-show, hover and leave transitions can be tested headlessly. The actual
// stacking of the popup window and the tooltip window is not visible to
// qmltestrunner's offscreen platform: reproduce that layer by running the
// bar, opening a module popup, moving the pointer out and back over the
// module (the popup stays and no tooltip is drawn over it), then hovering
// another module while the popup is open (the tooltip stays away until the
// popup has closed). Hover a module until its tooltip is up, then click it:
// the tooltip disappears when the popup opens.
TestCase {
    name: "PopupState"

    PopupState {
        id: state
        closeDelay: 20
    }

    PopupState {
        id: other
        closeDelay: 20
    }

    SignalSpy {
        id: closeSpy
        target: state
        signalName: "closeRequested"
    }

    function init() {
        state.hide()
        other.hide()
        state.closeDelay = 20
        other.closeDelay = 20
        state.pointerInside = false
        state.pointerOverTarget = false
        other.pointerInside = false
        other.pointerOverTarget = false
        closeSpy.clear()
    }

    function test_show_opens_the_popup() {
        state.show()
        compare(state.open, true)
        compare(state.closePending, false)
        compare(closeSpy.count, 0)
    }

    function test_the_popup_closes_after_the_delay() {
        state.show()
        state.closeWhenIdle()
        verify(state.closePending)

        wait(60)

        compare(state.open, false)
        compare(state.closePending, false)
        compare(closeSpy.count, 1)
    }

    function test_reopening_within_the_delay_keeps_the_popup_open() {
        state.show()
        state.closeWhenIdle()
        verify(state.closePending)

        // reopen before the 20 ms delay has expired
        wait(5)
        state.show()
        compare(state.closePending, false)

        wait(60)

        compare(state.open, true)
        compare(closeSpy.count, 0)
    }

    function test_hiding_cancels_a_pending_close() {
        state.show()
        state.closeWhenIdle()
        verify(state.closePending)

        state.hide()
        compare(state.open, false)
        compare(state.closePending, false)

        // the timer of the old open must not close the next open
        state.show()
        wait(60)
        compare(state.open, true)
    }

    function test_hovering_the_module_cancels_a_pending_close() {
        state.show()
        state.closeWhenIdle()
        verify(state.closePending)

        state.pointerOverTarget = true
        compare(state.closePending, false)

        wait(60)
        compare(state.open, true)
    }

    function test_leaving_the_module_starts_the_close() {
        state.show()
        state.pointerOverTarget = true
        state.pointerOverTarget = false

        verify(state.closePending)
        wait(60)
        compare(state.open, false)
    }

    function test_the_pointer_inside_the_popup_keeps_it_open() {
        state.show()
        state.pointerInside = true
        state.closeWhenIdle()
        compare(state.closePending, false)

        wait(60)
        compare(state.open, true)

        state.pointerInside = false
        verify(state.closePending)
        wait(60)
        compare(state.open, false)
    }

    function test_clicking_the_module_keeps_the_popup_open() {
        // the pointer is over the module when the popup opens by a click,
        // so the close delay never starts
        state.pointerOverTarget = true
        state.show()
        state.closeWhenIdle()
        compare(state.closePending, false)

        wait(60)
        compare(state.open, true)
    }

    function test_a_close_of_one_popup_does_not_hide_another() {
        state.show()
        state.closeWhenIdle()
        other.show()

        wait(60)

        compare(state.open, false)
        compare(other.open, true)
    }
}
