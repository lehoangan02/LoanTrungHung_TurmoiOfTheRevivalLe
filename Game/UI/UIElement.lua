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
    error("UIElement:update() not implemented")
end

function UIElement:setPosition(x, y)
    error("UIElement:setPosition() not implemented")
end

function UIElement:draw()
    error("UIElement:draw() not implemented")
end

return UIElement