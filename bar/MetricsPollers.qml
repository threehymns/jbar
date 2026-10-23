import QtQuick
import "adapters/"

// MetricsPollers — the pollers of the Metrics singleton.
//
// Metrics loads this object at runtime. It is a separate file because it
// imports Quickshell.Io through Poller, and qmltestrunner cannot load the
// Quickshell.Io plugin: keeping the import out of Metrics.qml lets the
// tests keep importing the plain metric types from bar/qmldir.
//
// One poller per metric, no matter how many bars there are.
QtObject {

    readonly property Poller cpuPoller: Poller {
        metric: Metrics.cpu
    }

    readonly property Poller memoryPoller: Poller {
        metric: Metrics.memory
    }

    readonly property Poller temperaturePoller: Poller {
        metric: Metrics.temperature
    }

    readonly property Poller networkPoller: Poller {
        metric: Metrics.network
    }

    readonly property Poller updatesPoller: Poller {
        metric: Metrics.updates
    }

    readonly property Poller backlightPoller: Poller {
        metric: Metrics.backlight
    }
}
