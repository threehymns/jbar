pragma Singleton
import QtQuick
import Quickshell

// Theme — colours, fonts and metrics, ported 1:1 from the waybar config
// (~/.config/waybar/theme.css + styles/fonts.css).
Singleton {
    id: theme

    // ── gruvbox-dark palette ────────────────────────────────────────────────
    readonly property color bg0: "#282828"
    readonly property color bg1: "#3c3836"
    readonly property color bg2: "#504945"
    readonly property color bg3: "#665c54"
    readonly property color bg4: "#7c6f64"

    readonly property color fg0: "#fbf1c7"
    readonly property color fg1: "#ebdbb2"
    readonly property color fg2: "#d5c4a1"
    readonly property color fg3: "#bdae93"
    readonly property color fg4: "#a89984"

    readonly property color red: "#fb4934"
    readonly property color green: "#b8bb26"
    readonly property color yellow: "#fabd2f"
    readonly property color blue: "#83a598"
    readonly property color purple: "#d3869b"
    readonly property color aqua: "#8ec07c"
    readonly property color orange: "#fe8019"
    readonly property color gray: "#928374"

    // ── main colours ────────────────────────────────────────────────────────
    readonly property color accent: blue
    readonly property color mainBr: bg4
    readonly property color mainBg: "#1d2021"
    readonly property color mainFg: fg1
    readonly property color hoverBg: bg1
    readonly property color hoverFg: Qt.rgba(fg1.r, fg1.g, fg1.b, 0.75)
    // GTK's shade(main-bg, 0.5)
    readonly property color outline: "#0e1010"

    // ── module background colours ───────────────────────────────────────────
    readonly property color workspaces: bg0
    readonly property color temperature: bg0
    readonly property color memory: bg1
    readonly property color cpu: bg2
    readonly property color time: bg2
    readonly property color date: bg1
    readonly property color tray: bg0
    readonly property color volume: bg0
    readonly property color backlight: bg1
    readonly property color battery: bg2

    // ── state colours ───────────────────────────────────────────────────────
    readonly property color warning: yellow
    readonly property color critical: red
    readonly property color charging: green

    // ── typography ──────────────────────────────────────────────────────────
    // Same stack as the waybar stylesheet. Geist carries the text, Maple Mono
    // NF provides the Nerd Font glyphs that Geist does not have.
    // The waybar stylesheet uses "Geist", "Maple Mono NF", sans-serif. Qt
    // resolves the Nerd Font glyphs through fontconfig on its own, so the
    // primary family is all that is needed here.
    readonly property string fontFamily: "Geist"

    // The Nerd Font the icons are drawn with. Fontconfig resolves the
    // private use codepoints of the waybar config to this font, so using it
    // explicitly keeps the icons identical to the waybar ones.
    readonly property string iconFont: "CaskaydiaCove Nerd Font"
    readonly property int fontSize: 16
    readonly property int iconSize: 16

    // waybar's "min-length"/"max-length" are expressed in characters. Pango,
    // the text stack waybar uses, measures a character of the bar font at
    // about 7.2 pixels, so the same value is used here to turn the
    // min-lengths of the waybar config into pixels.
    readonly property real charWidth: 7.2

    // Minimum width (px) for a label padded to `chars` characters.
    function minWidth(chars) {
        return Math.ceil(chars * charWidth);
    }
}
