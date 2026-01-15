local Color = {}
Color.__index = Color
function Color:new(r, g, b, a)
    local self = setmetatable({}, Color)
    self.r = r
    self.g = g
    self.b = b
    self.a = a or 1
    return self
end

return Color