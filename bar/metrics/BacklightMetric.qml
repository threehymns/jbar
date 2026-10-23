import QtQuick
import "../"

// BacklightMetric — the metric of the screen brightness.
//
// The waybar script splits the brightness into seven steps, the glyphs of
// the metric are spread over the same scale.
Metric {
    id: root

    // The command that reads the value. `-m` prints one machine readable
    // line: device,class,current,percent%,max. It is run directly, so a
    // poll is a single process (not the five-process pipeline the waybar
    // script used).
    readonly property var command: ["brightnessctl", "-m"]

    // How often the command runs, in milliseconds.
    property int interval: 2000

    parse: output => {
        // One line per device; the default device is the one we show.
        const line = output.trim().split("\n")[0]
        if (line === "")
            return null
        const fields = line.split(",")
        // `-m` puts the percentage in the fourth field, a plain number (the
        // old pipeline) is the only field.
        const percent = fields.length >= 4 ? fields[3] : fields[0]
        const value = parseInt(percent)
        return isNaN(value) ? null : value
    }

    // waybar splits the brightness into seven steps
    glyphs: Icons.backlight
    scaleMax: 100

    // The brightness is a percentage between 0 and 100.
    function clamp(value) {
        return Math.max(0, Math.min(100, Math.round(value)))
    }

    // The command that sets the brightness to a value. It is an argument
    // vector, not a shell line, so no shell is spawned for a write.
    function setCommand(value) {
        return ["brightnessctl", "set", root.clamp(value) + "%"]
    }
}
