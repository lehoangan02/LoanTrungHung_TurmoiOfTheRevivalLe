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

Color.White = Color:new(1, 1, 1, 1)
Color.Black = Color:new(0, 0, 0, 1)
Color.Red = Color:new(1, 0, 0, 1)
Color.Green = Color:new(0, 1, 0, 1)
Color.Blue = Color:new(0, 0, 1, 1)

return Color