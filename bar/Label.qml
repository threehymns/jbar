import QtQuick

// Label — a text run with the typography of the bar.
//
// The bar font (Geist) and the Nerd Font of the icons are decided here, so
// that no module spells out a font family again. The colour is left to the
// caller, because the modules dim their labels in different ways.
Text {
    id: root

    // Draw the text in the Nerd Font instead of the bar font.
    property bool glyph: false

    // The size of the text in pixels.
    property int pixelSize: Theme.fontSize

    // Elide the text after this many characters. 0 keeps the whole text.
    property int maxChars: 0

    font.family: root.glyph ? Theme.iconFont : Theme.fontFamily
    font.pixelSize: root.pixelSize
    elide: root.maxChars > 0 ? Text.ElideRight : Text.ElideNone
    width: root.maxChars > 0
        ? Math.min(implicitWidth, root.maxChars * Theme.charWidth)
        : implicitWidth
}
