--!nonstrict
-- A bar widget that opens a floating panel when clicked.

local label = noctalia.getConfig("label")
local glyph = noctalia.getConfig("glyph")
local showGlyph = noctalia.getConfig("show_glyph")

local clicks = 0

local function render()
  if showGlyph then
    barWidget.setGlyph(glyph)
  end
  barWidget.setText(label)
  barWidget.setTooltip(noctalia.trp("clicks", clicks))
end

function update()
  noctalia.setUpdateInterval(1000)
  render()
end

function onClick()
  clicks += 1
  render()
  noctalia.togglePanel("noctalia/example:panel")
end
