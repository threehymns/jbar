import QtQuick
import "../"

// SettingsButton — the button that opens the settings of the bar.
//
// The button is the hidden module of the group of the logo of the
// distribution, it slides out of it. It opens the settings of the bar in a
// popup below itself.
//
// The page is built when the popup is opened for the first time and then
// kept: its rows are only needed while the popup is open, but rebuilding
// them on every open would make the first frames of the animation late.
Module {
    id: root

    bg: Theme.mainBg
    fg: Theme.mainFg
    padLeft: 10
    padRight: 10
    minChars: 2
    dimOnHover: true

    tip: "Settings"

    onClicked: {
        if (root.popup && root.popup.visible) {
            root.closePopup()
        } else {
            settingsContent.activate()
            root.openPopup()
        }
    }

    iconText: Icons.settings

    popup: Popup {
        contentWidth: 400
        contentHeight: 520

        LazyContent {
            id: settingsContent
            anchors.fill: parent

            content: Component {
                SettingsPage {
                }
            }
        }
    }
}
