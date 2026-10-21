# jbar

A [Quickshell](https://quickshell.org) port of the waybar config in
`~/.config/waybar` (the *mechabar* theme).

Everything the waybar config does is done here as well: the same modules, the
same order, the same icons, the same colours and the same click, scroll and
hover behaviour.

```
shell.qml          entry point
bar/Bar.qml        the panel and the module layout
bar/Module.qml     base class of every module (background, padding, mouse)
bar/Theme.qml      colours, fonts and metrics (theme.css)
bar/Icons.qml      the Nerd Font glyphs of the waybar config
bar/Niri.qml       niri IPC (workspaces, focused window)
bar/Player.qml     the current MPRIS player
bar/Tooltip.qml    controller for the shared tooltip popup
bar/modules/       one file per module
```

## Running

```bash
quickshell -p ./shell.qml
```

To run it on every output the panel is created through `Variants` with
`Quickshell.screens` as the model, the same way the waybar `output` option
does. The outputs the bar is shown on are listed in `bar/Bar.qml`:

```qml
property var outputs: ["eDP-1", "HDMI-A-1", "DP-2"]
```

Set it to an empty list to show the bar on every output.

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
| `group/idle_inhibitor`              | `bar/modules/PowerGroup.qml`      | suspends the idle timer of the compositor          |
| `custom/power`                      | `bar/modules/PowerGroup.qml`      | opens `wlogout`                                    |

Both groups use the waybar `drawer` option: the second module of the group
is hidden and slides out to the left while the group is hovered, the module
that is hovered stays where it is.

## Differences to waybar

* **The battery percentage is calculated from the energy.** UPower reports a
  percentage of its own that does not match the charge level of the battery
  (1 % for a full battery), waybar reads the capacity from sysfs instead.
* **The tooltips are quickshell popups** instead of GTK tooltips, and the
  clock calendar is drawn by the port instead of by waybar.

## Requirements

* Quickshell (tested with 0.3.1)
* `Geist` and a Nerd Font (`CaskaydiaCove Nerd Font` is what fontconfig
  picks for the icons of the waybar config, so the icons look the same)
* `niri`, `nmcli`, `brightnessctl`, `checkupdates`, `playerctl`/`MPRIS`,
  `rofi` and `wlogout` for the actions of the individual modules
