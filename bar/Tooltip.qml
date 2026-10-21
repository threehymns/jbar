pragma Singleton
import QtQuick
import QtQml
import QtQuick.Window

// Tooltip — the tooltip of the bar.
//
// The popup itself lives in the bar, a popup cannot live in a scope. The
// bar registers its popup here, and the modules ask for the tooltip of the
// window they are in, so that every output gets its own.
QtObject {
    id: ctrl

    // The tooltip popups, by the window they belong to.
    property var popups: ({})

    // Called by the bar with the popup of its own window.
    function register(window, popup) {
        ctrl.popups[window] = popup
    }

    function unregister(window) {
        delete ctrl.popups[window]
    }

    // The tooltip popup of the window the item is in.
    function popupFor(item) {
        if (!item)
            return null
        const window = item.Window.window
        if (!window)
            return null
        return ctrl.popups[window] || null
    }

    function show(item, text) {
        const popup = ctrl.popupFor(item)
        if (!popup)
            return
        popup.target = item
        popup.tipText = text
        popup.visible = true
    }

    function hide(item) {
        const popup = ctrl.popupFor(item)
        if (popup)
            popup.visible = false
    }
}
