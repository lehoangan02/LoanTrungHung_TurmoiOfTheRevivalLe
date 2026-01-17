local FontLoader = {}
FontLoader.__index = FontLoader

local instance = nil
function FontLoader:getInstance()
    if instance == nil then
        instance = setmetatable({}, FontLoader)
    end
    return instance
end

function FontLoader:loadDefaultFonts()
    self.defaultFont = love.graphics.newFont("Resources/Fonts/Itim/Itim-Regular.ttf", 16)
    return self.defaultFont
end

function FontLoader:loadFont(name, fontSize)
    local fontSize = fontSize or 16
    local fontPath = "Resources/Fonts/" .. name .. "/" .. name .. "-Regular.ttf"
    local font = love.graphics.newFont(fontPath, fontSize)
    return font
end

return FontLoader