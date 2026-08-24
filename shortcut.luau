--!nonstrict
-- Control-center [[shortcut]] entry for System Monitor.

local function render()
  shortcut.setLabel("System Monitor")
  shortcut.setIcon("cpu")
  shortcut.setActive(false)
  shortcut.setEnabled(true)
end

render()

function onClick()
  noctalia.togglePanel("arrifat346afs/system-monitor:panel")
end

