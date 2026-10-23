pragma Singleton
import QtQuick

// Settings — the values of the bar that the user can change.
//
// Everything that is specific to a machine lives here: the commands the
// modules run, the thresholds of the metrics, the intervals of the polls,
// the fonts, the colours and the outputs the bar is shown on.
//
// The values are kept in memory, the file they are stored in is the job of
// the adapter of the config file, so the settings can be used without one.
//
// A setting is a property of this singleton. It reads its value from the
// stored values and the page of the settings writes it back:
//
//     property int cpuWarning: root.value("cpuWarning", 75)
//     Settings.set("cpuWarning", 80)
//
// The defaults are the values of the waybar config this bar is a port of.
QtObject {
    id: root

    // The stored values, keyed by the name of the setting.
    property var stored: ({})

    // The values changed. The adapter of the config file listens to it and
    // writes them to the file. The key is the setting that changed, so the
    // adapter only writes the values the user edited.
    signal changed(string key)

    // The last failure to write the config file, empty when the file is in
    // sync. It is not a setting: the adapter sets it so the page can show
    // that a change was not persisted.
    property string saveError: ""

    // ── the values ──────────────────────────────────────────────────────────

    // The outputs the bar is shown on, separated by commas. An empty value
    // shows the bar on every output; a list that matches no connected screen
    // falls back to every output as well.
    property string outputs: root.value("outputs", "")

    // The font of the text of the bar.
    property string fontFamily: root.value("fontFamily", "Geist")

    // The font the icons of the bar are drawn with.
    property string iconFont: root.value("iconFont", "CaskaydiaCove Nerd Font")

    // The size of the text of the bar, in pixels.
    property int fontSize: root.value("fontSize", 16)

    // Whether the bar animates its changes. The user can ask for reduced
    // motion, the bar then changes its state without animating it.
    property bool reducedMotion: root.value("reducedMotion", false)

    // Whether a popup shrinks back into the bar when it closes.
    property bool popupExitAnimation: root.value("popupExitAnimation", true)

    // Whether the clock shows the time in the 24 hour format.
    property bool clock24Hour: root.value("clock24Hour", true)

    // The format of the date, the way Qt.formatDate knows it.
    property string dateFormat: root.value("dateFormat", "dd-MM")

    // The command that opens the application launcher.
    property string launcherCommand: root.value("launcherCommand", "rofi -show drun")

    // The command that opens the power menu.
    property string powerMenuCommand: root.value("powerMenuCommand", "wlogout")

    // The command that opens the network manager.
    property string networkManagerCommand: root.value("networkManagerCommand",
        "xdg-open vicinae://launch/@dagimg-dot/store.vicinae.wifi-commander/scan-wifi")

    // The command that opens the bluetooth manager.
    property string bluetoothManagerCommand: root.value("bluetoothManagerCommand",
        "xdg-open vicinae://launch/@Gelei/store.vicinae.bluetooth/devices")

    // The command that installs the pending updates.
    property string updatesCommand: root.value("updatesCommand", "kitty -T Updates yay -Syua")

    // The command that counts the pending updates.
    property string updatesCheckCommand: root.value("updatesCheckCommand", "checkupdates")

    // The usage of the processor that is a warning, in percent.
    property int cpuWarning: root.value("cpuWarning", 75)

    // The usage of the processor that is critical, in percent.
    property int cpuCritical: root.value("cpuCritical", 90)

    // The used memory that is a warning, in percent.
    property int memoryWarning: root.value("memoryWarning", 75)

    // The used memory that is critical, in percent.
    property int memoryCritical: root.value("memoryCritical", 90)

    // The temperature that is critical, in degrees Celsius.
    property int temperatureCritical: root.value("temperatureCritical", 90)

    // The charge of the battery that is a warning, in percent.
    property int batteryWarning: root.value("batteryWarning", 20)

    // The charge of the battery that is critical, in percent.
    property int batteryCritical: root.value("batteryCritical", 10)

    // How often the usage of the processor is read, in seconds.
    property int cpuInterval: root.value("cpuInterval", 10)

    // How often the used memory is read, in seconds.
    property int memoryInterval: root.value("memoryInterval", 10)

    // How often the temperature is read, in seconds.
    property int temperatureInterval: root.value("temperatureInterval", 10)

    // How often the state of the network is read, in seconds.
    property int networkInterval: root.value("networkInterval", 10)

    // How often the brightness is read, in seconds.
    property int backlightInterval: root.value("backlightInterval", 2)

    // How often the pending updates are counted, in minutes.
    property int updatesInterval: root.value("updatesInterval", 60)

    // The thermal zone the temperature of the processor is read from.
    property int thermalZone: root.value("thermalZone", 1)

    // The unit the temperature is shown in: "F" or "C".
    property string temperatureUnit: root.value("temperatureUnit", "F")

    // The step the volume changes by, in percent.
    property int volumeStep: root.value("volumeStep", 2)

    // The loudest volume, in percent.
    property int volumeMax: root.value("volumeMax", 150)

    // The palette the bar is painted with. The roles of a palette live in
    // bar/ThemePalette.qml; the name is all the file has to store.
    property string palette: root.value("palette", "mecha")

    // The colour of the accent, the highlighted parts of the bar. It is an
    // explicit override: when it was never set it follows the palette.
    property string accentColor: root.value("accentColor",
        ThemePalette.byName(root.palette).accent)

    // The colour of the background of the bar.
    property string backgroundColor: root.value("backgroundColor",
        ThemePalette.byName(root.palette).background)

    // The colour of the text of the bar.
    property string foregroundColor: root.value("foregroundColor",
        ThemePalette.byName(root.palette).foreground)

    // ── the sections of the settings page ───────────────────────────────────

    // The settings of the bar, grouped in the sections of the page. Every
    // entry names the property that holds its value, so the page and the
    // settings always agree.
    readonly property var sections: [
        {
            title: "Bar",
            entries: [
                { key: "outputs", label: "Outputs", type: "text",
                    hint: "empty shows the bar everywhere" },
                { key: "fontFamily", label: "Font", type: "text" },
                { key: "iconFont", label: "Icon font", type: "text" },
                { key: "fontSize", label: "Font size", type: "number", min: 8, max: 48 },
                { key: "reducedMotion", label: "Reduced motion", type: "toggle" },
                { key: "popupExitAnimation", label: "Animate popup exit", type: "toggle" }
            ]
        },
        {
            title: "Clock",
            entries: [
                { key: "clock24Hour", label: "24 hour time", type: "toggle" },
                { key: "dateFormat", label: "Date format", type: "text" }
            ]
        },
        {
            title: "Commands",
            entries: [
                { key: "launcherCommand", label: "Launcher", type: "command" },
                { key: "powerMenuCommand", label: "Power menu", type: "command",
                    destructive: true },
                { key: "networkManagerCommand", label: "Network manager", type: "command" },
                { key: "bluetoothManagerCommand", label: "Bluetooth manager", type: "command" },
                { key: "updatesCommand", label: "Updates", type: "command",
                    destructive: true },
                { key: "updatesCheckCommand", label: "Update check", type: "text",
                    hint: "run through sh -c, not directly" }
            ]
        },
        {
            title: "Thresholds",
            entries: [
                { key: "cpuWarning", label: "Processor warning", type: "number",
                    min: 0, max: 100, unit: "%" },
                { key: "cpuCritical", label: "Processor critical", type: "number",
                    min: 0, max: 100, unit: "%" },
                { key: "memoryWarning", label: "Memory warning", type: "number",
                    min: 0, max: 100, unit: "%" },
                { key: "memoryCritical", label: "Memory critical", type: "number",
                    min: 0, max: 100, unit: "%" },
                { key: "temperatureCritical", label: "Temperature critical", type: "number",
                    min: 0, max: 150, unit: "°C" },
                { key: "batteryWarning", label: "Battery warning", type: "number",
                    min: 0, max: 100, unit: "%" },
                { key: "batteryCritical", label: "Battery critical", type: "number",
                    min: 0, max: 100, unit: "%" }
            ]
        },
        {
            title: "Polling",
            entries: [
                { key: "cpuInterval", label: "Processor", type: "number",
                    min: 1, max: 600, unit: "s" },
                { key: "memoryInterval", label: "Memory", type: "number",
                    min: 1, max: 600, unit: "s" },
                { key: "temperatureInterval", label: "Temperature", type: "number",
                    min: 1, max: 600, unit: "s" },
                { key: "networkInterval", label: "Network", type: "number",
                    min: 1, max: 600, unit: "s" },
                { key: "backlightInterval", label: "Brightness", type: "number",
                    min: 1, max: 600, unit: "s" },
                { key: "updatesInterval", label: "Updates", type: "number",
                    min: 1, max: 1440, unit: "min" }
            ]
        },
        {
            title: "System",
            entries: [
                { key: "thermalZone", label: "Thermal zone", type: "number", min: 0, max: 20 },
                { key: "temperatureUnit", label: "Temperature unit", type: "choice",
                    choices: ["F", "C"], labels: ["Fahrenheit", "Celsius"] },
                { key: "volumeStep", label: "Volume step", type: "number",
                    min: 1, max: 25, unit: "%" },
                { key: "volumeMax", label: "Volume max", type: "number",
                    min: 100, max: 200, unit: "%" }
            ]
        },
        {
            title: "Colours",
            entries: [
                { key: "palette", label: "Palette", type: "choice",
                    choices: ["mecha", "light"], labels: ["Mecha", "Light"] },
                { key: "accentColor", label: "Accent", type: "color" },
                { key: "backgroundColor", label: "Background", type: "color" },
                { key: "foregroundColor", label: "Text", type: "color" }
            ]
        }
    ]

    // ── the values ──────────────────────────────────────────────────────────

    // The value of a setting, or its default when it was never stored.
    function value(key, fallback) {
        return root.stored[key] !== undefined ? root.stored[key] : fallback
    }

    // Store a value.
    function set(key, val) {
        if (root.stored[key] === val)
            return
        const next = Object.assign({}, root.stored)
        next[key] = val

        // A palette switch moves the three colour overrides to the defaults
        // of the new palette when they still hold the defaults of the old
        // one. A colour the user picked is left alone: only an override that
        // equals the old palette's role is carried over. An override that was
        // never stored follows the palette on its own, so it is not written
        // here.
        const follow = []
        if (key === "palette") {
            const from = ThemePalette.byName(root.palette)
            const to = ThemePalette.byName(val)
            const overrides = [
                ["accentColor", "accent"],
                ["backgroundColor", "background"],
                ["foregroundColor", "foreground"]
            ]
            for (let i = 0; i < overrides.length; i++) {
                const colorKey = overrides[i][0]
                const role = overrides[i][1]
                if (next[colorKey] !== undefined && next[colorKey] === from[role]) {
                    next[colorKey] = to[role]
                    follow.push(colorKey)
                }
            }
        }

        root.stored = next
        root.changed(key)
        for (let i = 0; i < follow.length; i++)
            root.changed(follow[i])
    }

    // Replace the values with the ones that were read from the file.
    function load(values) {
        if (!values || typeof values !== "object")
            return
        root.stored = values
    }

    // Split a command line into the arguments of a process.
    //
    // The split is a small state machine rather than a regular expression:
    // a quote may start anywhere in an argument, so `--title="My Terminal"`
    // is one argument with the quotes removed. Backslash escapes the next
    // character outside quotes and inside double quotes; single quotes are
    // literal, the way a shell treats them. An empty quoted argument is an
    // argument, and an unmatched quote is an error instead of a guess.
    function tokenize(line) {
        const args = []
        let current = ""
        let inToken = false
        let quote = ""
        let escaped = false

        for (let i = 0; i < line.length; i++) {
            const ch = line.charAt(i)

            if (escaped) {
                current += ch
                escaped = false
                continue
            }

            if (quote === "'") {
                if (ch === "'")
                    quote = ""
                else
                    current += ch
                continue
            }

            if (quote === '"') {
                if (ch === "\\")
                    escaped = true
                else if (ch === '"')
                    quote = ""
                else
                    current += ch
                continue
            }

            if (ch === "\\") {
                escaped = true
                inToken = true
            } else if (ch === '"' || ch === "'") {
                quote = ch
                inToken = true
            } else if (ch === " " || ch === "\t" || ch === "\n" || ch === "\r") {
                if (inToken) {
                    args.push(current)
                    current = ""
                    inToken = false
                }
            } else {
                current += ch
                inToken = true
            }
        }

        if (escaped)
            return { args: [], error: "the command ends with a backslash that escapes nothing" }
        if (quote === '"')
            return { args: [], error: "unmatched double quote" }
        if (quote === "'")
            return { args: [], error: "unmatched single quote" }
        if (inToken)
            args.push(current)
        return { args: args, error: "" }
    }

    // The arguments of a command line, or no arguments when the line is not
    // valid. commandError() says what is wrong with it.
    function command(line) {
        return root.tokenize(line).args
    }

    // The reason a command line will not be run, or an empty string when it
    // is valid.
    //
    // Commands run directly, not through a shell. Shell syntax would be
    // split into ordinary arguments and silently do the wrong thing, so it
    // is rejected before launch instead. Quoting or escaping a character
    // passes it literally and is allowed.
    function commandError(line) {
        const parsed = root.tokenize(line)
        if (parsed.error !== "")
            return parsed.error

        const tradeoff = "commands run directly, not through a shell"
        let quote = ""
        let escaped = false
        let atTokenStart = true

        for (let i = 0; i < line.length; i++) {
            const ch = line.charAt(i)
            const next = i + 1 < line.length ? line.charAt(i + 1) : ""

            if (escaped) {
                escaped = false
                atTokenStart = false
                continue
            }

            if (quote === "'") {
                if (ch === "'") {
                    quote = ""
                    atTokenStart = false
                }
                continue
            }

            if (quote === '"') {
                if (ch === "\\")
                    escaped = true
                else if (ch === '"')
                    quote = ""
                else if (ch === "`")
                    return "command substitution is not supported; " + tradeoff
                else if (ch === "$" && /[A-Za-z0-9_{(@*#?$!-]/.test(next))
                    return "variables are not expanded; " + tradeoff
                continue
            }

            if (ch === "\\") {
                escaped = true
                atTokenStart = false
            } else if (ch === '"' || ch === "'") {
                quote = ch
                atTokenStart = false
            } else if (ch === "|") {
                return "pipes are not supported; " + tradeoff
            } else if (ch === "&") {
                return "&& and & are not supported; " + tradeoff
            } else if (ch === ";") {
                return "semicolons are not supported; " + tradeoff
            } else if (ch === "<" || ch === ">") {
                return "redirection is not supported; " + tradeoff
            } else if (ch === "`") {
                return "command substitution is not supported; " + tradeoff
            } else if (ch === "$" && /[A-Za-z0-9_{(@*#?$!-]/.test(next)) {
                return "variables are not expanded; " + tradeoff
            } else if (ch === "~" && atTokenStart) {
                return "~ is not expanded; " + tradeoff
            } else {
                // a shell also expands ~ at the start of the value of an
                // assignment, such as --prefix=~/bin
                atTokenStart = ch === " " || ch === "\t" || ch === "\n"
                    || ch === "\r" || ch === "="
            }
        }

        return ""
    }

    // The duration of an animation of the bar. It is zero when the user
    // asks for reduced motion, the bar then changes its state at once.
    function motion(duration) {
        return root.reducedMotion ? 0 : duration
    }
}
