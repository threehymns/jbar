pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../"

// Niri — thin wrapper around the niri IPC.
//
// waybar talks to niri through its own JSON IPC; here we use `niri msg`.
// The compositor is watched through `niri msg event-stream` and every event
// triggers a re-query of the workspaces and the focused window, which keeps
// the logic simple and always consistent.
Singleton {
    id: root

    // ── state ───────────────────────────────────────────────────────────────

    // [{ id, idx, name, isActive, isFocused, isUrgent, output }]
    property var workspaces: []
    // { id, title, appId }
    property var focusedWindow: null

    // The reconnection policy of the event stream: the delay before the
    // next attempt and whether the fallback has to poll.
    readonly property NiriReconnect reconnect: NiriReconnect {}

    readonly property bool streamAlive: root.reconnect.streamAlive

    // ── actions ─────────────────────────────────────────────────────────────

    function refresh() {
        workspacesProc.running = true
        windowProc.running = true
    }

    function scheduleRefresh() {
        debounce.restart()
    }

    function focusWorkspace(id) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(id)])
    }

    function focusWorkspaceUp() {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace-up"])
    }

    function focusWorkspaceDown() {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace-down"])
    }

    // ── workspaces ──────────────────────────────────────────────────────────

    Process {
        id: workspacesProc
        command: ["niri", "msg", "-j", "workspaces"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)
                    root.workspaces = data.map(ws => ({
                        id: ws.id,
                        idx: ws.idx,
                        name: ws.name,
                        isActive: !!ws.is_active,
                        isFocused: !!ws.is_focused,
                        isUrgent: !!ws.is_urgent,
                        output: ws.output
                    }))
                } catch (err) {
                    console.warn("[niri] could not parse workspaces:", err)
                }
            }
        }
    }

    // ── focused window ──────────────────────────────────────────────────────

    Process {
        id: windowProc
        command: ["niri", "msg", "-j", "focused-window"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const win = JSON.parse(text)
                    root.focusedWindow = {
                        id: win.id,
                        title: win.title || "",
                        appId: win.app_id || ""
                    }
                } catch (err) {
                    root.focusedWindow = null
                }
            }
        }
    }

    // ── event stream ────────────────────────────────────────────────────────

    Process {
        id: streamProc
        command: ["niri", "msg", "event-stream"]
        running: true

        onStarted: root.reconnect.streamStarted()

        onExited: exitCode => {
            const wait = root.reconnect.streamExited()
            console.warn("[niri] event stream exited with code " + exitCode
                + ", reconnecting in " + wait + " ms")
            retryTimer.interval = wait
            retryTimer.restart()
        }

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: {
                root.reconnect.streamRead()
                root.scheduleRefresh()
            }
        }
    }

    // Coalesce bursts of events into a single refresh.
    Timer {
        id: debounce
        interval: 50
        onTriggered: root.refresh()
    }

    // One retry timer, one stream process: the adapter never starts a
    // second event stream while the first one is still running.
    Timer {
        id: retryTimer
        repeat: false
        onTriggered: {
            if (!streamProc.running)
                streamProc.running = true
        }
    }

    // Fallback for when the event stream is unavailable. It is bound to
    // the policy, so it stops as soon as the stream is up again.
    Timer {
        id: fallback
        interval: 2000
        running: root.reconnect.polling
        repeat: true
        onTriggered: root.refresh()
    }
}
