pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Player — the MPRIS player the bar shows.
//
// The playing player wins, otherwise the first known player is used, which
// is the same order the waybar mpris module uses.
//
// The transport lives here as well, so the album art and the mpris label
// cannot disagree about what a click does.
Singleton {
    readonly property var players: Mpris.players.values

    readonly property var current: {
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing)
                return players[i]
        }
        return players.length > 0 ? players[0] : null
    }

    readonly property bool paused: current !== null
        && current.playbackState === MprisPlaybackState.Paused

    // ── transport ───────────────────────────────────────────────────────────

    function toggle() {
        if (current)
            current.togglePlaying()
    }

    function next() {
        if (current)
            current.next()
    }

    function previous() {
        if (current)
            current.previous()
    }
}
