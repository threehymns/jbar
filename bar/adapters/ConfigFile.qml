import QtQuick
import QtQml
import Quickshell
import Quickshell.Io
import "../"

// ConfigFile — the config file of the bar.
//
// The values of the settings are stored in the "config.json" of the config
// folder of the user, not in the folder of the shell. A checkout of the bar
// therefore never holds the settings of a machine. The file is read when the
// bar starts and written when a value changes. A file that was edited by hand
// is picked up while the bar runs.
//
// It is the adapter that keeps the settings of the bar and their file in
// sync, the settings themselves know nothing of a file.
QtObject {
    id: root

    // The folder the config file lives in. The folder is under the config
    // folder of the user, so every checkout of the bar shares the settings.
    readonly property string dir: {
        const base = Quickshell.env("XDG_CONFIG_HOME")
            || (Quickshell.env("HOME") || "") + "/.config"
        return base + "/quickshell/jbar"
    }

    // The file the values are stored in.
    readonly property string path: root.dir + "/config.json"

    // The file the values are read from and written to. A plain object has
    // no default property for children, so the file is held by a property.
    property FileView file: FileView {
        id: view
        path: root.path
        preload: true
        watchChanges: true
        printErrors: false

        onLoaded: root.load(view.text())
        onLoadFailed: error => console.log("[settings] no config file at", root.path,
            "- the defaults are used")
    }

    // The values changed, they are written to the file.
    property Connections connection: Connections {
        target: Settings
        function onChanged() {
            root.save()
        }
    }

    // Read the values from the file.
    function load(text) {
        let data = null
        try {
            data = JSON.parse(text)
        } catch (err) {
            console.warn("[settings] the config file is not valid json:", err)
            return
        }
        if (!data || typeof data !== "object")
            return
        Settings.load(data)
    }

    // Write the values to the file.
    function save() {
        root.file.setText(JSON.stringify(Settings.stored, null, 2) + "\n")
    }
}
