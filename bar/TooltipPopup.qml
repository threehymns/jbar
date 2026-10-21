import QtQuick

// TooltipPopup — the tooltip of a module.
//
// The popup shows the tip of the module the pointer is over. The bar owns
// one tooltip per output and the modules ask the bar for it, so the
// tooltip of one output never shows up on another.
Popup {
    // The text of the tip.
    property string tipText: ""

    content: Label {
        id: tipLabel
        anchors.centerIn: parent
        text: tipText
        color: Theme.mainFg
        pixelSize: 13
    }

    implicitWidth: tipLabel.implicitWidth + 20
    implicitHeight: tipLabel.implicitHeight + 14
}
