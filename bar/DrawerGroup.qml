import QtQuick

// DrawerGroup — a group of modules, the hidden ones hidden.
//
// The waybar "group" modules have a "drawer" option: the modules of the
// group are hidden and slide out to the left while the group is hovered.
// The module that is hovered keeps its place.
//
// The group owns the open state, the geometry and the animation. The
// trigger is the content of the group, the modules that slide out are
// handed to it:
//
//     DrawerGroup {
//         Module { ... }               // the trigger
//         hidden: [ Module { ... } ]   // the modules that slide out
//     }
//
// A group with the overlay slides its modules out over the modules next to
// it, so they do not move when the group opens. Such a group can slide
// modules out to the right of the trigger as well:
//
//     DrawerGroup {
//         overlay: true
//         Module { ... }                    // the trigger
//         hidden: [ Module { ... } ]        // slide out to the left
//         hiddenRight: [ Module { ... } ]   // slide out to the right
//     }
Item {
    id: root

    // How long the drawer takes to slide out.
    property int duration: 150

    // The modules that slide out to the left of the trigger.
    property list<Module> hidden: []

    // The modules that slide out to the right of the trigger. They need a
    // group with the overlay, they slide out over the modules next to the
    // group.
    property list<Module> hiddenRight: []

    // Keeps the group open while the pointer is elsewhere. A popup of the
    // group uses it, so the group does not close while the popup is open.
    property bool keepOpen: false

    // Whether the drawer slides out over the modules next to the group
    // instead of taking their place. A group in the middle of the bar uses
    // it, so the modules around it do not move when it opens.
    property bool overlay: false

    // The module that stays in place. It is the content of the group.
    default property alias trigger: triggerHolder.data

    // The trigger of the group.
    readonly property Item triggerModule: triggerHolder.children.length > 0
        ? triggerHolder.children[0] : null

    // The width of the trigger of the group.
    readonly property real triggerWidth: root.triggerModule
        ? root.triggerModule.width : 0

    // The width the drawer to the left takes.
    readonly property real drawerWidth: root.widthOf(root.hidden)

    // The width the drawer to the right takes.
    readonly property real rightWidth: root.widthOf(root.hiddenRight)

    // The pointer is over one of the modules that slide out.
    readonly property bool hiddenHovered: root.hoveredIn(root.hidden)
        || root.hoveredIn(root.hiddenRight)

    // The group is open while one of its modules is hovered.
    readonly property bool open: root.keepOpen
        || (root.triggerModule !== null && root.triggerModule.hovered)
        || root.hiddenHovered

    // The drawer is drawn over the modules next to the group.
    z: root.overlay ? 1 : 0

    implicitWidth: (root.triggerModule ? root.triggerModule.width : 0)
        + (!root.overlay && root.open ? root.drawerWidth : 0)
    implicitHeight: 31

    Behavior on implicitWidth {
        Motion { time: root.duration }
    }

    // The width a list of modules takes.
    function widthOf(modules) {
        let width = 0
        for (let i = 0; i < modules.length; i++)
            width += modules[i].width
        return width
    }

    // Whether the pointer is over one of the modules.
    function hoveredIn(modules) {
        for (let i = 0; i < modules.length; i++) {
            if (modules[i].hovered === true)
                return true
        }
        return false
    }

    // The drawer the modules slide out of. It is a window onto the modules:
    // it is as wide as the space they take and it clips them while the
    // group is closed. It is drawn below the trigger, so a drawer slides
    // out from under it.
    Item {
        id: drawer
        x: root.open && root.overlay ? -root.drawerWidth : 0
        width: root.open ? root.drawerWidth : 0
        height: 31
        clip: true

        Behavior on x {
            Motion { time: root.duration }
        }

        Behavior on width {
            Motion { time: root.duration }
        }

        // The modules that slide out to the left of the trigger.
        Row {
            id: drawerRow
            height: 31
        }
    }

    // The drawer the modules slide out of to the right of the trigger.
    Item {
        id: drawerRight
        x: root.open && root.overlay ? root.triggerWidth : 0
        width: root.open && root.overlay ? root.rightWidth : 0
        height: 31
        clip: true

        Behavior on x {
            Motion { time: root.duration }
        }

        Behavior on width {
            Motion { time: root.duration }
        }

        // The modules that slide out to the right of the trigger.
        Row {
            id: drawerRightRow
            height: 31
        }
    }

    // The trigger keeps its place: it sits at the right of the group, so the
    // group grows to the left and the trigger does not move.
    Item {
        id: triggerHolder
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.triggerWidth
        height: 31
    }

    // The hidden modules live in the drawer, so that the drawer clips them
    // while the group is closed.
    function attach() {
        for (let i = 0; i < root.hidden.length; i++)
            root.attachModule(root.hidden[i], drawerRow)
        for (let i = 0; i < root.hiddenRight.length; i++)
            root.attachModule(root.hiddenRight[i], drawerRightRow)
    }

    // Put a module into a drawer.
    function attachModule(module, holder) {
        if (module.parent !== holder)
            module.parent = holder
        // the hidden modules must not swallow the events of the modules
        // next to them while the group is closed
        module.visible = root.open || root.overlay
        module.interactive = root.open
    }

    onHiddenChanged: attach()
    onHiddenRightChanged: attach()
    onOpenChanged: attach()
    Component.onCompleted: attach()
}
