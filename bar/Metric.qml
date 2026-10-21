import QtQuick

// Metric — a number of the system, with its states and its glyphs.
//
// The metric turns a sample into a value, knows the warning and the
// critical threshold of the value, and the glyph that belongs to it.
//
// It is a plain object without any I/O, so the arithmetic of a metric can
// be tested without a bar and without a command.
//
// The metrics of the systems live in bar/metrics: they add the command and
// the parsing of their system to this.
//
//     Metric {
//         parse: output => parseInt(output)
//         measure: (sample, previous) => sample - previous
//         warningThreshold: 75
//         glyphs: ["low", "high"]
//     }
QtObject {
    id: root

    // ── the value ───────────────────────────────────────────────────────────

    // The value of the metric.
    property var value: 0

    // Turn the output of a command into a sample. Return null to keep the
    // sample of the last run.
    property var parse: output => null

    // Turn the sample and the one before it into the value. Return null to
    // keep the value of the last run.
    property var measure: (sample, previous) => sample

    // The sample of the last run and the one before it.
    property var sample: null
    property var previousSample: null

    // ── the states ──────────────────────────────────────────────────────────

    // The thresholds of the value, the "states" of the waybar config.
    property real warningThreshold: Infinity
    property real criticalThreshold: Infinity

    // Whether a value above the thresholds is the bad one. The cpu and the
    // memory are bad when they are high, the battery is bad when it is
    // empty.
    property bool highIsBad: true

    readonly property bool warning: typeof root.value === "number"
        && (root.highIsBad
            ? root.value >= root.warningThreshold
            : root.value <= root.warningThreshold)
    readonly property bool critical: typeof root.value === "number"
        && (root.highIsBad
            ? root.value >= root.criticalThreshold
            : root.value <= root.criticalThreshold)

    // ── the glyphs ──────────────────────────────────────────────────────────

    // The glyphs of the metric, from the lowest to the highest value.
    property var glyphs: []

    // The value the glyphs are spread over.
    property real scaleMax: 100

    readonly property string glyph: {
        if (root.glyphs.length === 0)
            return ""
        const step = Math.max(1, Math.floor(root.scaleMax / root.glyphs.length))
        const index = Math.max(0, Math.min(root.glyphs.length - 1, Math.floor(root.value / step)))
        return root.glyphs[index]
    }

    // Take the output of a command and turn it into the value.
    function accept(output) {
        const parsed = root.parse(output)
        if (parsed === null || parsed === undefined)
            return
        root.previousSample = root.sample
        root.sample = parsed
        const measured = root.measure(root.sample, root.previousSample)
        if (measured === null || measured === undefined)
            return
        root.value = measured
    }
}
