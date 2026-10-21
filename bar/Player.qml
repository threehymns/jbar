pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Player — the MPRIS player the bar shows.
//
// The playing player wins, otherwise the first known player is used, which
// is the same order the waybar mpris module uses.
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
}
