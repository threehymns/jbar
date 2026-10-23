import QtQuick

// BatteryState — the charge states and the notification state machine of the
// battery.
//
// The module hands the state of the UPower device in through update(), so the
// warnings and the tooltip label can be tested without UPower and without a
// bar.
//
// The low and the critical warning re-arm when the battery recovers above
// their threshold, and the full notification re-arms when the battery leaves
// the full state, so every discharge and every charge cycle warns again.
QtObject {
    id: root

    // ── the state of the battery ────────────────────────────────────────────

    // The charge level, from 0 to 100.
    property int percentage: 0

    // The UPower charge states the module distinguishes.
    property bool charging: false
    property bool full: false
    property bool discharging: false

    // The thresholds of the waybar config.
    property int warningThreshold: 20
    property int criticalThreshold: 10

    // The battery is full when UPower says so, or while it is still charging
    // at 100 % (some devices keep reporting Charging until the charger is
    // unplugged).
    readonly property bool isFull: root.full
        || (root.charging && root.percentage >= 100)

    // The label of the tooltip. Full wins over the charge state, so a full
    // battery is never called "Discharging".
    readonly property string status: root.isFull ? "Full"
        : (root.charging ? "Charging" : "Discharging")

    // ── the notifications ───────────────────────────────────────────────────

    // A notification is due when the battery crosses a threshold.
    signal low()
    signal critical()
    signal fullCharge()

    // Whether the notification of the current threshold has already fired.
    // The flags are reset when the battery recovers above the threshold.
    property bool lowNotified: false
    property bool criticalNotified: false
    property bool fullNotified: false

    // Take the whole state of the device at once. Updating the inputs one by
    // one would evaluate the thresholds while the state is half updated.
    function update(percentage, charging, full, discharging) {
        root.percentage = percentage
        root.charging = charging
        root.full = full
        root.discharging = discharging
        evaluate()
    }

    // Check the current state and emit the notifications that are due.
    function evaluate() {
        // Re-arm a warning once the battery is above its threshold again.
        if (root.percentage > root.warningThreshold)
            root.lowNotified = false
        if (root.percentage > root.criticalThreshold)
            root.criticalNotified = false

        // The bound isFull property may still be the value of the update
        // before this one inside a change handler, so test the inputs.
        const fullNow = root.full
            || (root.charging && root.percentage >= 100)

        // The full notification belongs to a charge cycle: fire it once when
        // the battery becomes full and re-arm it when the battery leaves the
        // full state.
        if (!fullNow) {
            root.fullNotified = false
        } else if (!root.fullNotified) {
            root.fullNotified = true
            root.fullCharge()
        }

        // A battery that is charging or full is not discharging, so the
        // low and critical warnings only belong to a discharge.
        if (!root.discharging || fullNow)
            return

        if (root.percentage <= root.criticalThreshold) {
            if (!root.criticalNotified) {
                root.criticalNotified = true
                // the critical warning implies the low one, do not repeat it
                root.lowNotified = true
                root.critical()
            }
        } else if (root.percentage <= root.warningThreshold
            && !root.lowNotified) {
            root.lowNotified = true
            root.low()
        }
    }
}
