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
  noctalia.togglePanel("noctalia/system-monitor:panel")
end
