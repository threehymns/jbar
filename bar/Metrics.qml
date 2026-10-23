pragma Singleton
import QtQuick
import "metrics/"

// Metrics — the system metrics of the bar, polled once per shell.
//
// shell.qml creates one Bar per output, so a metric that a module owned
// would be read once per output as well. This singleton is created once per
// engine, outside the per-screen Variants: every bar reads the same values,
// and adding or removing an output cannot leave a poller behind.
//
// The intervals and the thresholds are bound to Settings: a change in the
// settings page reaches the one poller that reads the system.
//
// The pollers themselves live in MetricsPollers.qml and are loaded at
// runtime. They import Quickshell.Io, which qmltestrunner cannot load; this
// file has to stay loadable by the tests, because it is registered in
// bar/qmldir and the tests import the plain metric types from there.
QtObject {

    // ── the processor ──────────────────────────────────────────────────────

    readonly property CpuMetric cpu: CpuMetric {
        warningThreshold: Settings.cpuWarning
        criticalThreshold: Settings.cpuCritical
        interval: Settings.cpuInterval * 1000
    }

    // ── the memory ─────────────────────────────────────────────────────────

    readonly property MemoryMetric memory: MemoryMetric {
        warningThreshold: Settings.memoryWarning
        criticalThreshold: Settings.memoryCritical
        interval: Settings.memoryInterval * 1000
    }

    // ── the temperature ────────────────────────────────────────────────────

    readonly property TemperatureMetric temperature: TemperatureMetric {
        unit: Settings.temperatureUnit
        thermalZone: Settings.thermalZone
        criticalCelsius: Settings.temperatureCritical
        interval: Settings.temperatureInterval * 1000
    }

    // ── the network ────────────────────────────────────────────────────────

    readonly property NetworkMetric network: NetworkMetric {
        interval: Settings.networkInterval * 1000
    }

    // ── the pending updates ────────────────────────────────────────────────

    readonly property UpdatesMetric updates: UpdatesMetric {
        checkCommand: Settings.updatesCheckCommand
        interval: Settings.updatesInterval * 60000
    }

    // ── the brightness ─────────────────────────────────────────────────────

    readonly property BacklightMetric backlight: BacklightMetric {
        interval: Settings.backlightInterval * 1000
    }

    // ── the polls ──────────────────────────────────────────────────────────

    // The object that owns one Poller per metric. It is loaded at runtime,
    // so this file stays free of Quickshell.Io, and the polls start once for
    // the whole shell.
    readonly property Loader pollers: Loader {
        source: "MetricsPollers.qml"
    }
}
