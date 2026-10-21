import QtQuick
import Quickshell
import "../"

// WindowTitle — port of the waybar "niri/window" module.
//
// Shows the icon of the focused application followed by its title. The
// waybar config rewrites an empty title to "Desktop".
Module {
    id: root

    bg: "transparent"
    // #window { margin: 0 12px; }
    padLeft: 12
    padRight: 12
    contentSpacing: 4

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

    implicitWidth: padLeft + padRight + (appIcon !== "" ? Theme.iconSize + contentSpacing : 0)
        + titleText.width

    Image {
        source: root.appIcon !== "" ? "image://icon/" + root.appIcon : ""
        visible: root.appIcon !== ""
        width: Theme.iconSize
        height: Theme.iconSize
        sourceSize.width: 48
        sourceSize.height: 48
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    Text {
        id: titleText
        text: root.title
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.labelColor
        elide: Text.ElideRight
        // waybar's niri/window caps the title at 100 characters
        width: Math.min(implicitWidth, 100 * Theme.charWidth)
    }
}
