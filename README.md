# Example

A minimal plugin demonstrating a bar widget that opens a floating panel when
clicked.

## Plugin

| Field | Value |
| --- | --- |
| ID | `noctalia/example` |
| Entries | Bar widget: `hello`; panel: `panel` |

## Usage

Add the `hello` widget from the Add-widget picker. Clicking the widget toggles
the floating panel (`noctalia/example:panel`). The widget's tooltip shows the
click count.

## Settings

| Setting | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `string` | `Hello` | Text shown in the bar widget. |
| `glyph` | `glyph` | `puzzle` | Glyph shown before the label. |
| `show_glyph` | `bool` | `true` | Controls whether the glyph is visible. |

## IPC

You can also open the panel from the shell:

```sh
noctalia msg panel-toggle noctalia/example:panel
```
