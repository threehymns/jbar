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
// The file is the source of truth: a save merges only the keys the user
// changed in the page over the values that were last read from disk, so a
// hand edit of an unrelated value is not overwritten. The adapter is the only
// part that knows the file, the settings themselves know nothing of it.
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

    // The values that were last read from or written to the file. It is the
    // base a save merges the changed keys over.
    property var disk: ({})

    // The keys the page changed since they were last written successfully.
    // A change on disk does not lose them and a failed write keeps them, so
    // a later save can still persist them.
    property var dirty: ({})

    // A write is in flight. The next change waits for it, so the text of the
    // file and the values the adapter believes are on disk stay in order.
    property bool writing: false

    // A change arrived while a write or a read was in flight.
    property bool pending: false

    // A change of the file is being read back.
    property bool reloading: false

    // The file was read once, so a save has a base to merge over.
    property bool ready: false

    // The values and the keys of the write that is in flight, used when it
    // succeeds.
    property var lastValues: ({})
    property var lastKeys: []
    property string lastText: ""

    // The text of the writes we made ourselves. The file watcher reports
    // them as a change of the file, they must not be read back as an edit
    // by hand.
    property var ownWrites: []

    // The file the values are read from and written to. A plain object has
    // no default property for children, so the file is held by a property.
    property FileView file: FileView {
        id: view
        path: root.path
        preload: true
        watchChanges: true
        printErrors: false

        onLoaded: root.load(view.text())
        onLoadFailed: error => {
            root.reloading = false
            root.ready = true
            console.log("[settings] could not read", root.path,
                "(" + ConfigMerge.errorName(error) + ") - the defaults are used")
            if (root.pending) {
                root.pending = false
                root.save()
            }
        }
        // the view does not read the file again on its own, so a change on
        // disk is loaded before the settings are updated
        onFileChanged: root.fileChanged()
        onSaved: root.saved()
        onSaveFailed: error => root.failed(error)
    }

    // The values changed, they are written to the file.
    property Connections connection: Connections {
        target: Settings
        function onChanged(key) {
            root.save(key)
        }
    }

    // A change of the file was reported. The file is read back, a write that
    // is in flight updates the values itself.
    function fileChanged() {
        if (root.writing)
            return
        root.reloading = true
        view.reload()
    }

    // The file was read, when the bar starts or after a change on disk.
    function load(text) {
        root.reloading = false
        root.ready = true
        if (root.ownWrite(text)) {
            if (root.pending) {
                root.pending = false
                root.save()
            }
            return
        }
        const result = ConfigMerge.read(text)
        if (result.error !== "") {
            console.warn("[settings] the config file is not valid json:", result.error)
            return
        }
        root.disk = result.values
        root.apply(result.values)
        if (root.pending) {
            root.pending = false
            root.save()
        }
    }

    // Merge the values of the file into the settings without losing a dirty
    // key, then hand the result to the settings.
    function apply(values) {
        Settings.load(ConfigMerge.merge(values, Settings.stored,
            Object.keys(root.dirty)))
    }

    // Write the values to the file. Only the dirty keys are taken from the
    // settings, everything else comes from the file as it was last read.
    function save(key) {
        if (key !== undefined && key !== "")
            root.dirty[key] = true
        if (!root.ready || root.writing || root.reloading) {
            root.pending = true
            return
        }
        const keys = Object.keys(root.dirty)
        if (keys.length === 0)
            return
        const values = ConfigMerge.merge(root.disk, Settings.stored, keys)
        const text = ConfigMerge.write(values)
        // the file view does not report a save when the text is unchanged,
        // and the values may already be on disk in another formatting
        if (text === view.text() || text === ConfigMerge.write(root.disk)) {
            root.commit(values, keys)
            if (root.pending) {
                root.pending = false
                root.save()
            }
            return
        }
        root.lastValues = values
        root.lastKeys = keys
        root.lastText = text
        root.writing = true
        root.pending = false
        root.ownWrites.push(text)
        // the file watcher does not report every write, so the list cannot
        // grow without a bound
        if (root.ownWrites.length > 8)
            root.ownWrites.shift()
        root.file.setText(text)
    }

    // Whether a change of the file is the text of one of our own writes.
    function ownWrite(text) {
        const index = root.ownWrites.indexOf(text)
        if (index === -1)
            return false
        root.ownWrites.splice(index, 1)
        return true
    }

    // The values are on disk now, so the keys that still hold the written
    // value are no longer dirty. A key the user changed again while the
    // write was in flight stays dirty.
    function commit(values, keys) {
        Settings.saveError = ""
        root.disk = values
        for (let i = 0; i < keys.length; i++) {
            const key = keys[i]
            if (Settings.stored[key] === values[key])
                delete root.dirty[key]
        }
    }

    // A write succeeded.
    function saved() {
        root.writing = false
        const values = root.lastValues
        const keys = root.lastKeys
        root.lastValues = ({})
        root.lastKeys = []
        root.lastText = ""
        root.commit(values, keys)
        if (root.pending) {
            root.pending = false
            root.save()
        }
    }

    // A write failed. The keys stay dirty, so the page can try again, and
    // the error is logged with the path and shown in the settings.
    function failed(error) {
        root.writing = false
        root.pending = false
        root.ownWrite(root.lastText)
        root.lastText = ""
        const message = "could not write " + root.path + ": "
            + ConfigMerge.errorName(error)
        console.warn("[settings]", message)
        Settings.saveError = message
    }
}
