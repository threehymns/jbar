pragma Singleton
import QtQuick
import QtQml

// Tooltip — controller for the bar's single tooltip popup.
//
// The popup itself lives in Bar.qml (a window cannot live inside a scope);
// this singleton is the API the modules talk to:
//
//     Tooltip.show(item, "some text")
//     Tooltip.hide()
QtObject {
    id: ctrl

    // The PopupWindow, assigned by Bar.qml.
    property var popup: null
    // The bar window, used as the coordinate space of the popup.
    property var host: null

    function show(item, text) {
        if (!popup || !host || !item)
            return
        popup.target = item
        popup.tipText = text
        popup.visible = true
    }

    function hide() {
        if (popup)
            popup.visible = false
    }
}
