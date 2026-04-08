-- DrawText: helper for drawing text in screen space from logical (scaled) coordinates.
-- Use this OUTSIDE of push/scale/pop blocks, matching how HoldTextButton draws text.
--
-- Usage:
--   DrawText.print(text, x, y, scale, offsetX, offsetY, options)
--
-- options (all optional):
--   fontName  string  font to load via FontLoader, default "Itim"
--   fontSize  number  logical font size (multiplied by scale internally), default 16
--   color     table   {r, g, b, a}, default black
--   align     string  "left" | "center" | "right", default "left"
--   valign    string  "top" | "middle" | "bottom", default "top"

local FontLoader = require("Game.Fonts.FontLoader")
local fontLoader = FontLoader:getInstance()

local DrawText = {}

function DrawText.print(text, x, y, scale, offsetX, offsetY, options)
    options  = options or {}
    local fontName = options.fontName or "Itim"
    local fontSize = options.fontSize or 16
    local color    = options.color    or {r = 0, g = 0, b = 0, a = 1}
    local align    = options.align    or "left"
    local valign   = options.valign   or "top"

    local prevFont = love.graphics.getFont()
    local font = fontLoader:loadFont(fontName, fontSize * scale)
    love.graphics.setFont(font)
    love.graphics.setColor(color.r, color.g, color.b, color.a)

    -- Convert logical position to screen space (mirrors offsetX + centerX * scale pattern)
    local screenX = offsetX + x * scale
    local screenY = offsetY + y * scale

    local textWidth  = font:getWidth(text)
    local textHeight = font:getHeight()

    if align == "center" then
        screenX = screenX - textWidth / 2
    elseif align == "right" then
        screenX = screenX - textWidth
    end

    if valign == "middle" then
        screenY = screenY - textHeight / 2
    elseif valign == "bottom" then
        screenY = screenY - textHeight
    end

    love.graphics.print(text, math.floor(screenX), math.floor(screenY))

    love.graphics.setFont(prevFont)
    love.graphics.setColor(1, 1, 1, 1)
end

return DrawText
