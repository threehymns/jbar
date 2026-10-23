import QtQuick

// LazyContent — content that is built when it is first needed and kept.
//
// A module owns its popup, so a popup that fills itself with content while
// the bar starts builds that content for every output even though it may
// never be opened. The calendar's year view is more than a thousand text
// objects and the settings page more than thirty rows, so the content of a
// popup is held by this item and only created when the module calls
// activate().
//
// The content is kept after the first activation: a popup is opened and
// closed many times, and building a calendar or a settings page again on
// every open would make the first frames of the animation late.
Item {
    id: root

    // The content, built on the first activation.
    property Component content: null

    // Whether the content has been built. It stays true: the content is
    // retained after the first open.
    readonly property bool loaded: loader.item !== null

    // The item of the content, or null before the first activation.
    readonly property var item: loader.item

    // Build the content. Calling it again keeps the content that exists.
    function activate() {
        loader.active = true
    }

    Loader {
        id: loader
        anchors.fill: parent
        active: false
        sourceComponent: root.content
    }
}
