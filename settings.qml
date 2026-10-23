//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQml
import Quickshell
import "./bar/"
import "./bar/adapters/"

// settings.qml — the settings without the bar.
//
// Run this entry point when the bar is not running:
//
//     qs -p settings.qml
//
// The window reads and writes the same config file as the bar, so a value
// changed here is picked up by the bar when it starts. Closing the window
// ends this Quickshell instance; the bar is not affected.
ShellRoot {
    ConfigFile {}

    SettingsWindow {
        id: settingsWindow

        // The window is hidden when it is built. Quit only when the window
        // that was opened is closed again, not on the initial hidden state.
        property bool started: false

        Component.onCompleted: {
            started = true
            settingsWindow.open()
        }

        onVisibleChanged: {
            if (started && !visible)
                Qt.quit()
        }
    }
}
