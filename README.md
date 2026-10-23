# jbar

A [Quickshell](https://quickshell.org) port of the waybar config in
`~/.config/waybar` (the *mechabar* theme).

Everything the waybar config does is done here as well: the same modules, the
same order, the same icons, the same colours and the same click, scroll and
hover behaviour.

```
shell.qml            entry point
bar/Bar.qml          the panel and the module layout
bar/Module.qml       base class of every module (background, padding, mouse)
bar/Theme.qml        colours, fonts and metrics (theme.css)
bar/Icons.qml        the Nerd Font glyphs of the waybar config
bar/Label.qml        a text run with the typography of the bar
bar/Metric.qml       a number of the system, with its states and its glyphs
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
```

## Running

```bash
quickshell -p ./shell.qml
```

To run it on every output the panel is created through `Variants` with
`Quickshell.screens` as the model, the same way the waybar `output` option
does. The outputs the bar is shown on are a setting of the bar, see below.

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
The folder is created on first run. The file is read when the bar starts
and written when a value changes, a file that was edited by hand is picked
up while the bar runs.

The settings are changed in the page of the settings: the button of the
settings slides out of the group of the logo of the distribution, it opens
the page in a popup below the bar.

## Tests

The metrics of the systems and the settings of the bar are plain objects
without any I/O, so they can be tested without a bar and without a command:

```bash
/usr/lib/qt6/bin/qmltestrunner -input tests
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

* Quickshell (tested with 0.3.1)
* `Geist` and a Nerd Font (`CaskaydiaCove Nerd Font` is what fontconfig
  picks for the icons of the waybar config, so the icons look the same)
* `niri`, `nmcli`, `brightnessctl`, `checkupdates`, `playerctl`/`MPRIS`,
  `rofi` and `wlogout` for the actions of the individual modules
