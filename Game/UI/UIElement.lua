local UIElement = {}
UIElement.__index = UIElement

function UIElement:new(x, y, width, height)
    local self = setmetatable({}, UIElement)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.numCellX = numCellX
    self.numCelly = numCellY
    self.cellWidthX = width / numCellX
    self.cellWidthY = height / numCellY
    self.grid = {}
    for i = 1, numCellY do
        self.grid[i] = {}
        for j = 1, numCellX do
            self.grid[i][j] = nil
        end
    end
    return self
end



function UIElement:draw()
    error("UIElement:draw() not implemented")
end

return UIElement