--!nonstrict
-- A bar widget that displays system stats and opens the system monitor panel.

local showCpu = noctalia.getConfig("show_cpu")
local showRam = noctalia.getConfig("show_ram")
local showGpu = noctalia.getConfig("show_gpu")
local showDisk = noctalia.getConfig("show_disk")
local showNetwork = noctalia.getConfig("show_network")

local cpuUsage = 0
local ramUsage = 0
local gpuUsage = 0
local diskUsage = 0
local netSpeed = ""

local function formatPercent(value)
  return string.format("%d%%", value)
end

local function formatSpeed(bytesPerSec)
  if bytesPerSec >= 1073741824 then
    return string.format("%.1fGB/s", bytesPerSec / 1073741824)
  elseif bytesPerSec >= 1048576 then
    return string.format("%.1fMB/s", bytesPerSec / 1048576)
  elseif bytesPerSec >= 1024 then
    return string.format("%.1fKB/s", bytesPerSec / 1024)
  end
  return string.format("%.0fB/s", bytesPerSec)
end

local function render()
  local parts = {}
  if showCpu then
    table.insert(parts, string.format("CPU %s", formatPercent(cpuUsage)))
  end
  if showRam then
    table.insert(parts, string.format("RAM %s", formatPercent(ramUsage)))
  end
  if showGpu then
    table.insert(parts, string.format("GPU %s", formatPercent(gpuUsage)))
  end
  if showDisk then
    table.insert(parts, string.format("Disk %s", formatPercent(diskUsage)))
  end
  if showNetwork then
    table.insert(parts, string.format("Net %s", netSpeed))
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

    if showGpu and s.gpu then
      gpuUsage = math.floor(s.gpu.usagePercent or 0)
    end

    if showDisk then
      local mounts = noctalia.diskMounts()
      if mounts and #mounts > 0 then
        local d = noctalia.diskStats(mounts[1].path)
        if d then
          diskUsage = math.floor(d.usagePercent or 0)
        end
      end
    end

    if showNetwork and s.net then
      local rx = s.net.rxBytesPerSec or 0
      local tx = s.net.txBytesPerSec or 0
      netSpeed = string.format("↓%s ↑%s", formatSpeed(rx), formatSpeed(tx))
    end
  end
  render()
end

function onClick()
  noctalia.togglePanel("noctalia/system-monitor:panel")
end

function onIpc(event, payload)
  if event == "open" then
    noctalia.togglePanel("noctalia/system-monitor:panel")
  end
end
