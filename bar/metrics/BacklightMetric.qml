import QtQuick
import "../"

// BacklightMetric — the metric of the screen brightness.
//
// The waybar script splits the brightness into seven steps, the glyphs of
// the metric are spread over the same scale.
Metric {
    // The command that reads the value.
    readonly property var command: ["sh", "-c",
        "brightnessctl -m 2>/dev/null | grep -oE '[0-9]+%' | tr -d '%' | head -1"]

    // How often the command runs, in milliseconds.
    readonly property int interval: 2000

    parse: output => {
        const value = parseInt(output.trim())
        return isNaN(value) ? null : value
    }

    // waybar splits the brightness into seven steps
    glyphs: Icons.backlight
    scaleMax: 100

    // The command that sets the brightness to a value. The brightness of
    // the screen is between 0 and 100, the value is clamped to that.
    function setCommand(value) {
        const clamped = Math.max(0, Math.min(100, Math.round(value)))
        return ["sh", "-c", "brightnessctl set " + clamped + "% >/dev/null 2>&1"]
    }
}
