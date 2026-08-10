--!nonstrict
-- CPU monitor detail view: Mission Center style with full-width graph and stats panel.

local MAX_SAMPLES = 60

local history = {}
local tempHistory = {}
local coreHistories = {}
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

function M.getPreview()
  if #history == 0 then
    return nil
  end
  return { values = { table.unpack(history) }, color = "primary" }
end

function M.getValue()
  if usage == 0 then
    return "—"
  end
  return string.format("%d%%", usage)
end

function M.getSubtitle()
  if temp == nil then
    return ""
  end
  return string.format("%d°C", temp)
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
    if cores ~= nil then
      for i = 1, #cores do
        if coreHistories[i] == nil then
          coreHistories[i] = {}
        end
        table.insert(coreHistories[i], (cores[i] or 0) / 100)
        if #coreHistories[i] > MAX_SAMPLES then
          table.remove(coreHistories[i], 1)
        end
      end
    end
  end
end

local function formatGhz(mhz)
  if mhz == nil then
    return "—"
  end
  return string.format("%.1f GHz", mhz / 1000)
end

local function buildYLabels()
  return ui.column({ justify = "space_between", width = 40 }, {
    ui.label({ text = "100%", fontSize = 10, color = "on_surface_variant" }),
    ui.label({ text = "75%", fontSize = 10, color = "on_surface_variant" }),
    ui.label({ text = "50%", fontSize = 10, color = "on_surface_variant" }),
    ui.label({ text = "25%", fontSize = 10, color = "on_surface_variant" }),
    ui.label({ text = "0%", fontSize = 10, color = "on_surface_variant" }),
  })
end

local function buildGraph()
  return ui.column({ flexGrow = 1, gap = 4 }, {
    ui.row({ gap = 8, align = "stretch", flexGrow = 1 }, {
      buildYLabels(),
      ui.column({ flexGrow = 1, gap = 4 }, {
        ui.graph({
          values = { table.unpack(history) },
          color = "primary",
          values2 = { table.unpack(tempHistory) },
          color2 = "error",
          lineWidth = 2,
          flexGrow = 1,
        }),
        ui.row({ justify = "space_between" }, {
          ui.label({ text = "Utilization over 1 minute", fontSize = 10, color = "on_surface_variant" }),
          ui.label({ text = "100%", fontSize = 10, color = "on_surface_variant" }),
        }),
      }),
    }),
  })
end

local function buildStatsPanel()
  local stats = {
    { label = "Utilization", value = string.format("%d%%", usage), highlight = true },
    { label = "Temperature", value = temp ~= nil and string.format("%d°C", temp) or "—" },
    { label = "Frequency", value = formatGhz(freq) },
    { label = "Max Frequency", value = formatGhz(maxFreq) },
  }
  if load ~= nil and #load >= 3 then
    table.insert(stats, { label = "Load (1m)", value = string.format("%.2f", load[1]) })
    table.insert(stats, { label = "Load (5m)", value = string.format("%.2f", load[2]) })
    table.insert(stats, { label = "Load (15m)", value = string.format("%.2f", load[3]) })
  end
  table.insert(stats, { label = "Min Usage", value = string.format("%d%%", minUsage) })
  table.insert(stats, { label = "Max Usage", value = string.format("%d%%", maxUsage) })

  local rows = {}
  for _, s in ipairs(stats) do
    local valColor = s.highlight and "primary" or nil
    table.insert(rows, ui.row({ justify = "space_between" }, {
      ui.label({ text = s.label, fontSize = 12, color = "on_surface_variant" }),
      ui.label({ text = s.value, fontSize = 12, fontWeight = s.highlight and "bold" or nil, color = valColor }),
    }))
  end
  return ui.column({
    fill = "surface_variant/0.6",
    radius = 8,
    padding = 12,
    gap = 6,
    width = 180,
  }, {
    ui.label({ text = "Statistics", fontSize = 12, fontWeight = "bold" }),
    ui.column({ gap = 4 }, rows),
  })
end

function M.build()
  return ui.column({ flexGrow = 1, gap = 0 }, {
    ui.row({ padding = { left = 12, right = 12, top = 12, bottom = 4 }, align = "center", justify = "space_between" }, {
      ui.column({ gap = 2 }, {
        ui.label({ text = "CPU", fontSize = 18, fontWeight = "bold" }),
        ui.label({ text = "Utilization over 1 minute", fontSize = 11, color = "on_surface_variant" }),
      }),
      ui.label({ text = string.format("%d%%", usage), fontSize = 18, fontWeight = "bold", color = "primary" }),
    }),
    ui.row({ flexGrow = 1, gap = 12, padding = { left = 12, right = 12, bottom = 12 }, align = "stretch" }, {
      ui.column({ flexGrow = 1, gap = 8 }, {
        ui.column({ fill = "surface_variant/0.4", radius = 10, border = "outline/0.2", borderWidth = 1, padding = 12, flexGrow = 1 }, {
          buildGraph(),
        }),
      }),
      buildStatsPanel(),
    }),
  })
end

return M
