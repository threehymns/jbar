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
    // writes them to the file.
    signal changed()

    // ── the values ──────────────────────────────────────────────────────────

    // The outputs the bar is shown on, separated by commas. An empty value
    // shows the bar on every output.
    property string outputs: root.value("outputs", "eDP-1, HDMI-A-1, DP-2")

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

    // The colour of the accent, the highlighted parts of the bar.
    property string accentColor: root.value("accentColor", "#83a598")

    // The colour of the background of the bar.
    property string backgroundColor: root.value("backgroundColor", "#1d2021")

    // The colour of the text of the bar.
    property string foregroundColor: root.value("foregroundColor", "#ebdbb2")

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
                { key: "launcherCommand", label: "Launcher", type: "text" },
                { key: "powerMenuCommand", label: "Power menu", type: "text" },
                { key: "networkManagerCommand", label: "Network manager", type: "text" },
                { key: "bluetoothManagerCommand", label: "Bluetooth manager", type: "text" },
                { key: "updatesCommand", label: "Updates", type: "text" },
                { key: "updatesCheckCommand", label: "Update check", type: "text" }
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
        root.stored = next
        root.changed()
    }

    // Replace the values with the ones that were read from the file.
    function load(values) {
        if (!values || typeof values !== "object")
            return
        root.stored = values
    }

    // Split a command line into the arguments of a process. A part of it in
    // quotes stays one argument.
    function command(line) {
        const args = []
        const pattern = /"([^"]*)"|'([^']*)'|(\S+)/g
        let match = pattern.exec(line)
        while (match !== null) {
            args.push(match[1] !== undefined ? match[1]
                : (match[2] !== undefined ? match[2] : match[3]))
            match = pattern.exec(line)
        }
        return args
    }

    // The duration of an animation of the bar. It is zero when the user
    // asks for reduced motion, the bar then changes its state at once.
    function motion(duration) {
        return root.reducedMotion ? 0 : duration
    }
}
