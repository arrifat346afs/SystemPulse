--!nonstrict
-- System monitor panel with sidebar showing device cards and individual app usages.

local cpu = require("./monitors/cpu.luau")
local ram = require("./monitors/ram.luau")
local disk = require("./monitors/disk.luau")
local network = require("./monitors/network.luau")
local gpu = require("./monitors/gpu.luau")
local system = require("./monitors/system.luau")

local monitors = {
  cpu = cpu,
  ram = ram,
  disk = disk,
  network = network,
  gpu = gpu,
  system = system,
}

local tab = "cpu"
local processes = {}

local deviceColors = {
  cpu = "primary",
  ram = "tertiary",
  disk = "secondary",
  network = "error",
  gpu = "secondary",
  system = "on_surface_variant",
}

local function sidebarItem(id, label, subtitle, value, module)
  local color = deviceColors[id] or "primary"
  local preview = module and module.getPreview and module.getPreview() or nil
  local isSelected = tab == id

  local function onClick()
    tab = id
    render()
  end

  local graphElement = nil
  if preview and #preview.values > 0 then
    graphElement = ui.column({ height = 50, border = "outline/0.3", radius = 4 }, {
      ui.graph({
        values = preview.values,
        color = color,
        height = 50,
        lineWidth = 1.5,
        flexGrow = 1,
      }),
    })
  else
    graphElement = ui.column({ height = 50, border = "outline/0.3", radius = 4 })
  end

  return ui.column({
    key = id,
    opacity = isSelected and 1.0 or 0.65,
    fill = isSelected and "primary/0.25" or "surface_variant/0.4",
    radius = 10,
    border = "outline/0.25",
    borderWidth = 1,
    padding = { left = 8, right = 2, top = 6, bottom = 6 },
    gap = 0,
    onClick = onClick,
  }, {
    ui.row({ gap = 8, align = "center" }, {
      ui.column({ width = 55 }, {
        graphElement,
      }),
      ui.column({ width = 110, gap = 2 }, {
        ui.label({ text = label, fontSize = 13, fontWeight = "bold", width = 110 }),
        ui.label({ text = subtitle, fontSize = 10, color = "on_surface_variant", width = 110 }),
        ui.label({ text = value, fontSize = 11, color = color, width = 110 }),
      }),
    }),
  })
end
-- 
local function formatMem(rssKb)
  if rssKb >= 1048576 then
    return string.format("%.1f GiB", rssKb / 1048576)
  elseif rssKb >= 1024 then
    return string.format("%.0f MiB", rssKb / 1024)
  end
  return string.format("%.0f KiB", rssKb)
end

local function appItem(proc)
  local name = proc.name
  if #name > 25 then
    name = name:sub(1, 22) .. "..."
  end
  return ui.row({
    key = "app_" .. tostring(proc.pid),
    radius = 6,
    padding = { left = 8, right = 8, top = 3, bottom = 3 },
    gap = 8,
    align = "center",
  }, {
    ui.label({ text = name, fontSize = 10, flexGrow = 1 }),
    ui.label({ text = string.format("%.0f%%", proc.cpu), fontSize = 10, width = 40, textAlign = "end" }),
    ui.label({ text = formatMem(proc.rss), fontSize = 10, width = 60, textAlign = "end" }),
  })
end

local function buildSidebar()
  local cpuVal = cpu.getValue and cpu.getValue() or "—"
  local ramVal = ram.getValue and ram.getValue() or "—"
  local diskVal = disk.getValue and disk.getValue() or "—"
  local netVal = network.getValue and network.getValue() or "—"
  local gpuVal = gpu.getValue and gpu.getValue() or "—"

  local appItems = {}
  for _, proc in ipairs(processes) do
    table.insert(appItems, appItem(proc))
  end

  return ui.column({ width = 180, gap = 6, fill = "surface_variant/0.4", radius = 10, padding = 6 }, {
    -- ui.label({ text = "Devices", fontSize = 14, fontWeight = "bold" }),
    sidebarItem("cpu", "CPU", cpu.getSubtitle and cpu.getSubtitle() or "", cpuVal, cpu),
    sidebarItem("ram", "Memory", ram.getSubtitle and ram.getSubtitle() or "", ramVal, ram),
    sidebarItem("disk", "Disk", disk.getSubtitle and disk.getSubtitle() or "", diskVal, disk),
    sidebarItem("network", "Network", network.getSubtitle and network.getSubtitle() or "", netVal, network),
    sidebarItem("gpu", "GPU", gpu.getSubtitle and gpu.getSubtitle() or "", gpuVal, gpu),
    sidebarItem("system", "System", "System Info", "", system),
    ui.column({ gap = 4 }, appItems),
  })
end

local function buildPerformanceView()
  return ui.row({ flexGrow = 1, gap = 12, align = "stretch" }, {
    buildSidebar(),
    ui.column({ flexGrow = 1, gap = 0, align = "stretch" }, {
      monitors[tab].build(),
    }),
  })
end





function render()
  panel.render(ui.column({ flexGrow = 1, gap = 0,padding = 0,align = "stretch"  }, {
    ui.row({ align = "center", justify = "space_between"}, {
      ui.label({ text = "System Monitor", fontSize = 16, fontWeight = "bold" }),
      ui.button({ glyph = "close", onClick = "onCloseClicked" }),
    }),
    ui.separator({ spacing = 12 }),
    buildPerformanceView(),
  }))
end

function onCloseClicked()
  panel.close()
end

function onOpen(_context)
  panel.setWantsSecondTicks(true)
  for _, m in pairs(monitors) do
    if m.attach then m.attach(render) end
  end
  render()
end

function update()
  for _, m in pairs(monitors) do
    if m.tick then m.tick() end
  end
  if apps and apps.tick then apps.tick() end
  processes = (apps and apps.getProcesses) and apps.getProcesses() or {}
  render()
end

function onIpc(event, _payload)
  if event == "open" or event == "toggle" then
    render()
  end
end
