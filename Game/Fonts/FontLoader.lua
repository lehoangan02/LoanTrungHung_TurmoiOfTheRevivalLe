local FontLoader = {}
FontLoader.__index = FontLoader

local instance = nil
function FontLoader:getInstance()
    if instance == nil then
        instance = setmetatable({}, FontLoader)
    end
    return instance
end

function FontLoader:loadFonts()
    self.defaultFont = love.graphics.newFont("Resources/Fonts/Pattaya/Pattaya-Regular.ttf", 16)
    return self.defaultFont
end

return FontLoader