import QtQuick

// SettingCommand — a command line of a setting.
//
// The field edits the line, the text below it shows the exact argument
// vector the bar will run. Seeing the split is the point: a quote that
// starts inside an argument stays with that argument, while shell syntax
// is refused and its error is shown instead.
//
// Test runs exactly that vector, in the page, and reports what happened.
// The runner is loaded lazily: the page and its tests do not import
// Quickshell.Io until a test is actually started. A destructive command
// needs a second click, shown as "Run anyway", which expires after a few
// seconds; the page never runs one on a single click.
Item {
    id: root

    // The command line of the setting.
    property string value: ""

    // The hint of the field, shown while it is empty.
    property string hint: ""

    // Whether a test of this command needs a confirmation.
    property bool destructive: false

    // How long a test may run, in milliseconds.
    property int timeoutMs: 10000

    // The command line was edited.
    signal edited(string text)

    // The reason the line cannot run, empty when it can.
    readonly property string error: Settings.commandError(root.value)

    // The arguments that will be passed to the process.
    readonly property var args: Settings.command(root.value)

    // The vector the user can compare with what they wrote. JSON quotes
    // every argument, so a space or an empty argument is visible.
    readonly property string preview: root.error !== ""
        ? root.error : "runs " + JSON.stringify(root.args)

    // Whether the Test button can do something. While a test runs it is
    // the Cancel button, so it stays enabled.
    readonly property bool canTest: (root.error === "" && root.args.length > 0)
        || testState.running

    // The colour of the result line.
    readonly property color resultColor: {
        if (testState.status === "succeeded")
            return Theme.green
        if (testState.status === "failed" || testState.status === "timed out")
            return Theme.critical
        if (testState.status === "running")
            return Theme.accent
        return Theme.fg4
    }

    implicitHeight: content.implicitHeight
    implicitWidth: 200

    // The state of the test, without any I/O. It is separate from the
    // runner so the tests can drive it without Quickshell.
    CommandPreview {
        id: testState
        line: root.value
        destructive: root.destructive
        timeoutMs: root.timeoutMs
        onRunRequested: args => root.startTest(args)
        onCancelRequested: {
            root.pendingArgs = []
            if (root.runnerItem)
                root.runnerItem.cancel()
        }
    }

    // The arguments of a run that was requested before the lazy runner
    // finished loading, and the loaded runner itself.
    property var pendingArgs: []
    property var runnerItem: null

    // Quickshell.Io is only imported by CommandRunner.qml, and this loader
    // is inactive until the first Test click, so qmltestrunner never loads
    // the runtime runner through this page.
    Loader {
        id: runner
        active: false
        source: "CommandRunner.qml"

        onLoaded: {
            root.runnerItem = item
            if (!root.runnerItem)
                return
            root.runnerItem.timeoutMs = root.timeoutMs
            if (root.pendingArgs.length > 0 && testState.running) {
                const args = root.pendingArgs
                root.pendingArgs = []
                root.runnerItem.start(args)
            } else {
                root.pendingArgs = []
            }
        }

        onStatusChanged: {
            if (runner.status === Loader.Error)
                testState.fail("the test runner could not be loaded")
        }
    }

    Connections {
        target: root.runnerItem

        function onFinished(exitCode, output, error) {
            testState.accept(exitCode, output, error)
        }

        function onTimedOut() {
            testState.timeout()
        }

        function onFailed(message) {
            testState.fail(message)
        }
    }

    // Start the argv of the test, loading the runner on the first click.
    function startTest(args) {
        if (root.runnerItem) {
            root.runnerItem.start(args)
            return
        }
        root.pendingArgs = args
        runner.active = true
    }

    // The Test action: run, confirm or cancel, depending on the state.
    function test() {
        if (testState.running) {
            testState.cancel()
            return
        }
        testState.run()
    }

    Column {
        id: content
        width: parent.width
        spacing: 2

        // The field of the command.
        Item {
            width: parent.width
            height: 26

            SettingText {
                anchors.fill: parent
                value: root.value
                hint: root.hint
                onEdited: text => root.edited(text)
            }
        }

        // The argv preview. It has the full width of the row so the error
        // of a shell line is readable instead of being cut next to a
        // button.
        Text {
            width: parent.width
            text: root.preview
            color: root.error !== "" ? Theme.critical : Theme.fg3
            font.family: Theme.fontFamily
            font.pixelSize: 10
            elide: Text.ElideRight
        }

        // The hint and the Test action. The command rows are the one place
        // where a shell would change the meaning of the line, so say that
        // they do not use one.
        Item {
            width: parent.width
            height: 22

            Text {
                anchors.left: parent.left
                anchors.right: testButton.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: "runs directly, no shell"
                color: Theme.bg4
                font.family: Theme.fontFamily
                font.pixelSize: 9
                elide: Text.ElideRight
            }

            Rectangle {
                id: testButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 72
                height: 22
                radius: 6
                color: testState.armed
                    ? Theme.bg3
                    : (testMouse.containsMouse ? Theme.bg2 : Theme.bg1)
                border.width: 1
                border.color: testState.armed ? Theme.critical : Theme.bg3
                opacity: root.canTest ? 1 : 0.45

                Text {
                    anchors.centerIn: parent
                    text: testState.running ? "Cancel"
                        : (testState.armed ? "Run anyway" : "Test")
                    color: testState.armed ? Theme.critical : Theme.mainFg
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }

                MouseArea {
                    id: testMouse
                    anchors.fill: parent
                    enabled: root.canTest
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.test()
                }
            }
        }

        // The result of the test: state, exit code and a short output.
        Text {
            width: parent.width
            visible: testState.status !== "idle"
            text: testState.statusText
            color: root.resultColor
            font.family: Theme.fontFamily
            font.pixelSize: 10
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: testState.outputSummary !== ""
            text: testState.outputSummary
            color: Theme.fg4
            font.family: Theme.fontFamily
            font.pixelSize: 9
            wrapMode: Text.Wrap
            maximumLineCount: 4
            elide: Text.ElideRight
        }
    }
}
