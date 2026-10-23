//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import Quickshell
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

    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
