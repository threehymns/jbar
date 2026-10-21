import QtQuick
import "../"

// AlbumArt — port of the waybar "image#album-art" module.
//
// Shows the cover art of the current MPRIS player.
Module {
    id: root

    bg: "transparent"
    // #image.album-art { padding: 0 0 0 12px; }
    padLeft: 12
    padRight: 0

    readonly property var player: Player.current
    readonly property string artUrl: {
        if (!player)
            return ""
        const url = player.trackArtUrl || ""
        if (url.indexOf("file://") === 0 || url.indexOf("http://") === 0
            || url.indexOf("https://") === 0)
            return url
        return ""
    }

    onClicked: Player.toggle()
    onMiddleClicked: Player.toggle()
    onRightClicked: Player.next()
    onScrolled: direction => {
        if (direction > 0)
            Player.next()
        else
            Player.previous()
    }

    iconImage: root.artUrl
    iconPixelSize: 24
}
