--!nonstrict
-- A Task Manager style panel: a sidebar of category tabs on the left, and the
-- selected category's detail view on the right. Each monitor's detail view
-- lives in its own module under monitors/ (see require below).

local cpu = require("./monitors/cpu.luau")
local ram = require("./monitors/ram.luau")
local disk = require("./monitors/disk.luau")
local network = require("./monitors/network.luau")
local gpu = require("./monitors/gpu.luau")

local monitors = {
  cpu = cpu,
  ram = ram,
  disk = disk,
  network = network,
  gpu = gpu,
}

local tab = "cpu"

local function setTab(name)
  tab = name
  render()
end

local function sidebarItem(id, label, glyph)
  return ui.button({
    key = id,
    text = label,
    glyph = glyph,
    variant = "ghost",
    selected = tab == id,
    contentAlign = "start",
    onClick = function() setTab(id) end,
  })
end

local function buildSidebar()
  return ui.column({ width = 160, gap = 4 }, {
    sidebarItem("cpu", "CPU", "cpu"),
    sidebarItem("ram", "RAM", "memory"),
    sidebarItem("disk", "Disk (SSD)", "database"),
    sidebarItem("network", "Network", "network"),
    sidebarItem("gpu", "GPU", "device-desktop"),
  })
end

local function buildMain()
  return ui.column({ flexGrow = 1, gap = 0 }, {
    monitors[tab].build(),
  })
end

local function render()
  panel.render(ui.column({ flexGrow = 1, gap = 12 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = "System Monitor", fontSize = 16, fontWeight = "bold", flexGrow = 1 }),
      ui.button({ glyph = "close", onClick = "onCloseClicked" }),
    }),
    ui.row({ flexGrow = 1, gap = 8, align = "stretch" }, {
      buildSidebar(),
      buildMain(),
    }),
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
  render()
end
