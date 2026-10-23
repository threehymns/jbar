import QtQuick
import "../"
import "../adapters/"
import "../metrics/"

// Updates — port of the waybar "custom/update" module.
//
// The metric of the updates knows the command and the parsing, the module
// only draws it.
Module {
    id: root

    bg: Theme.tray
    // #custom-update { padding: 0 8px 0 2px; }
    padLeft: Theme.px(2)
    padRight: Theme.px(8)
    minChars: 1
    dimOnHover: true

    readonly property UpdatesMetric metric: UpdatesMetric {
        checkCommand: Settings.updatesCheckCommand
        interval: Settings.updatesInterval * 60000
    }

    // The poll that fills the metric.
    readonly property Poller poller: Poller { metric: root.metric }

    onClicked: root.run(Settings.updatesCommand)

    iconText: Icons.update
    labelText: root.metric.value + ""
}
