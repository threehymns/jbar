pragma Singleton
import QtQuick
import QtQml

// Theme — colours, fonts and metrics, ported 1:1 from the waybar config
// (~/.config/waybar/theme.css + styles/fonts.css).
QtObject {
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
    // The three colours the user can change live in the settings.
    readonly property color accent: Settings.accentColor
    readonly property color mainBr: bg4
    readonly property color mainBg: Settings.backgroundColor
    readonly property color mainFg: Settings.foregroundColor
    readonly property color hoverBg: bg1
    readonly property color hoverFg: Qt.rgba(fg1.r, fg1.g, fg1.b, 0.75)
    // The dimmed colour of a secondary label (the mpris artist).
    readonly property color dimFg: Qt.rgba(fg1.r, fg1.g, fg1.b, 0.6)
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
    readonly property string fontFamily: Settings.fontFamily

    // The Nerd Font the icons are drawn with. Fontconfig resolves the
    // private use codepoints of the waybar config to this font, so using it
    // explicitly keeps the icons identical to the waybar ones.
    readonly property string iconFont: Settings.iconFont
    readonly property int fontSize: Settings.fontSize
    readonly property int iconSize: Settings.fontSize

    // ── the scale of the bar ────────────────────────────────────────────────
    // The bar was designed for 16 px text: a 31 px row, 10 px module padding
    // and 7.2 px per character. The font size setting goes from 8 to 48 px,
    // so every layout metric is derived from this one scale. At 16 px the
    // scale is 1 and the bar looks exactly like the waybar config.
    readonly property real scale: fontSize / 16

    // A design size of the 16 px bar, scaled to the current font size.
    function px(value) {
        return Math.round(value * theme.scale)
    }

    // The height of a row of the bar. It is the 31 px default row scaled with
    // the font, but never less than the text plus the scaled padding of the
    // row, so the text of 8 px and 48 px labels never clips.
    readonly property int rowPadding: theme.px(8)
    readonly property int rowHeight: Math.max(fontSize + rowPadding, theme.px(31))

    // The horizontal padding and the hover radius of a module.
    readonly property int modulePadding: theme.px(10)
    readonly property int moduleRadius: theme.px(16)

    // One workspace cell: as tall as a row and square, so the glyph stays
    // centred in the cell at every font size.
    readonly property int workspaceCell: rowHeight

    // waybar's "min-length"/"max-length" are expressed in characters. Pango,
    // the text stack waybar uses, measures a character of the bar font at
    // about 7.2 pixels at the default size, so the same value is used here
    // to turn the min-lengths of the waybar config into pixels. It follows
    // the font size with the rest of the bar.
    readonly property real charWidth: 7.2 * scale

    // The advance width of a space in the bar font. The waybar formats
    // separate the icon and the value with a space, so the modules use this
    // to keep the same gap between the two.
    property TextMetrics spaceMetrics: TextMetrics {
        font.family: theme.fontFamily
        font.pixelSize: theme.fontSize
        text: " "
    }

    readonly property real labelSpacing: spaceMetrics.advanceWidth

    // Minimum width (px) for a label padded to `chars` characters.
    function minWidth(chars) {
        return Math.ceil(chars * charWidth);
    }
}
