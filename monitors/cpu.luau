--!nonstrict
-- CPU monitor detail view: overall usage graph, temperature / frequency / load
-- readouts, and an optional per-core usage list.

local MAX_SAMPLES = 60

local history = {}
local tempHistory = {}
local usage = 0
local temp = nil
local freq = nil
local maxFreq = nil
local load = nil
local cores = nil
local showCores = false
local refresh = nil
local minUsage = 100
local maxUsage = 0

local M = {}

function M.attach(fn)
  refresh = fn
  noctalia.setUpdateInterval(1000)
end

function M.tick()
  local s = noctalia.systemStats()
  if s == nil then
    return
  end

  usage = s.cpu.usagePercent or 0
  temp = s.cpu.tempC
  freq = s.cpu.freqMhz
  maxFreq = s.cpu.maxFreqMhz
  load = s.loadAvg

  table.insert(history, usage / 100)
  if #history > MAX_SAMPLES then
    table.remove(history, 1)
  end

  table.insert(tempHistory, (temp or 0) / 100)
  if #tempHistory > MAX_SAMPLES then
    table.remove(tempHistory, 1)
  end

  if usage < minUsage then minUsage = usage end
  if usage > maxUsage then maxUsage = usage end

  if showCores then
    cores = noctalia.cpuCores()
  end
end

local function formatGhz(mhz)
  if mhz == nil then
    return "—"
  end
  return string.format("%.1f GHz", mhz / 1000)
end

local function statCard(label, value)
  return ui.column({ flexGrow = 1, gap = 2 }, {
    ui.label({ text = label, fontSize = 12, color = "on_surface_variant" }),
    ui.label({ text = value, fontWeight = "bold" }),
  })
end

local function buildCores()
  if cores == nil or #cores == 0 then
    return ui.label({ text = "Sampling…", color = "on_surface_variant" })
  end

  local rows = {}
  for i, pct in ipairs(cores) do
    table.insert(rows, ui.row({ gap = 8, align = "center" }, {
      ui.label({ text = string.format("Core %d", i), width = 56 }),
      ui.progress({ progress = (pct or 0) / 100, flexGrow = 1 }),
      ui.label({ text = string.format("%d%%", math.floor(pct or 0)), width = 40, textAlign = "end" }),
    }))
  end

  return ui.scroll({ flexGrow = 1, gap = 6 }, rows)
end

local function getUsageColor()
  return "primary"
end

function M.build()
  local loadText = "—"
  if load ~= nil and #load >= 3 then
    loadText = string.format("%.1f / %.1f / %.1f", load[1], load[2], load[3])
  end

  local freqText = formatGhz(freq)
  if freq ~= nil and maxFreq ~= nil then
    freqText = freqText .. " / " .. formatGhz(maxFreq)
  end

  local children = {
    ui.row({ gap = 24, align = "center" }, {
      ui.label({ text = string.format("%d%%", usage), fontSize = 32, fontWeight = "bold", color = "primary" }),
      ui.column({ flexGrow = 1, gap = 2 }, {
        ui.label({ text = "CPU Usage", fontSize = 12, color = "on_surface_variant" }),
        ui.label({ text = "Overall utilisation across all cores", color = "on_surface_variant" }),
      }),
    }),
    ui.row({ gap = 8, align = "stretch" }, {
      ui.column({ justify = "space_between", width = 36, gap = 0 }, {
        ui.label({ text = "100%", fontSize = 10, color = "primary" }),
        ui.label({ text = "75%", fontSize = 10, color = "primary" }),
        ui.label({ text = "50%", fontSize = 10, color = "primary" }),
        ui.label({ text = "25%", fontSize = 10, color = "primary" }),
        ui.label({ text = "0%", fontSize = 10, color = "primary" }),
      }),
      ui.column({ flexGrow = 1, gap = 4 }, {
        ui.graph({
          values = { table.unpack(history) },
          color = "primary",
          values2 = { table.unpack(tempHistory) },
          color2 = "error",
          lineWidth = 2,
          height = 700,
        }),
        ui.row({ justify = "space_between" }, {
          ui.label({ text = "60s ago", fontSize = 10, color = "outline" }),
          ui.label({ text = "now", fontSize = 10, color = "outline" }),
        }),
      }),
    }),
    ui.row({ gap = 24, align = "center" }, {
      ui.label({
        text = string.format("Min: %d%%  Max: %d%%", minUsage, maxUsage),
        fontSize = 12,
        color = "on_surface_variant"
      }),
    }),
    ui.row({ gap = 12, align = "stretch" }, {
      statCard("Temperature", temp ~= nil and string.format("%.0f°C", temp) or "—"),
      statCard("Frequency", freqText),
      statCard("Load (1m / 5m / 15m)", loadText),
    }),
    ui.row({ gap = 12, align = "center" }, {
      ui.toggle({
        checked = showCores,
        onChange = function(value)
          showCores = value == "true"
          if showCores then
            cores = noctalia.cpuCores()
          end
          if refresh then refresh() end
        end,
      }),
      ui.label({ text = "Show per-core usage", flexGrow = 1 }),
    }),
  }

  if showCores then
    table.insert(children, buildCores())
  end

  return ui.column({ flexGrow = 1, gap = 12 }, children)
end

return M
