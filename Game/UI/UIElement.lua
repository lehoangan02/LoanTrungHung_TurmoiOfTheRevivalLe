local UIElement = {}
UIElement.__index = UIElement

function UIElement:new(x, y, width, height, numCellX, numCellY)
    local self = setmetatable({}, UIElement)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.numCellX = numCellX
    self.numCelly = numCellY
    self.grid = {}
    for i = 1, numCellY do
        self.grid[i] = {}
        for j = 1, numCellX do
            self.grid[i][j] = nil
        end
    end
    return self
end

function UIElement:addUIElement(element, cellIndexX, cellIndexY)
    if cellIndexX < 1 or cellIndexX > self.numCellX or cellIndexY < 1 or cellIndexY > self.numCellY then
        error("Cell index out of bounds")
    end
    self.grid[cellIndexY][cellIndexX] = element
end

function UIElement:draw()
    error("UIElement:draw() not implemented")
end

return UIElement