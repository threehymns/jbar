import QtQuick

// DrawerGroup — a group of two modules, the second one hidden.
//
// The waybar "group" modules have a "drawer" option: the second module of
// the group is hidden and slides out to the left while the group is
// hovered. The module that is hovered keeps its place.
//
// The group owns the open state, the geometry and the animation. The
// trigger is the content of the group, the hidden module is handed to it:
//
//     DrawerGroup {
//         Module { ... }          // the trigger
//         hidden: Module { ... }  // the module that slides out
//     }
Item {
    id: root

    // How long the drawer takes to slide out.
    property int duration: 150

    // The module that slides out of the group.
    property Item hidden: null

    // The module that stays in place. It is the content of the group.
    default property alias trigger: triggerHolder.data

    // The trigger of the group.
    readonly property Item triggerModule: triggerHolder.children.length > 0
        ? triggerHolder.children[0] : null

    // The group is open while one of its modules is hovered.
    readonly property bool open: (root.triggerModule !== null && root.triggerModule.hovered)
        || (root.hidden !== null && root.hidden.hovered)

    implicitWidth: (root.triggerModule ? root.triggerModule.width : 0)
        + (root.open && root.hidden ? root.hidden.width : 0)
    implicitHeight: 31

    Behavior on implicitWidth {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.OutCubic
        }
    }

    // The trigger keeps its place: it sits at the right of the group, so the
    // group grows to the left and the trigger does not move.
    Item {
        id: triggerHolder
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.triggerModule ? root.triggerModule.width : 0
        height: 31
    }

    // The drawer the hidden module slides out of.
    Item {
        id: drawer
        x: 0
        width: root.open && root.hidden ? root.hidden.width : 0
        height: 31
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.OutCubic
            }
        }
    }

    // The hidden module lives in the drawer, so that the drawer clips it
    // while the group is closed.
    function attach() {
        if (!root.hidden || !drawer)
            return
        if (root.hidden.parent !== drawer) {
            root.hidden.parent = drawer
            root.hidden.x = 0
            root.hidden.y = 0
        }
        // the hidden module must not swallow the events of the modules
        // next to it while it is closed
        root.hidden.visible = root.open
        root.hidden.interactive = root.open
    }

    onHiddenChanged: attach()
    onOpenChanged: attach()
    Component.onCompleted: attach()
}
