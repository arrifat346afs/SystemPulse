--!nonstrict
-- RAM monitor detail view: Mission Center style with full-width graph and stats panel.

local MAX_SAMPLES = 60

local history = {}
local usagePercent = 0
local usedMb = 0
local totalMb = 0
local refresh = nil

local M = {}

function M.attach(fn)
  refresh = fn
end

function M.getPreview()
  if #history == 0 then
    return nil
  end
  return { values = { table.unpack(history) }, color = "tertiary" }
end

function M.getValue()
  if usagePercent == 0 then
    return "—"
  end
  return string.format("%.1f%%", usagePercent)
end

function M.getSubtitle()
  if totalMb == 0 then
    return ""
  end
  return string.format("%.1f / %.1f GiB", usedMb / 1024, totalMb / 1024)
end

function M.tick()
  local s = noctalia.systemStats()
  if s == nil then
    return
  end
  usagePercent = s.ram.usagePercent or 0
  usedMb = s.ram.usedMb or 0
  totalMb = s.ram.totalMb or 0
  table.insert(history, usagePercent / 100)
  if #history > MAX_SAMPLES then
    table.remove(history, 1)
  end
end

local function formatMb(mb)
  if mb >= 1024 then
    return string.format("%.1f GiB", mb / 1024)
  end
  return string.format("%.0f MiB", mb)
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
          color = "tertiary",
          lineWidth = 2,
          flexGrow = 1,
        }),
        ui.row({ justify = "space_between" }, {
          ui.label({ text = "Memory usage over 1 minute", fontSize = 10, color = "on_surface_variant" }),
          ui.label({ text = formatMb(totalMb), fontSize = 10, color = "on_surface_variant" }),
        }),
      }),
    }),
  })
end

local function buildStatsPanel()
  local freeMb = totalMb - usedMb
  local stats = {
    { label = "In use", value = formatMb(usedMb), highlight = true },
    { label = "Available", value = formatMb(freeMb) },
    { label = "Total", value = formatMb(totalMb) },
    { label = "Usage", value = string.format("%.1f%%", usagePercent) },
  }

  local rows = {}
  for _, s in ipairs(stats) do
    local valColor = s.highlight and "tertiary" or nil
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
    ui.row({ padding = 12, align = "center", justify = "space_between" }, {
      ui.column({ gap = 2 }, {
        ui.label({ text = "Memory", fontSize = 18, fontWeight = "bold" }),
        ui.label({ text = "Memory usage over 1 minute", fontSize = 11, color = "on_surface_variant" }),
      }),
      ui.label({ text = formatMb(totalMb), fontSize = 18, fontWeight = "bold", color = "tertiary" }),
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
