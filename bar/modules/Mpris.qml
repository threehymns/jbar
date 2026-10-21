import QtQuick
import Quickshell.Services.Mpris
import "../"
import "../adapters/"

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

    onClicked: Player.toggle()
    onMiddleClicked: Player.toggle()
    onRightClicked: Player.next()
    onScrolled: direction => {
        if (direction > 0)
            Player.next()
        else
            Player.previous()
    }

    Label {
        text: root.icon
        glyph: true
        color: root.labelColor
    }

    Label {
        text: root.title
        color: root.labelColor
        maxChars: 40
    }

    Label {
        // <span size="x-small" alpha="60%">- {artist}</span>
        text: root.artist === "" ? "" : "- " + root.artist
        color: Theme.dimFg
        pixelSize: 11
        maxChars: 25
    }
}
