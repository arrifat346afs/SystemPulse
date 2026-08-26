--!nonstrict
-- Control-center [[shortcut]] entry for System Monitor.

-- Sets up the control-center tile: label, icon and enabled state.
local function render()
  shortcut.setLabel("System Monitor")
  shortcut.setIcon("cpu")
  shortcut.setActive(false)
  shortcut.setEnabled(true)
end

render()

-- Opens (or closes) the System Monitor panel.
function onClick()
  noctalia.togglePanel("arrifat346afs/system-monitor:panel")
end

