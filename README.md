# jbar

A [Quickshell](https://quickshell.org) port of the waybar config in
`~/.config/waybar` (the *mechabar* theme).

Everything the waybar config does is done here as well: the same modules, the
same order, the same icons, the same colours and the same click, scroll and
hover behaviour.

```
shell.qml            entry point
config.example.json  a template of the settings file (not the live config)
bar/Bar.qml          the panel and the module layout
bar/Module.qml       base class of every module (background, padding, mouse)
bar/Theme.qml        colours, fonts and metrics (theme.css)
bar/Icons.qml        the Nerd Font glyphs of the waybar config
bar/Label.qml        a text run with the typography of the bar
bar/Metric.qml       a number of the system, with its states and its glyphs
bar/Metrics.qml      the system metrics shared by every bar
bar/MetricsPollers.qml the one poller of every shared metric
bar/NiriReconnect.qml the reconnection policy of the niri event stream
bar/Settings.qml     the values of the bar the user can change
bar/SettingsPage.qml the page of the settings
bar/SettingRow.qml   a row of the settings page
bar/DrawerGroup.qml  a group of modules, the hidden ones hidden
bar/Motion.qml       an animation of the bar
bar/Popup.qml        a popup of the bar, anchored below its module
bar/TooltipPopup.qml the tooltip of a module
bar/adapters/        the things that talk to the system
  ConfigFile.qml     the config file of the bar
  Niri.qml           niri IPC (workspaces, focused window)
  Player.qml         the current MPRIS player
  Poller.qml         reads the value of a metric with a command
bar/metrics/         the metric of every system the bar shows
bar/modules/         one file per module
tests/               the tests of the headless modules
tests/check.sh       the tests and the lint gate
```

## Running

```bash
quickshell -p ./shell.qml
```

To run it on every output the panel is created through `Variants` with
`Quickshell.screens` as the model, the same way the waybar `output` option
does. The outputs the bar is shown on are a setting of the bar, see below.

The system metrics are polled once for the whole shell, not once per output:
`bar/Metrics.qml` is a QML singleton created outside the `Variants`, so every
bar reads the same values and adding an output starts no new poll.

## Settings

Everything that is specific to a machine is a setting of the bar: the
commands the modules run, the thresholds of the metrics, the intervals of
the polls, the fonts, the colours and the outputs the bar is shown on. Two
of the settings are about the way the bar moves: *reduced motion* turns the
animations off, *animate popup exit* lets a popup shrink back into the bar
when it closes.

The settings live in `config.json` in the config folder of the user,
`$XDG_CONFIG_HOME/quickshell/jbar/config.json` (usually
`~/.config/quickshell/jbar/config.json`), not in the checkout of the bar.
The folder and the file are created the first time a setting changes. The
file is read when the bar starts and written when a value changes, a file
that was edited by hand is picked up while the bar runs.

`config.example.json` at the root of the checkout is a template of that
file: every key with its default value. It is not the live config, the bar
never reads it. Copy it to the path above if you want to start from the
template; the schema is documented in
[Configuration reference](#configuration-reference).

The settings are changed in the page of the settings: the button of the
settings slides out of the group of the logo of the distribution, it opens
the page in a popup below the bar.

## Configuration reference

The live file is `$XDG_CONFIG_HOME/quickshell/jbar/config.json`. Every key
is optional: a key that is missing uses its default, which is also the value
in `config.example.json`. Keys that are not listed here are kept in the file
but have no effect on the bar.

The type of a colour is a string with a `#rrggbb` value or a colour name Qt
knows. A command is a command line, split into arguments at whitespace;
single or double quotes keep a part together. Commands are run directly and
not through a shell, so pipes, variables and `~` do not work in them. The
one exception is `updatesCheckCommand`, which the metric runs as
`sh -c "<command> 2>/dev/null | wc -l"`: it may use shell syntax, and its
output is counted line by line as the number of pending updates.

`outputs` is a comma separated list of output names (`eDP-1`, `HDMI-A-1`,
`DP-2`). Spaces around a name are ignored. An empty string shows the bar on
every output. The names are the ones of `Quickshell.screens`, which are the
output names of niri.

### Bar

| Key                  | Type   | Default                              | Meaning                                              |
| -------------------- | ------ | ------------------------------------ | ---------------------------------------------------- |
| `outputs`            | string | `""`                                 | the outputs the bar is shown on; empty means all     |
| `fontFamily`         | string | `"Geist"`                            | the font of the text of the bar                      |
| `iconFont`           | string | `"CaskaydiaCove Nerd Font"`          | the font the icons are drawn with                    |
| `fontSize`           | int    | `16`                                 | the size of the text and the icons, in pixels        |
| `reducedMotion`      | bool   | `false`                              | turn the animations off                              |
| `popupExitAnimation` | bool   | `true`                               | shrink a popup back into the bar when it closes      |

### Clock

| Key            | Type   | Default     | Meaning                                             |
| -------------- | ------ | ----------- | --------------------------------------------------- |
| `clock24Hour`  | bool   | `true`      | `true` shows 24 hour time, `false` 12 hour time      |
| `dateFormat`   | string | `"dd-MM"`   | the date format, in the syntax of `Qt.formatDate`    |

### Commands

| Key                      | Type   | Default                                                                         | Meaning                                                        |
| ------------------------ | ------ | ------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `launcherCommand`        | string | `"rofi -show drun"`                                                             | click on the distribution logo opens the launcher              |
| `powerMenuCommand`       | string | `"wlogout"`                                                                     | the power button opens the power menu                          |
| `networkManagerCommand`  | string | `"xdg-open vicinae://launch/@dagimg-dot/store.vicinae.wifi-commander/scan-wifi"` | click on the network module opens the network manager          |
| `bluetoothManagerCommand` | string | `"xdg-open vicinae://launch/@Gelei/store.vicinae.bluetooth/devices"`            | click on the Bluetooth module opens the Bluetooth manager      |
| `updatesCommand`         | string | `"kitty -T Updates yay -Syua"`                                                  | click on the updates module installs the updates               |
| `updatesCheckCommand`    | string | `"checkupdates"`                                                                | counts the pending updates; run through `sh`, see above        |

### Thresholds

| Key                    | Type | Default | Meaning                                                   |
| ---------------------- | ---- | ------- | --------------------------------------------------------- |
| `cpuWarning`           | int  | `75`    | processor usage that is a warning, in percent             |
| `cpuCritical`          | int  | `90`    | processor usage that is critical, in percent              |
| `memoryWarning`        | int  | `75`    | used memory that is a warning, in percent                 |
| `memoryCritical`       | int  | `90`    | used memory that is critical, in percent                  |
| `temperatureCritical`  | int  | `90`    | critical temperature in degrees Celsius, converted for display |
| `batteryWarning`       | int  | `20`    | battery charge that is a warning, in percent              |
| `batteryCritical`      | int  | `10`    | battery charge that is critical, in percent               |

### Polling

| Key                   | Type | Default | Meaning                              |
| --------------------- | ---- | ------- | ------------------------------------ |
| `cpuInterval`         | int  | `10`    | how often the processor is read, in seconds |
| `memoryInterval`      | int  | `10`    | how often the memory is read, in seconds    |
| `temperatureInterval` | int  | `10`    | how often the temperature is read, in seconds |
| `networkInterval`     | int  | `10`    | how often the network is read, in seconds   |
| `backlightInterval`   | int  | `2`     | how often the brightness is read, in seconds |
| `updatesInterval`     | int  | `60`    | how often the updates are counted, in minutes |

Every metric is polled once per shell. The defaults add up to the following
process launches per hour; a poll of `sh -c "… | …"` is counted as the
processes it starts:

| Metric      | Polls/hour | Before #11: processes/poll | Before #11: launches/hour | After #11: processes/poll | After #11: launches/hour |
| ----------- | ---------: | -------------------------: | ------------------------: | ------------------------: | -----------------------: |
| processor   |        360 |               2 (sh, head) |                       720 |                  1 (head) |                      360 |
| memory      |        360 |                2 (sh, awk) |                       720 |                   1 (awk) |                      360 |
| temperature |        360 |          3 (sh, cat, head) |                      1080 |                  1 (head) |                      360 |
| network     |        360 |              2 (sh, nmcli) |                       720 |                 1 (nmcli) |                      360 |
| brightness  |       1800 |       1 (brightnessctl -m) |                      1800 |      1 (brightnessctl -m) |                     1800 |
| updates     |          1 |   3 (sh, checkupdates, wc) |                         3 |  3 (sh, checkupdates, wc) |                        3 |
| **total**   |            |                            |                  **5043** |                           |                 **3243** |

Before #11 the table was multiplied by the number of bars: two outputs
launched 2 × 5043 = 10086 processes an hour, three outputs 15129. After #11
the total is the whole shell, so an added output launches no process at all.
Before #7 the brightness poll was a five-process pipeline (5 × 1800 = 9000
launches an hour for the brightness alone), which is where the ~13k per bar
of the audit came from; #7 made it a single `brightnessctl -m` process.

### System

| Key                 | Type   | Default | Meaning                                                          |
| ------------------- | ------ | ------- | ---------------------------------------------------------------- |
| `thermalZone`       | int    | `1`     | the thermal zone the temperature is read from                    |
| `temperatureUnit`   | string | `"F"`   | `"F"` or `"C"`; the threshold is stored in Celsius in both cases |
| `volumeStep`        | int    | `2`     | the step of the volume on scroll, in percent                     |
| `volumeMax`         | int    | `150`   | the loudest volume, in percent                                   |

### Colours

| Key               | Type   | Default     | Meaning                                   |
| ----------------- | ------ | ----------- | ----------------------------------------- |
| `accentColor`     | string | `"#83a598"` | the accent, the highlighted parts of the bar |
| `backgroundColor` | string | `"#1d2021"` | the background of the bar                 |
| `foregroundColor` | string | `"#ebdbb2"` | the text of the bar                       |

## Tests

The gate of the tree runs the headless tests and lints every QML file:

```bash
./tests/check.sh
```

The script first runs the tests below, then `qmllint` over
`shell.qml`, `bar/` and `tests/`. It also checks that the example config
names every setting and that the README lists the requirements; the JSON of
the example is parsed when `jq` or Python 3 is available. The gate fails on
a failing test or a lint error.

### Known lint warnings

With Qt 6.11.2 the tree lints with exit status 0 and the warnings below.
They are documented instead of silenced:

* `uncreatable-type` and `unresolved-type` — the qmltypes of Quickshell do
  not mark `PanelWindow` as creatable and do not expose the declarative
  dependencies of `Bluetooth.defaultAdapter` and `Bluetooth.devices`. The bar
  loads them at runtime with Quickshell 0.3.1; the warning is in the type
  metadata of Quickshell, not in the bar.
* `missing-property` (`DrawerGroup.triggerModule.hovered`) — qmllint types
  the property as `QQuickItem`, while the bar puts `Module` objects there.
* `unqualified` and the `pragma ComponentBehavior: Bound` infos — nested
  components in the drawers, the calendar, the settings page and the
  tooltip read the ids of their outer component. These are style warnings;
  they do not change the behaviour and can be fixed file by file.
* `unused-imports` infos — these imports name no type of the file; they are
  harmless.

The metrics of the systems and the settings of the bar are plain objects
without any I/O, so they can be tested without a bar and without a command.
The two commands also work on their own:

```bash
/usr/lib/qt6/bin/qmltestrunner -input tests
/usr/lib/qt6/bin/qmllint -I /usr/lib/qt6/qml shell.qml bar/*.qml bar/*/*.qml tests/*.qml
```

## Module mapping

| waybar                              | quickshell                        | notes                                              |
| ----------------------------------- | --------------------------------- | -------------------------------------------------- |
| `niri/workspaces`                   | `bar/modules/Workspaces.qml`      | click focuses, scroll moves the focus              |
| `niri/window`                       | `bar/modules/WindowTitle.qml`     | application icon comes from the desktop entry       |
| `temperature`                       | `bar/modules/Temperature.qml`     | thermal zone 1, critical from 194°F                 |
| `memory`                            | `bar/modules/Memory.qml`          | warning 75%, critical 90%                          |
| `cpu`                               | `bar/modules/Cpu.qml`             | warning 75%, critical 90%                          |
| `custom/distro`                     | `bar/modules/Distro.qml`          | opens `rofi -show drun`                            |
| `clock#time`                        | `bar/modules/Clock.qml`           | click toggles 12h/24h, the choice is remembered     |
| `clock#date`                        | `bar/modules/DateModule.qml`      | hover opens the year calendar, click switches view  |
| `network`                           | `bar/modules/Network.qml`         | opens the vicinae wifi commander                   |
| `bluetooth`                         | `bar/modules/Bluetooth.qml`       | opens the vicinae bluetooth manager                |
| `custom/update`                     | `bar/modules/Updates.qml`         | `checkupdates` once an hour, opens `yay -Syua`     |
| `image#album-art`                   | `bar/modules/AlbumArt.qml`        | the cover of the current player                    |
| `mpris`                             | `bar/modules/Mpris.qml`           | click toggles, right click skips the track         |
| `group/pulseaudio`                  | `bar/modules/Volume.qml`          | output and input, both on the volume background    |
| `backlight`                         | `bar/modules/Backlight.qml`       | click opens a brightness slider                    |
| `battery`                           | `bar/modules/Battery.qml`         | click opens the power profile menu                 |
| `group/idle_inhibitor`              | `bar/modules/IdleToggle.qml`      | suspends the idle timer of the compositor          |
| `custom/power`                      | `bar/modules/PowerButton.qml`     | opens `wlogout`                                    |
|                                     | `bar/modules/SettingsButton.qml`  | opens the settings of the bar                      |

The groups use the waybar `drawer` option: the modules of the group are
hidden and slide out while the group is hovered, the module that is hovered
stays where it is. The group of the logo of the distribution slides its
modules out over the modules next to it, so the logo keeps its place: the
button of the settings comes out to the left of it, the power button and the
idle inhibitor to the right.

Every output gets its own bar, its own tooltip and its own popups: a module
finds the window of its bar on its own, so the tooltip of one output never
shows up on another.

## Differences to waybar

* **The battery percentage is calculated from the energy.** UPower reports a
  percentage of its own that does not match the charge level of the battery
  (1 % for a full battery), waybar reads the capacity from sysfs instead.
* **The tooltips are quickshell popups** instead of GTK tooltips, and the
  clock calendar is drawn by the port instead of by waybar.
* **The values of the bar are settings.** Everything that is specific to a
  machine (the commands, the thresholds, the intervals, the fonts, the
  colours and the outputs) can be changed in the settings of the bar, they
  are stored in `$XDG_CONFIG_HOME/quickshell/jbar/config.json`.

## Requirements

* Quickshell (tested with 0.3.1; the idle inhibitor is imported from the
  public `Quickshell.Wayland` module, which re-exports it in 0.3.1)
* `Geist` for the text of the bar and a Nerd Font for the icons; the default
  icon font is `CaskaydiaCove Nerd Font`
* `niri` — the workspaces, the focused window and the workspace actions
* `nmcli` (NetworkManager) — the state of the network connection
* `brightnessctl` — reading and setting the screen brightness
* `checkupdates` (pacman-contrib) — counting the pending updates
* an MPRIS player — the bar reads it through the MPRIS service of
  Quickshell; `playerctl` is a convenient way to check the player
* `rofi` — the default application launcher
* `wlogout` — the default power menu
* `kitty` and `yay` — the default command that installs the updates
* `notify-send` (libnotify) and a notification daemon — the battery events
* `xdg-open` and a handler for the `vicinae://` URIs (vicinae) — the default
  network and Bluetooth managers
* `sh` and the usual core utilities — the command lines of the metrics
* PipeWire, UPower and BlueZ — the volume, battery and Bluetooth services
  are read through Quickshell

For development:

* `qmltestrunner` and `qmllint` from Qt 6 (tested with Qt 6.11.2)
* `bash` — `tests/check.sh`
