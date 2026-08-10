--!nonstrict
-- Disk (SSD) monitor detail view.

local M = {}

function M.build()
  return ui.column({ flexGrow = 1, gap = 8 }, {
    ui.label({ text = "Disk (SSD)", fontSize = 18, fontWeight = "bold" }),
    ui.label({ text = "Disk details go here.", color = "on_surface_variant" }),
  })
end

return M
