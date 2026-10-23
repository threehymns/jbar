import QtQuick
import "../"

// PowerButton — the button that opens the power menu.
//
// It is the port of the waybar "custom/power" module.
Module {
    id: root

    bg: Theme.mainBg
    // #custom-power { padding: 0 19px 0 16px; font-size: 18px; }
    padLeft: Theme.px(16)
    padRight: Theme.px(19)
    fg: Theme.accent

    onClicked: root.run(Settings.powerMenuCommand)

    iconText: Icons.power
    iconPixelSize: Theme.px(18)
}
