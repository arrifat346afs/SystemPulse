--!nonstrict
-- A bar widget that displays CPU/RAM stats and opens the system monitor panel.

local showCpu = noctalia.getConfig("show_cpu")
local showRam = noctalia.getConfig("show_ram")

local cpuUsage = 0
local ramUsage = 0

local function formatPercent(value)
  return string.format("%d%%", value)
end

local function render()
  local parts = {}
  if showCpu then
    table.insert(parts, string.format("CPU %s", formatPercent(cpuUsage)))
  end
  if showRam then
    table.insert(parts, string.format("RAM %s", formatPercent(ramUsage)))
  end

  local text = table.concat(parts, " | ")
  if text == "" then
    text = "System Monitor"
  end

  barWidget.setGlyph("cpu")
  barWidget.setText(text)
  barWidget.setTooltip("Click to open System Monitor")
end

function update()
  noctalia.setUpdateInterval(2000)
  local s = noctalia.systemStats()
  if s ~= nil then
    cpuUsage = math.floor(s.cpu.usagePercent or 0)
    ramUsage = math.floor(s.ram.usagePercent or 0)
  end
  render()
end

function onClick()
  noctalia.togglePanel("noctalia/system-monitor:panel")
end
