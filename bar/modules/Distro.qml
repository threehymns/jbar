import QtQuick
import Quickshell
import "../"

// Distro — port of the waybar "custom/distro" module.
//
// A single icon on the accent background that opens the application launcher.
Module {
    id: root

    bg: Theme.accent
    fg: Theme.mainBg
    // #custom-distro { padding: 0 15px 0 10px; font-size: 20px; }
    padLeft: 10
    padRight: 15

    onClicked: Quickshell.execDetached(["rofi", "-show", "drun"])

    iconText: Icons.distro
    iconPixelSize: 20
}
