pragma Singleton
import QtQuick

// BarOutputs — the outputs the bar is shown on.
//
// The "outputs" setting is a list of output names, the waybar "output"
// option. An empty list shows the bar on every output. A list that matches
// none of the connected screens also shows the bar on every output: a bar
// that renders nothing would take the settings page away, so the user could
// not correct the list.
//
// The decision is a plain function without a bar, so the tests can cover it.
QtObject {
    id: root

    // Split a configured list into the names of the outputs.
    function parse(text) {
        if (!text)
            return []
        return String(text).split(",")
            .map(name => name.trim())
            .filter(name => name !== "")
    }

    // The plan of the outputs for the connected screens:
    //
    //   filter   the outputs the bar is shown on, empty shows every output
    //   showAll  the bar is shown on every output
    //   fallback the configured list matched no connected screen
    //   unmatched the configured names that are not connected
    function plan(text, connected) {
        const configured = root.parse(text)
        const screens = connected || []
        const unmatched = configured.filter(name => screens.indexOf(name) === -1)
        if (configured.length === 0)
            return { filter: [], unmatched: [], fallback: false, showAll: true }
        if (unmatched.length === configured.length)
            return { filter: [], unmatched: configured, fallback: true, showAll: true }
        return { filter: configured, unmatched: unmatched, fallback: false, showAll: false }
    }

    // Whether the bar is shown on an output.
    function shows(plan, outputName) {
        if (!plan || plan.showAll)
            return true
        return plan.filter.indexOf(outputName) !== -1
    }

    // The warning of a fallback, empty when there is nothing to warn about.
    function warning(plan) {
        if (!plan || !plan.fallback)
            return ""
        return "the configured outputs match no connected screen: "
            + plan.unmatched.join(", ") + " - showing the bar on every output"
    }

    // The warning that was already printed, so a bar on every output does
    // not repeat the same warning.
    property string warned: ""

    // Warn once about a fallback.
    function warn(plan) {
        const message = root.warning(plan)
        if (message === "") {
            root.warned = ""
            return
        }
        if (message === root.warned)
            return
        root.warned = message
        console.warn("[bar]", message)
    }
}
