--!nonstrict
-- Network monitor detail view.

local M = {}

function M.build()
  return ui.column({ flexGrow = 1, gap = 8 }, {
    ui.label({ text = "Network", fontSize = 18, fontWeight = "bold" }),
    ui.label({ text = "Network details go here.", color = "on_surface_variant" }),
  })
end

return M
