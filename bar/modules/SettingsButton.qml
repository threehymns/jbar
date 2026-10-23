import QtQuick
import "../"

// SettingsButton — the button that opens the settings of the bar.
//
// The button is the hidden module of the group of the logo of the
// distribution, it slides out of it. It opens the settings of the bar in a
// popup below itself.
Module {
    id: root

    bg: Theme.mainBg
    fg: Theme.mainFg
    padLeft: 10
    padRight: 10
    minChars: 2
    dimOnHover: true

    tip: "Settings"

    onClicked: root.togglePopup()

    iconText: Icons.settings

    popup: Popup {
        contentWidth: 400
        contentHeight: 520

        SettingsPage {
            anchors.fill: parent
        }
    }
}
