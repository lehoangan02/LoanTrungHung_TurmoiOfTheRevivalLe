local UIElement = {}
UIElement.__index = UIElement

function UIElement:new(x, y, width, height)
    local instance = setmetatable({}, self)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    return instance
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