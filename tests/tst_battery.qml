import QtQuick
import QtTest
import "../bar/metrics/"

// The tests of the battery.
//
// The state machine is a plain object: the module hands the UPower values in,
// so the warnings and the tooltip state can be tested without UPower and
// without a bar.
TestCase {
    name: "Battery"

    BatteryState {
        id: state
    }

    SignalSpy {
        id: lowSpy
        target: state
        signalName: "low"
    }

    SignalSpy {
        id: criticalSpy
        target: state
        signalName: "critical"
    }

    SignalSpy {
        id: fullSpy
        target: state
        signalName: "fullCharge"
    }

    function init() {
        lowSpy.clear()
        criticalSpy.clear()
        fullSpy.clear()
        // a healthy discharging battery arms every warning again
        setState(80, false, false, true)
    }

    // Change the whole state at once, the way the module does when a device
    // update arrives.
    function setState(percentage, charging, full, discharging) {
        state.update(percentage, charging, full, discharging)
    }

    // ── the state machine ───────────────────────────────────────────────────

    function test_a_discharge_warns_low_and_critical_once() {
        setState(20, false, false, true)
        compare(lowSpy.count, 1)
        compare(criticalSpy.count, 0)

        // the warning does not repeat while the battery stays below the
        // threshold
        setState(19, false, false, true)
        compare(lowSpy.count, 1)

        setState(10, false, false, true)
        compare(criticalSpy.count, 1)

        // a critical battery does not repeat its warning either
        setState(9, false, false, true)
        compare(criticalSpy.count, 1)
    }

    function test_a_low_warning_rearms_after_the_battery_recovers() {
        setState(18, false, false, true)
        compare(lowSpy.count, 1)

        // above the warning threshold the warning is armed again
        setState(25, false, false, true)
        setState(20, false, false, true)
        compare(lowSpy.count, 2)
    }

    function test_a_critical_warning_rearms_after_the_battery_recovers() {
        setState(9, false, false, true)
        compare(criticalSpy.count, 1)

        // above the critical threshold but still below the warning threshold
        // only the critical warning is armed again
        setState(15, false, false, true)
        setState(10, false, false, true)
        compare(criticalSpy.count, 2)
        // the critical warning stands in for the low one
        compare(lowSpy.count, 0)

        // above both thresholds both warnings are armed again
        setState(25, false, false, true)
        setState(20, false, false, true)
        compare(lowSpy.count, 1)
        setState(10, false, false, true)
        compare(criticalSpy.count, 3)
    }

    function test_charging_does_not_warn() {
        setState(5, true, false, false)
        compare(lowSpy.count, 0)
        compare(criticalSpy.count, 0)
    }

    function test_a_full_battery_notifies_once_per_charge_cycle() {
        setState(99, true, false, false)
        setState(99, true, true, false)
        compare(fullSpy.count, 1)

        // staying full does not notify again
        setState(99, true, true, false)
        compare(fullSpy.count, 1)

        // leaving the full state arms the notification for the next cycle
        setState(99, true, false, false)
        setState(99, true, true, false)
        compare(fullSpy.count, 2)
    }

    function test_charging_at_100_is_full() {
        setState(99, true, false, false)
        setState(100, true, false, false)
        compare(fullSpy.count, 1)
        compare(state.status, "Full")

        setState(99, true, false, false)
        setState(100, true, false, false)
        compare(fullSpy.count, 2)
    }

    function test_the_status_follows_the_charge_state() {
        setState(50, true, false, false)
        compare(state.status, "Charging")

        setState(50, false, false, true)
        compare(state.status, "Discharging")

        // full wins over the other flags, a full battery is never
        // "Discharging"
        setState(100, false, true, true)
        compare(state.status, "Full")
    }

}
