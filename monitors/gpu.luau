--!nonstrict
-- GPU monitor detail view: Mission Center style with full-width graph and stats panel.

local MAX_SAMPLES = 60

local history = {}
local tempHistory = {}
local usagePercent = 0
local tempC = nil
local vramUsedBytes = nil
local vramTotalBytes = nil
local refresh = nil

local M = {}

function M.attach(fn)
  refresh = fn
end

function M.getPreview()
  if #history == 0 then
    return nil
  end
  return { values = { table.unpack(history) }, color = "secondary" }
end

function M.getValue()
  if usagePercent == 0 then
    return "—"
  end
  local val = string.format("%d%%", usagePercent)
  if tempC ~= nil then
    val = val .. string.format(" (%d°C)", tempC)
  end
  return val
end

function M.getSubtitle()
  if tempC == nil then
    return ""
  end
  return string.format("%d°C", tempC)
end

function M.tick()
  local s = noctalia.systemStats()
  if s == nil then
    return
  end
  usagePercent = s.gpu.usagePercent or 0
  tempC = s.gpu.tempC
  vramUsedBytes = s.gpu.vramUsedBytes
  vramTotalBytes = s.gpu.vramTotalBytes
  table.insert(history, usagePercent / 100)
  table.insert(tempHistory, tempC ~= nil and tempC / 100 or 0)
  if #history > MAX_SAMPLES then
    table.remove(history, 1)
    table.remove(tempHistory, 1)
  end
end

local function formatBytes(bytes)
  if bytes == nil then
    return "N/A"
  end
  if bytes >= 1073741824 then
    return string.format("%.1f GiB", bytes / 1073741824)
  elseif bytes >= 1048576 then
    return string.format("%.1f MiB", bytes / 1048576)
  end
  return string.format("%.0f KiB", bytes / 1024)
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
          color = "secondary",
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
    { label = "Utilization", value = string.format("%d%%", usagePercent), highlight = true },
    { label = "Temperature", value = tempC ~= nil and string.format("%d°C", tempC) or "—" },
  }
  if vramUsedBytes ~= nil and vramTotalBytes ~= nil then
    local vramPct = (vramUsedBytes / vramTotalBytes) * 100
    table.insert(stats, { label = "Memory Usage", value = string.format("%s / %s", formatBytes(vramUsedBytes), formatBytes(vramTotalBytes)) })
    table.insert(stats, { label = "Memory Usage %", value = string.format("%.1f%%", vramPct) })
  elseif vramUsedBytes ~= nil then
    table.insert(stats, { label = "Memory Used", value = formatBytes(vramUsedBytes) })
  end

  local rows = {}
  for _, s in ipairs(stats) do
    local valColor = s.highlight and "secondary" or nil
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
  local headerValue = string.format("%d%%", usagePercent)
  if tempC ~= nil then
    headerValue = headerValue .. string.format(" · %d°C", tempC)
  end
  return ui.column({ flexGrow = 1, gap = 0 }, {
    ui.row({ padding = 12, align = "center", justify = "space_between" }, {
      ui.column({ gap = 2 }, {
        ui.label({ text = "GPU", fontSize = 18, fontWeight = "bold" }),
        ui.label({ text = "Utilization over 1 minute", fontSize = 11, color = "on_surface_variant" }),
      }),
      ui.label({ text = headerValue, fontSize = 18, fontWeight = "bold", color = "secondary" }),
    }),
    ui.row({ flexGrow = 1, gap = 12, padding = { left = 12, right = 12, bottom = 12 }, align = "stretch" }, {
      ui.column({ flexGrow = 1, gap = 0 }, {
        ui.column({ fill = "surface_variant/0.4", radius = 10, border = "outline/0.2", borderWidth = 1, padding = 12, flexGrow = 1 }, {
          buildGraph(),
        }),
      }),
      buildStatsPanel(),
    }),
  })
end

return M
