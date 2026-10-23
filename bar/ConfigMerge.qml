pragma Singleton
import QtQuick

// ConfigMerge — the pure part of the config file adapter.
//
// The adapter reads the file, merges it with the values of the settings and
// writes the result back. The merge is the part that decides whether a value
// on disk survives a change in the page, so it is a plain object without any
// I/O: the adapter and the tests use the same code.
QtObject {
    id: root

    // Read the values of a config file. An empty file has no values, a file
    // that is not a JSON object is an error and leaves the settings alone.
    function read(text) {
        if (text === undefined || text === null || String(text).trim() === "")
            return { values: {}, error: "" }
        let data = null
        try {
            data = JSON.parse(text)
        } catch (err) {
            return { values: {}, error: String(err) }
        }
        if (!data || typeof data !== "object" || Array.isArray(data))
            return { values: {}, error: "the config file does not hold an object" }
        return { values: data, error: "" }
    }

    // The values to write. The file as it is on disk is the base, and only
    // the keys the user changed in memory are applied over it. A value that
    // was edited on disk since the last read therefore survives a change
    // that has nothing to do with it.
    function merge(disk, memory, keys) {
        const merged = Object.assign({}, disk || {})
        if (!memory || !keys)
            return merged
        for (let i = 0; i < keys.length; i++) {
            const key = keys[i]
            if (memory[key] !== undefined)
                merged[key] = memory[key]
        }
        return merged
    }

    // The text of a config file.
    function write(values) {
        return JSON.stringify(values || {}, null, 2) + "\n"
    }

    // The name of an error of the file view. The values are the ones of
    // Quickshell's FileViewError enum.
    function errorName(error) {
        if (typeof error === "string")
            return error
        switch (error) {
        case 0: return "Success"
        case 2: return "FileNotFound"
        case 3: return "PermissionDenied"
        case 4: return "NotAFile"
        default: return "Unknown"
        }
    }
}
