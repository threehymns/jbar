//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import Quickshell
import Quickshell.Io
import "./bar/"
import "./bar/adapters/"

// jbar — a Quickshell port of the waybar "mechabar" config.
//
// The bar is created once per output, so a second monitor gets its own bar
// just like the waybar "output" option does.

ShellRoot {
    // The values of the settings of the bar are stored in the config file
    // of the shell, it reads them when the bar starts and writes them back
    // when they change.
    ConfigFile {}

    // The settings are a window of their own, not a popup of a bar. It is
    // kept hidden until the IPC handler opens it, so the settings can be
    // reached while every bar is hidden by the outputs setting.
    SettingsWindow {
        id: settingsWindow
    }

    // `qs ipc call jbar settings` opens the settings. The handler lives on
    // the shell root, not in a bar: it must work when no bar is visible.
    IpcHandler {
        target: "jbar"

        function settings(): void { settingsWindow.open() }
        function closeSettings(): void { settingsWindow.close() }
        function toggleSettings(): void { settingsWindow.toggle() }
    }

    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
