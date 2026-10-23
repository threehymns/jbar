pragma Singleton
import QtQuick
import QtQml

// Icons — the Nerd Font glyphs used by the waybar config. The codepoints are
// unchanged from the original modules, so the bar renders exactly the same
// glyphs. They are written literally, as \u escapes are error prone for the
// private use area.
QtObject {
    // workspaces
    readonly property string workspaceActive: "" // nf-md-circle_slash
    readonly property string workspaceDefault: "" // nf-md-circle_outline

    // temperature
    readonly property string tempCritical: "󰀦" // critical
    // temperature scale, cold -> hot (waybar picks one of three icons)
    readonly property var temperature: ["󱃃", "󰔏", "󱃂"]

    // memory / cpu
    readonly property string memory: "󰘚" // memory chip
    readonly property string memoryWarning: "󰀧" // warning

    // distro / clock / updates
    readonly property string cpu: "󰍛" // cpu chip
    readonly property string distro: "󰣇" // linux
    readonly property string calendar: "󰸗" // calendar

    // network / bluetooth
    readonly property string update: "󰚰" // package update
    readonly property string wifi: "󰤨" // wifi
    readonly property string ethernet: "󰈀" // ethernet
    readonly property string networkDown: "󰤮" // wifi off
    readonly property string bluetooth: "󰂯" // bluetooth
    readonly property string bluetoothDisabled: "󰂲" // bluetooth off
    readonly property string bluetoothConnected: "󰂱" // bluetooth connected

    // mpris
    readonly property string mpris: "󰐊" // play
    readonly property string mprisPaused: "󰏤" // pause

    // volume
    readonly property string volumeLow: "󰕿" // volume low
    readonly property string volumeHigh: "󰖀" // volume high
    readonly property string volumeMute: "󰝟" // volume muted
    readonly property string volumeOff: "󰕾" // volume off
    readonly property string mic: "󰍬" // microphone
    readonly property string micMuted: "󰍭" // microphone muted

    // backlight (7 brightness steps, low -> high)
    readonly property var backlight: ["󰃚", "󰃛", "󰃜", "󰃝", "󰃞", "󰃟", "󰃠"]

    // battery (10 charge steps, empty -> full)
    readonly property var battery: ["󰂎", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property string batteryCharging: "󰉁" // charging

    // settings
    readonly property string settings: "󰒓" // nf-md-cog

    // idle inhibitor / power
    readonly property string idleActive: "󱤱" // idle active
    readonly property string idleInactive: "󰾪" // idle inactive
    readonly property string power: "󰤄" // power / night
}
