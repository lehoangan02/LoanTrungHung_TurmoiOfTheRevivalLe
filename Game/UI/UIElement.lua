local UIElement = {}
UIElement.__index = UIElement

function UIElement:new(x, y, width, height)
    local self = setmetatable({}, UIElement)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    return self
end

function UIElement:update(dt)
    error("Abstract function must be implemented!")
end

function UIElement:setPosition(x, y)
    error("Abstract function must be implemented!")
end

function UIElement:draw(scale, offsetX, offsetY)
    error("Abstract function must be implemented!")
end

return UIElement