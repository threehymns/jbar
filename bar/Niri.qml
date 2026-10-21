pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

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

    readonly property bool streamAlive: streamProc.running

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

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: root.scheduleRefresh()
        }
    }

    // Coalesce bursts of events into a single refresh.
    Timer {
        id: debounce
        interval: 50
        onTriggered: root.refresh()
    }

    // Fallback for when the event stream is unavailable.
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!root.streamAlive)
                root.refresh()
        }
    }
}
