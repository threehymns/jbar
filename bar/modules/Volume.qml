import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../"

// Volume — port of the waybar "group/pulseaudio" module.
//
// The group holds the output and the input device, both of them on the
// volume background of the waybar theme.
//
// The group uses the waybar "drawer" option: the input device is hidden
// under the output device and slides out to the left while the group is
// hovered. The output device itself keeps its place.
Item {
    id: root

    property int duration: 150

    // The group is open while one of its modules is hovered.
    readonly property bool open: output.hovered || input.hovered

    implicitWidth: output.width + (open ? input.width : 0)
    implicitHeight: 31

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.OutCubic
        }
    }

    // Output device
    Module {
        id: output
        x: root.width - output.width

        bg: Theme.volume
        minChars: 7
        stateDim: output.sinkMuted

        readonly property var sink: Pipewire.defaultAudioSink
        readonly property bool sinkMuted: sink !== null && sink.audio !== null && sink.audio.muted
        readonly property int volume: sink !== null && sink.audio !== null
            ? Math.round(sink.audio.volume * 100) : 0

        readonly property string icon: {
            if (output.sinkMuted)
                return Icons.volumeMute
            // waybar picks the icon from the "default" icon list, the volume
            // is split into three ranges
            const scale = [Icons.volumeLow, Icons.volumeHigh, Icons.volumeOff]
            const index = Math.min(scale.length - 1, Math.floor(output.volume / 33))
            return scale[index]
        }

        onClicked: root.setSinkMuted()
        onScrolled: direction => root.changeSinkVolume(direction)

        Text {
            text: output.icon
            font.family: Theme.iconFont
            font.pixelSize: Theme.fontSize
            color: output.labelColor
        }

        Text {
            text: " " + output.volume + "%"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: output.labelColor
        }
    }

    // The drawer the input device slides out of.
    Item {
        id: drawer
        x: 0
        width: root.open ? input.width : 0
        height: 31
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.OutCubic
            }
        }

        // Input device
        Module {
            id: input
            x: 0

            bg: Theme.volume
            minChars: 7
            stateDim: input.sourceMuted
            // the hidden device must not swallow the events of the modules
            // next to it
            interactive: root.open
            visible: root.open

            readonly property var source: Pipewire.defaultAudioSource
            readonly property bool sourceMuted: source !== null && source.audio !== null
                && source.audio.muted
            readonly property int volume: source !== null && source.audio !== null
                ? Math.round(source.audio.volume * 100) : 0

            onClicked: root.setSourceMuted()
            onScrolled: direction => root.changeSourceVolume(direction)

            Text {
                text: input.sourceMuted ? Icons.micMuted : Icons.mic
                font.family: Theme.iconFont
                font.pixelSize: Theme.fontSize
                color: input.labelColor
            }

            Text {
                text: " " + input.volume + "%"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                color: input.labelColor
            }
        }
    }

    // Tracking the nodes keeps their audio interface bound, without it the
    // volume of a node stays at zero.
    PwObjectTracker {
        objects: [output.sink, input.source]
    }

    function setSinkMuted() {
        if (output.sink && output.sink.audio)
            output.sink.audio.muted = !output.sink.audio.muted
    }

    function setSourceMuted() {
        if (input.source && input.source.audio)
            input.source.audio.muted = !input.source.audio.muted
    }

    function changeSinkVolume(direction) {
        if (!output.sink || !output.sink.audio)
            return
        const step = 0.02
        output.sink.audio.volume = Math.max(0,
            Math.min(1.5, output.sink.audio.volume + (direction > 0 ? step : -step)))
    }

    function changeSourceVolume(direction) {
        if (!input.source || !input.source.audio)
            return
        const step = 0.02
        input.source.audio.volume = Math.max(0,
            Math.min(1.5, input.source.audio.volume + (direction > 0 ? step : -step)))
    }
}
