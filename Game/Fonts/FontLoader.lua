local FontLoader = {}
FontLoader.__index = FontLoader

local instance = nil
function FontLoader:getInstance()
    if instance == nil then
        instance = setmetatable({}, FontLoader)
    end
    return instance
end

function FontLoader:loadFont(name, fontSize)
    local fontSize = fontSize or 16
    if type(fontSize) ~= "number" or fontSize ~= fontSize then fontSize = 16 end
    fontSize = math.max(2, math.floor(fontSize))
    local fontPath = "Resources/Fonts/" .. name .. "/" .. name .. "-Regular.ttf"
    local font = love.graphics.newFont(fontPath, fontSize, "mono")
    -- font:setFilter("nearest", "nearest")
    return font
end

return FontLoader