pragma Singleton
import QtQuick

// ThemePalette — the colour roles of a theme of the bar.
//
// A palette is a plain object of role names and colour values. The bar never
// names a colour of its own: Theme maps the roles of the selected palette to
// the properties the modules read, so switching the palette repaints the
// whole bar without a restart.
//
// The "mecha" palette is the gruvbox-dark palette of the waybar config this
// bar is a port of, value for value. "light" is the gruvbox-light counterpart:
// the same roles, the same ramp, the colours inverted.
//
// Adding a palette: add its object to `palettes` with every role of `roles`
// below, then add its name to the settings choice in Settings.qml and to
// tests/tst_theme.qml. The tests fail when a palette misses a role.
QtObject {
    id: root

    // The roles every palette has to define. `roles` is the schema of a
    // palette; the tests compare it with the keys of each palette.
    readonly property var roles: [
        // The surface ramp: the bar background and the modules on it.
        "background",
        "surface",
        "surfaceAlt",
        "surfaceHigh",
        "surfaceHover",
        "surfaceBorder",
        // The text.
        "foreground",
        "foregroundStrong",
        "foregroundMuted",
        "foregroundDim",
        "hoverForeground",
        // The accent and the state colours.
        "accent",
        "onAccent",
        "warning",
        "critical",
        "positive",
        "outline",
        // The gruvbox ramp and terminal colours. They are kept as named
        // roles because the calendar, the workspaces and the state colours
        // were ported from the waybar palette with these names.
        "bg0", "bg1", "bg2", "bg3", "bg4",
        "fg0", "fg1", "fg2", "fg3", "fg4",
        "red", "green", "yellow", "blue", "purple", "aqua", "orange", "gray",
        // The background of every module that has one of its own.
        "workspaces", "temperature", "memory", "cpu", "time", "date",
        "tray", "volume", "backlight", "battery"
    ]

    // The palettes by name. The values are the roles of `roles` above.
    //
    // foregroundDim and hoverForeground are the fg1 text at 60 % and 75 %
    // alpha, the way the waybar stylesheet dims a label.
    readonly property var palettes: ({
        mecha: {
            background: "#1d2021",
            surface: "#282828",
            surfaceAlt: "#3c3836",
            surfaceHigh: "#504945",
            surfaceHover: "#665c54",
            surfaceBorder: "#7c6f64",

            foreground: "#ebdbb2",
            foregroundStrong: "#fbf1c7",
            foregroundMuted: "#bdae93",
            foregroundDim: "#99ebdbb2",
            hoverForeground: "#bfebdbb2",

            accent: "#83a598",
            onAccent: "#1d2021",
            warning: "#fabd2f",
            critical: "#fb4934",
            positive: "#b8bb26",
            outline: "#0e1010",

            bg0: "#282828",
            bg1: "#3c3836",
            bg2: "#504945",
            bg3: "#665c54",
            bg4: "#7c6f64",
            fg0: "#fbf1c7",
            fg1: "#ebdbb2",
            fg2: "#d5c4a1",
            fg3: "#bdae93",
            fg4: "#a89984",
            red: "#fb4934",
            green: "#b8bb26",
            yellow: "#fabd2f",
            blue: "#83a598",
            purple: "#d3869b",
            aqua: "#8ec07c",
            orange: "#fe8019",
            gray: "#928374",

            workspaces: "#282828",
            temperature: "#282828",
            memory: "#3c3836",
            cpu: "#504945",
            time: "#504945",
            date: "#3c3836",
            tray: "#282828",
            volume: "#282828",
            backlight: "#3c3836",
            battery: "#504945"
        },

        // A light theme on the gruvbox-light ramp. The bar background is
        // bg0 and the modules step down the ramp, the same way the dark
        // palette steps up from the bar background. warning and positive are
        // darker than the gruvbox yellow and green so the state labels stay
        // readable on the light surfaces.
        light: {
            background: "#fbf1c7",
            surface: "#f2e5bc",
            surfaceAlt: "#ebdbb2",
            surfaceHigh: "#d5c4a1",
            surfaceHover: "#bdae93",
            surfaceBorder: "#a89984",

            foreground: "#3c3836",
            foregroundStrong: "#282828",
            foregroundMuted: "#665c54",
            foregroundDim: "#993c3836",
            hoverForeground: "#bf3c3836",

            accent: "#076678",
            onAccent: "#fbf1c7",
            warning: "#805400",
            critical: "#9d0006",
            positive: "#5f5c00",
            outline: "#d5c4a1",

            bg0: "#fbf1c7",
            bg1: "#ebdbb2",
            bg2: "#d5c4a1",
            bg3: "#bdae93",
            bg4: "#a89984",
            fg0: "#282828",
            fg1: "#3c3836",
            fg2: "#504945",
            fg3: "#665c54",
            fg4: "#7c6f64",
            red: "#9d0006",
            green: "#79740e",
            yellow: "#b57614",
            blue: "#076678",
            purple: "#8f3f71",
            aqua: "#427b58",
            orange: "#af3a03",
            gray: "#928374",

            workspaces: "#f2e5bc",
            temperature: "#f2e5bc",
            memory: "#ebdbb2",
            cpu: "#d5c4a1",
            time: "#d5c4a1",
            date: "#ebdbb2",
            tray: "#f2e5bc",
            volume: "#f2e5bc",
            backlight: "#ebdbb2",
            battery: "#d5c4a1"
        }
    })

    // The names of the palettes, in the order of the settings choice.
    readonly property var names: ["mecha", "light"]

    // The palette with this name, or the mecha palette for an unknown name.
    // A config file that names a palette this build does not know must not
    // leave the bar without colours.
    function byName(name) {
        return root.palettes[name] !== undefined ? root.palettes[name] : root.palettes.mecha
    }
}
