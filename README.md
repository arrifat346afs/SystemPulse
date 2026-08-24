#   Monitor

A bar widget that displays live CPU and RAM usage, with a detailed floating panel showing CPU, RAM, Disk, Network, and GPU monitoring.

## Plugin

| Field | Value |
| --- | --- |
| ID | `noctalia/system-monitor` |
| Entries | Bar widget: `sysmon`; panel: `panel`; shortcut: `toggle` |

## Usage

Add the `sysmon` widget from the Add-widget picker. Clicking the widget opens the system monitor panel, which attaches to the bar so its background follows the bar's `background_opacity`.

## Settings

| Setting | Type | Default | Description |
| --- | --- | --- | --- |
| `show_cpu` | `bool` | `true` | Display CPU usage percentage in the bar. |
| `show_ram` | `bool` | `true` | Display RAM usage percentage in the bar. |

## Keybind

Open the panel from the shell:

```sh
noctalia msg panel-toggle noctalia/system-monitor:panel
```

Or via plugin IPC:

```sh
noctalia msg plugin noctalia/system-monitor:panel all open
```

To set up a Hyprland keybind, add to your `binds.lua`:

```lua
bind = SHIFT+CTRL, Escape, exec, noctalia msg panel-toggle noctalia/system-monitor:panel
```

## Shortcut

Add the `toggle` shortcut from Settings → Control Center shortcuts to toggle the panel from the control center.
