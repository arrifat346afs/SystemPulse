--!nonstrict
-- GPU monitor detail view.

local M = {}

function M.build()
  return ui.column({ flexGrow = 1, gap = 8 }, {
    ui.label({ text = "GPU", fontSize = 18, fontWeight = "bold" }),
    ui.label({ text = "GPU details go here.", color = "on_surface_variant" }),
  })
end

return M
