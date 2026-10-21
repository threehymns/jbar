import QtQuick
import Quickshell.Services.Mpris
import "../"

// Mpris — port of the waybar "mpris" module.
//
// Shows the icon, the title and the artist of the current player. The artist
// is drawn smaller and dimmer, like the waybar format does.
Module {
    id: root

    bg: "transparent"
    // #mpris { padding: 0 12px; }
    padLeft: 12
    padRight: 12
    contentSpacing: 6
    dimOnHover: true
    stateDim: Player.paused

    readonly property var player: Player.current
    readonly property string title: player ? (player.trackTitle || "") : ""
    readonly property string artist: player ? (player.trackArtist || "") : ""
    readonly property string album: player ? (player.trackAlbum || "") : ""

    readonly property string icon: Player.paused ? Icons.mprisPaused : Icons.mpris

    tip: root.title === "" ? "" : [
        root.title,
        "󰠃  " + root.artist,
        "󰀥  " + root.album,
        "─────────────",
        (root.player ? root.player.identity : "") + "  •  "
            + (Player.paused ? "Paused" : "Playing")
    ].join("\n")

    onClicked: {
        if (root.player)
            root.player.togglePlaying()
    }
    onMiddleClicked: {
        if (root.player)
            root.player.togglePlaying()
    }
    onRightClicked: {
        if (root.player)
            root.player.next()
    }
    onScrolled: direction => {
        if (!root.player)
            return
        if (direction > 0)
            root.player.next()
        else
            root.player.previous()
    }

    Text {
        text: root.icon
        font.family: Theme.iconFont
        font.pixelSize: Theme.fontSize
        color: root.labelColor
    }

    Text {
        text: root.title
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.labelColor
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 40 * Theme.charWidth)
    }

    Text {
        // <span size="x-small" alpha="60%">- {artist}</span>
        text: root.artist === "" ? "" : "- " + root.artist
        font.family: Theme.fontFamily
        font.pixelSize: 11
        color: Qt.rgba(Theme.mainFg.r, Theme.mainFg.g, Theme.mainFg.b, 0.6)
        elide: Text.ElideRight
        width: Math.min(implicitWidth, 25 * Theme.charWidth)
    }
}
