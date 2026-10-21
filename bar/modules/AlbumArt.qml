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

    Image {
        source: root.artUrl
        visible: root.artUrl !== ""
        width: 24
        height: 24
        sourceSize.width: 96
        sourceSize.height: 96
        fillMode: Image.PreserveAspectFit
        smooth: true
        // the art changes while the url stays the same
        cache: false
        asynchronous: true
    }
}
