import QtQuick
import Quickshell
import "../"
import "../adapters/"

// WindowTitle — port of the waybar "niri/window" module.
//
// Shows the icon of the focused application followed by its title. The
// waybar config rewrites an empty title to "Desktop".
Module {
    id: root

    bg: "transparent"
    // #window { margin: 0 12px; }
    padLeft: Theme.px(12)
    padRight: Theme.px(12)

    readonly property var window_: Niri.focusedWindow
    readonly property string title: window_ && window_.title !== "" ? window_.title : "Desktop"

    // The application icon is resolved through the desktop entry of the
    // window's app id, the same way waybar's niri/window module does it.
    readonly property string appIcon: {
        if (!window_ || !window_.appId)
            return ""
        let entry = DesktopEntries.byId(window_.appId + ".desktop")
        if (!entry)
            entry = DesktopEntries.heuristicLookup(window_.appId)
        return entry ? entry.icon : ""
    }

    // waybar's niri/window caps the title at 100 characters
    iconImage: root.appIcon !== "" ? "image://icon/" + root.appIcon : ""
    iconPixelSize: Theme.iconSize
    labelText: root.title
    labelMaxChars: 100
}
