import QtQuick

// TooltipPopup — the tooltip of a module.
//
// The popup shows the tip of the module the pointer is over. The bar owns
// one tooltip per output and the modules ask the bar for it, so the
// tooltip of one output never shows up on another.
//
// A tooltip follows the pointer and does not animate: it is there when the
// pointer arrives and it is gone when the pointer leaves.
Popup {
    // The text of the tip.
    property string tipText: ""

    // The tooltip does not own the popup layer of the bar; it is the layer
    // a module popup has to hide.
    isTooltip: true

    duration: 0

    content: Label {
        id: tipLabel
        anchors.centerIn: parent
        text: tipText
        color: Theme.mainFg
        pixelSize: 13
    }

    contentWidth: tipLabel.implicitWidth + 20
    contentHeight: tipLabel.implicitHeight + 14
}
