import QtQuick

// Motion — an animation of the bar.
//
// The bar animates the changes of its state: a drawer slides out, a popup
// grows out of the bar. Everything animates the same way, so an animation
// only has to say how long it takes:
//
//     Behavior on x { Motion {} }
//     Behavior on width { Motion { time: 300 } }
//
// A user can ask for reduced motion. An animation then takes no time at all
// and the bar changes its state at once, so the duration of an animation is
// never set by hand.
NumberAnimation {
    id: root

    // How long the animation takes, in milliseconds.
    property int time: 150

    duration: Settings.motion(root.time)
    easing.type: Easing.OutCubic
}
