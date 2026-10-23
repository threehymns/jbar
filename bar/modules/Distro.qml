import QtQuick
import "../"

// Distro — port of the waybar "custom/distro" module.
//
// A single icon on the accent background that opens the application
// launcher.
//
// The icon is the trigger of a drawer group: the button of the settings
// slides out to the left of it, the power button and the idle inhibitor to
// the right, the same way the waybar drawer groups work.
DrawerGroup {
    id: root

    // The group stays open while the settings are open, so the button does
    // not slide back while the pointer is in the settings.
    keepOpen: settings.popup !== null && settings.popup.visible

    // The drawer slides out over the modules next to the group, so the icon
    // of the distribution keeps its place.
    overlay: true

    // The icon of the distribution.
    Module {
        id: logo

        bg: Theme.accent
        fg: Theme.mainBg
        // #custom-distro { padding: 0 15px 0 10px; font-size: 20px; }
        padLeft: 10
        padRight: 15

        onClicked: logo.run(Settings.launcherCommand)

        iconText: Icons.distro
        iconPixelSize: 20
    }

    // The modules that slide out to the left of the icon.
    hidden: [
        SettingsButton {
            id: settings
        }
    ]

    // The modules that slide out to the right of the icon.
    hiddenRight: [
        PowerButton {},

        IdleToggle {}
    ]
}
