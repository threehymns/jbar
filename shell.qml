//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import Quickshell
import "./bar/"

// jbar — a Quickshell port of the waybar "mechabar" config.
//
// The bar is created once per output, so a second monitor gets its own bar
// just like the waybar "output" option does.

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
