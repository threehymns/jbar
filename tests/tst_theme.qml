import QtQuick
import QtTest
import "../bar/"

// The tests of the palette and of the theme tokens.
//
// The palette is a plain object and the theme derives every colour and every
// metric from it, so the palette can be switched and the tokens can be
// checked without a bar and without a compositor.
TestCase {
    name: "Theme"

    // A module colour follows the palette through the binding, the same way
    // a Rectangle of a module does.
    Rectangle {
        id: moduleProbe
        color: Theme.memory
    }

    function init() {
        Settings.load({})
        Settings.set("fontSize", 16)
        Settings.set("palette", "mecha")
    }

    function cleanup() {
        Settings.load({})
    }

    // The value of a design size scaled like Theme.px() scales it.
    function px(value, size) {
        return Math.round(value * size / 16)
    }

    // The relative luminance of an "#rrggbb" colour, the WCAG definition.
    function luminance(hex) {
        const value = hex.replace("#", "")
        const channels = [
            parseInt(value.substring(0, 2), 16),
            parseInt(value.substring(2, 4), 16),
            parseInt(value.substring(4, 6), 16)
        ]
        for (let i = 0; i < channels.length; i++) {
            const c = channels[i] / 255
            channels[i] = c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]
    }

    function contrast(a, b) {
        const la = luminance(a)
        const lb = luminance(b)
        const high = Math.max(la, lb)
        const low = Math.min(la, lb)
        return (high + 0.05) / (low + 0.05)
    }

    function test_the_mecha_palette_is_the_current_palette() {
        const palette = ThemePalette.byName("mecha")
        const expected = {
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
        }

        const roles = Object.keys(expected)
        for (let i = 0; i < roles.length; i++)
            compare(palette[roles[i]], expected[roles[i]], roles[i])
    }

    function test_the_mecha_palette_paints_the_same_bar_as_before() {
        Settings.load({})
        compare(Theme.palette, "mecha")
        compare(Qt.colorEqual(Theme.mainBg, "#1d2021"), true)
        compare(Qt.colorEqual(Theme.mainFg, "#ebdbb2"), true)
        compare(Qt.colorEqual(Theme.accent, "#83a598"), true)
        compare(Qt.colorEqual(Theme.mainBr, "#7c6f64"), true)
        compare(Qt.colorEqual(Theme.hoverBg, "#3c3836"), true)
        compare(Qt.colorEqual(Theme.dimFg, ThemePalette.byName("mecha").foregroundDim), true)
        compare(Qt.colorEqual(Theme.outline, "#0e1010"), true)
        compare(Qt.colorEqual(Theme.workspaces, "#282828"), true)
        compare(Qt.colorEqual(Theme.memory, "#3c3836"), true)
        compare(Qt.colorEqual(Theme.cpu, "#504945"), true)
        compare(Qt.colorEqual(Theme.warning, "#fabd2f"), true)
        compare(Qt.colorEqual(Theme.critical, "#fb4934"), true)
        compare(Qt.colorEqual(Theme.charging, "#b8bb26"), true)
    }

    function test_every_palette_defines_the_same_roles() {
        const reference = Object.keys(ThemePalette.palettes.mecha).sort().join(",")
        for (let i = 0; i < ThemePalette.names.length; i++) {
            const name = ThemePalette.names[i]
            const keys = Object.keys(ThemePalette.byName(name)).sort().join(",")
            compare(keys, reference, name + " has a different set of roles")
        }

        // the schema list and the objects agree in both directions
        const schema = ThemePalette.roles.slice().sort().join(",")
        compare(schema, reference, "the role schema does not match the palettes")
    }

    function test_an_unknown_palette_name_falls_back_to_mecha() {
        const fallback = ThemePalette.byName("a-palette-that-does-not-exist")
        compare(Object.keys(fallback).sort().join(","),
            Object.keys(ThemePalette.palettes.mecha).sort().join(","))
        compare(fallback.background, ThemePalette.palettes.mecha.background)
    }

    function test_switching_the_palette_recolours_the_bar_without_a_restart() {
        Settings.set("palette", "mecha")
        const mecha = ThemePalette.byName("mecha")
        compare(Qt.colorEqual(moduleProbe.color, mecha.memory), true)

        Settings.set("palette", "light")
        const light = ThemePalette.byName("light")
        compare(Theme.palette, "light")
        compare(Qt.colorEqual(Theme.background, light.background), true)
        compare(Qt.colorEqual(Theme.surface, light.surface), true)
        compare(Qt.colorEqual(Theme.foreground, light.foreground), true)
        compare(Qt.colorEqual(Theme.accent, light.accent), true)
        compare(Qt.colorEqual(Theme.mainBg, light.background), true)
        compare(Qt.colorEqual(Theme.mainFg, light.foreground), true)
        compare(Qt.colorEqual(Theme.memory, light.memory), true)
        compare(Qt.colorEqual(Theme.cpu, light.cpu), true)
        compare(Qt.colorEqual(Theme.battery, light.battery), true)
        compare(Qt.colorEqual(moduleProbe.color, light.memory), true)
        verify(!Qt.colorEqual(moduleProbe.color, mecha.memory),
            "the module kept the colour of the old palette")
    }

    function test_the_light_palette_has_readable_contrast() {
        const light = ThemePalette.byName("light")
        verify(contrast(light.foreground, light.background) >= 4.5,
            "foreground on background is "
                + contrast(light.foreground, light.background))
        verify(contrast(light.foreground, light.surface) >= 4.5,
            "foreground on the module background is "
                + contrast(light.foreground, light.surface))
        verify(contrast(light.foreground, light.surfaceAlt) >= 4.5,
            "foreground on the alternate module background is "
                + contrast(light.foreground, light.surfaceAlt))
        verify(contrast(light.foreground, light.surfaceHigh) >= 4.5,
            "foreground on the high module background is "
                + contrast(light.foreground, light.surfaceHigh))
        verify(contrast(light.onAccent, light.accent) >= 4.5,
            "text on the accent is " + contrast(light.onAccent, light.accent))

        // the same check on the default palette keeps the dark bar honest
        const mecha = ThemePalette.byName("mecha")
        verify(contrast(mecha.foreground, mecha.background) >= 4.5,
            "the mecha foreground on its background is "
                + contrast(mecha.foreground, mecha.background))
    }

    function test_the_font_sizes_keep_the_scaled_row_metrics() {
        const sizes = [8, 16, 48]
        for (let i = 0; i < sizes.length; i++) {
            const size = sizes[i]
            Settings.set("fontSize", size)
            compare(Theme.fontSize, size)
            compare(Theme.fontSizeBar, size)
            compare(Theme.scale, size / 16)
            compare(Theme.rowPadding, px(8, size))
            compare(Theme.rowHeight, Math.max(size + px(8, size), px(31, size)))
            compare(Theme.modulePadding, px(10, size))
            compare(Theme.moduleRadius, px(16, size))
            compare(Theme.workspaceCell, Theme.rowHeight)
            compare(Theme.fontSizeSecondary, px(11, size))
            compare(Theme.fontSizeTitle, px(13, size))
            verify(Math.abs(Theme.charWidth - 7.2 * size / 16) < 0.0001,
                "the character width of " + size + " px is " + Theme.charWidth)
        }

        Settings.set("fontSize", 16)
        compare(Theme.rowHeight, 31)
        compare(Theme.rowPadding, 8)
    }

    function test_the_spacing_and_radius_tokens_keep_the_design() {
        Settings.set("fontSize", 16)
        compare(Theme.spaceXs, 2)
        compare(Theme.spaceSm, 4)
        compare(Theme.spaceMd, 8)
        compare(Theme.spaceLg, 12)
        compare(Theme.spaceXl, 16)
        compare(Theme.radiusSm, 4)
        compare(Theme.radiusMd, 8)
        compare(Theme.radiusLg, 12)
        compare(Theme.moduleRadius, 16)
        compare(Theme.borderWidth, 2)
        compare(Theme.popupPadding, 20)
        compare(Theme.workspacePadding, 1)
        compare(Theme.workspaceActiveSize, 20)

        const design = [
            ["spaceXs", 2], ["spaceSm", 4], ["spaceMd", 8],
            ["spaceLg", 12], ["spaceXl", 16],
            ["radiusSm", 4], ["radiusMd", 8], ["radiusLg", 12],
            ["moduleRadius", 16], ["popupPadding", 20]
        ]
        const sizes = [8, 16, 48]
        for (let i = 0; i < sizes.length; i++) {
            const size = sizes[i]
            Settings.set("fontSize", size)
            for (let j = 0; j < design.length; j++) {
                const token = design[j][0]
                compare(Theme[token], px(design[j][1], size),
                    token + " at " + size + " px")
            }
        }
        Settings.set("fontSize", 16)
    }

    function test_a_palette_switch_follows_the_untouched_colour_overrides() {
        // No override was stored: the three colours follow the palette.
        Settings.load({})
        compare(Settings.accentColor, ThemePalette.byName("mecha").accent)
        compare(Settings.backgroundColor, ThemePalette.byName("mecha").background)
        compare(Settings.foregroundColor, ThemePalette.byName("mecha").foreground)

        Settings.set("palette", "light")
        compare(Settings.accentColor, ThemePalette.byName("light").accent)
        compare(Settings.backgroundColor, ThemePalette.byName("light").background)
        compare(Settings.foregroundColor, ThemePalette.byName("light").foreground)
        compare(Settings.stored.accentColor, undefined)
    }

    function test_a_palette_switch_moves_an_unmodified_override() {
        // The page may have stored the default: it moves with the palette.
        Settings.load({})
        Settings.set("accentColor", "#83a598")
        Settings.set("backgroundColor", "#1d2021")
        Settings.set("foregroundColor", "#ebdbb2")

        Settings.set("palette", "light")
        compare(Settings.stored.accentColor, ThemePalette.byName("light").accent)
        compare(Settings.stored.backgroundColor, ThemePalette.byName("light").background)
        compare(Settings.stored.foregroundColor, ThemePalette.byName("light").foreground)
        compare(Settings.accentColor, "#076678")
        compare(Settings.backgroundColor, "#fbf1c7")
        compare(Settings.foregroundColor, "#3c3836")
    }

    function test_a_palette_switch_keeps_a_customised_colour() {
        Settings.load({})
        Settings.set("accentColor", "#ff00ff")
        Settings.set("backgroundColor", "#101010")
        Settings.set("foregroundColor", "#eeeeee")

        Settings.set("palette", "light")
        compare(Settings.stored.accentColor, "#ff00ff")
        compare(Settings.stored.backgroundColor, "#101010")
        compare(Settings.stored.foregroundColor, "#eeeeee")
        compare(Settings.accentColor, "#ff00ff")
        compare(Settings.backgroundColor, "#101010")
        compare(Settings.foregroundColor, "#eeeeee")
    }

    function test_the_palette_is_a_setting_of_the_page() {
        let paletteEntry = null
        for (let i = 0; i < Settings.sections.length; i++) {
            const entries = Settings.sections[i].entries
            for (let j = 0; j < entries.length; j++) {
                if (entries[j].key === "palette")
                    paletteEntry = entries[j]
            }
        }
        verify(paletteEntry !== null, "the palette is not in the settings page")
        compare(paletteEntry.type, "choice")
        compare(paletteEntry.choices, ["mecha", "light"])
        compare(paletteEntry.labels, ["Mecha", "Light"])
        compare(Settings.palette, "mecha")
    }
}
