import QtQuick
import QtQuick.Controls

// SettingsPage — the page of the settings of the bar.
//
// The page shows every setting of the bar, grouped in the sections of the
// settings. The rows are built from the sections of the settings, so a
// setting that is added to the settings shows up here on its own.
Item {
    id: page

    // The space around the settings.
    property int padding: 12

    ScrollView {
        id: scroll
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        Column {
            id: sections
            x: page.padding
            y: page.padding
            width: scroll.availableWidth - 2 * page.padding
            spacing: 12

            Repeater {
                model: Settings.sections

                delegate: Column {
                    id: section
                    required property var modelData

                    width: sections.width
                    spacing: 4

                    // The name of the section.
                    Text {
                        text: section.modelData.title
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }

                    // The settings of the section.
                    Repeater {
                        model: section.modelData.entries

                        delegate: SettingRow {
                            required property var modelData

                            width: section.width
                            key: modelData.key
                            label: modelData.label
                            type: modelData.type
                            min: modelData.min !== undefined ? modelData.min : 0
                            max: modelData.max !== undefined ? modelData.max : 100
                            unit: modelData.unit !== undefined ? modelData.unit : ""
                            choices: modelData.choices !== undefined ? modelData.choices : []
                            labels: modelData.labels !== undefined ? modelData.labels : []
                            hint: modelData.hint !== undefined ? modelData.hint : ""
                        }
                    }
                }
            }

            // The space below the last section.
            Item {
                width: 1
                height: page.padding
            }
        }
    }
}
