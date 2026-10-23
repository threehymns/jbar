pragma Singleton
import QtQuick
import QtQml

// Theme — colours, fonts and metrics, ported 1:1 from the waybar config
// (~/.config/waybar/theme.css + styles/fonts.css).
//
// The colours are the roles of the selected palette (`bar/ThemePalette.qml`). The
// property names of the waybar theme are kept as aliases of those roles, so
// the modules and the other tickets keep working unchanged while the bar
// gains a palette that can be switched at runtime.
QtObject {
    id: theme

    // ── the palette ─────────────────────────────────────────────────────────
    // The name of the palette the user picked and its roles. A switch of
    // Settings.palette changes the name, which re-evaluates every role below
    // and repaints the bar without a restart.
    readonly property string palette: Settings.palette
    readonly property var paletteColors: ThemePalette.byName(theme.palette)

    // ── semantic colour roles ──────────────────────────────────────────────
    readonly property color background: paletteColors.background
    readonly property color surface: paletteColors.surface
    readonly property color surfaceAlt: paletteColors.surfaceAlt
    readonly property color surfaceHigh: paletteColors.surfaceHigh
    readonly property color surfaceHover: paletteColors.surfaceHover
    readonly property color surfaceBorder: paletteColors.surfaceBorder

    readonly property color foreground: paletteColors.foreground
    readonly property color foregroundStrong: paletteColors.foregroundStrong
    readonly property color foregroundMuted: paletteColors.foregroundMuted
    readonly property color foregroundDim: paletteColors.foregroundDim

    // The background of the bar and the text of the bar are explicit user
    // overrides: they default to the palette, but a colour the user picked
    // wins. onAccent is the text that sits on an accent block (the logo of
    // the distribution); it follows the background override so the block and
    // the bar keep matching.
    readonly property color accent: Settings.accentColor
    readonly property color mainBg: Settings.backgroundColor
    readonly property color mainFg: Settings.foregroundColor
    readonly property color onAccent: Settings.backgroundColor

    readonly property color warning: paletteColors.warning
    readonly property color critical: paletteColors.critical
    readonly property color positive: paletteColors.positive
    readonly property color outline: paletteColors.outline

    // ── gruvbox palette names ───────────────────────────────────────────────
    // The named ramp of the waybar theme. They are aliases of the palette so
    // a palette switch recolours them too.
    readonly property color bg0: paletteColors.bg0
    readonly property color bg1: paletteColors.bg1
    readonly property color bg2: paletteColors.bg2
    readonly property color bg3: paletteColors.bg3
    readonly property color bg4: paletteColors.bg4

    readonly property color fg0: paletteColors.fg0
    readonly property color fg1: paletteColors.fg1
    readonly property color fg2: paletteColors.fg2
    readonly property color fg3: paletteColors.fg3
    readonly property color fg4: paletteColors.fg4

    readonly property color red: paletteColors.red
    readonly property color green: paletteColors.green
    readonly property color yellow: paletteColors.yellow
    readonly property color blue: paletteColors.blue
    readonly property color purple: paletteColors.purple
    readonly property color aqua: paletteColors.aqua
    readonly property color orange: paletteColors.orange
    readonly property color gray: paletteColors.gray

    // ── main colours ────────────────────────────────────────────────────────
    // The waybar names of the bar background, the text and the hover state.
    readonly property color mainBr: paletteColors.surfaceBorder
    readonly property color hoverBg: paletteColors.surfaceAlt
    readonly property color hoverFg: paletteColors.hoverForeground
    // The dimmed colour of a secondary label (the mpris artist).
    readonly property color dimFg: paletteColors.foregroundDim

    // ── module background colours ───────────────────────────────────────────
    readonly property color workspaces: paletteColors.workspaces
    readonly property color temperature: paletteColors.temperature
    readonly property color memory: paletteColors.memory
    readonly property color cpu: paletteColors.cpu
    readonly property color time: paletteColors.time
    readonly property color date: paletteColors.date
    readonly property color tray: paletteColors.tray
    readonly property color volume: paletteColors.volume
    readonly property color backlight: paletteColors.backlight
    readonly property color battery: paletteColors.battery

    // ── state colours ───────────────────────────────────────────────────────
    readonly property color charging: paletteColors.positive

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

    // The text sizes of the bar. `fontSize` is the size the user sets; the
    // others are the two secondary sizes of the waybar design, scaled with
    // the bar. At 16 px they are the 11 px artist line and the 13 px title
    // of a popup, exactly as before.
    readonly property int fontSizeBar: theme.fontSize
    readonly property int fontSizeSecondary: theme.px(11)
    readonly property int fontSizeTitle: theme.px(13)

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

    // ── spacing ─────────────────────────────────────────────────────────────
    // The spacing steps of the 16 px design. A number that is specific to one
    // module (the 5 px padding of the Bluetooth module, the 19 px right
    // padding of the power button) stays a Theme.px() of its design value.
    readonly property int spaceXs: theme.px(2)
    readonly property int spaceSm: theme.px(4)
    readonly property int spaceMd: theme.px(8)
    readonly property int spaceLg: theme.px(12)
    readonly property int spaceXl: theme.px(16)

    // The height of a row of the bar. It is the 31 px default row scaled with
    // the font, but never less than the text plus the scaled padding of the
    // row, so the text of 8 px and 48 px labels never clips.
    readonly property int rowPadding: theme.spaceMd
    readonly property int rowHeight: Math.max(fontSize + rowPadding, theme.px(31))

    // The horizontal padding and the hover radius of a module.
    readonly property int modulePadding: theme.px(10)
    readonly property int moduleRadius: theme.px(16)

    // ── radii ───────────────────────────────────────────────────────────────
    // The radii of the popups and their controls. moduleRadius is the fully
    // rounded hover background of a module.
    readonly property int radiusSm: theme.px(4)
    readonly property int radiusMd: theme.px(8)
    readonly property int radiusLg: theme.px(12)

    // The width of the frame of a popup.
    readonly property int borderWidth: theme.px(2)

    // The space between the frame of a popup and its content.
    readonly property int popupPadding: theme.px(20)

    // One workspace cell: as tall as a row and square, so the glyph stays
    // centred in the cell at every font size. The one pixel of padding and
    // the larger glyph of the active workspace are part of the cell.
    readonly property int workspaceCell: rowHeight
    readonly property int workspacePadding: theme.px(1)
    readonly property int workspaceActiveSize: theme.px(20)

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
