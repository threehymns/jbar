import QtQuick

// BatteryDevice — select the battery that powers the system.
//
// UPower names the system battery in displayDevice. When it is missing or is
// not a battery, a battery that reports powerSupply (the one wired to the
// system) wins over a peripheral battery that merely comes first in the
// device list. The first battery is the last resort, and no battery at all
// yields null.
//
// The battery type is handed in by the module, so this object does not need
// the UPower import and can be tested with plain objects.
QtObject {
    function select(devices, displayDevice, batteryType) {
        if (displayDevice && displayDevice.type === batteryType)
            return displayDevice

        let first = null
        if (!devices)
            return null

        for (let i = 0; i < devices.length; i++) {
            const device = devices[i]
            if (!device || device.type !== batteryType)
                continue
            if (device.powerSupply === true)
                return device
            if (!first)
                first = device
        }
        return first
    }
}
