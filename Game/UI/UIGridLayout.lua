local UIGridLayout = {}
UIGridLayout.__index = UIGridLayout

local InputManager = require("Game.Input.InputManager")

function UIGridLayout:new(rows, cols, width, height, numCellX, numCellY)
    local self = setmetatable({}, UIGridLayout)
    self.rows = rows
    self.cols = cols
    self.width = width
    self.height = height
    self.numCellX = numCellX
    self.numCelly = numCellY
    self.cellWidth = width / numCellX
    self.cellHeight = height / numCellY
    self.grid = {}
    for i = 1, numCellY do
        self.grid[i] = {}
        for j = 1, numCellX do
            self.grid[i][j] = nil
        end
    end
    self.focus = {x = 1, y = 1}
    return self
end

function UIGridLayout:addUIElement(element, cellIndexX, cellIndexY)
    if cellIndexX < 1 or cellIndexX > self.numCellX or cellIndexY < 1 or cellIndexY > self.numCellY then
        error("Cell index out of bounds")
    end
    self.grid[cellIndexY][cellIndexX] = element
    local centerX = self.x + (cellIndexX - 1) * self.numCellX + self.cellWidth
    local leftX = centerX - element.width
    element.x = leftX
    local centerY = self.y + (cellIndexY - 1) * self.numCellY + self.cellHeight
    local topY = centerY - element.height
    element.y = topY
end

function UIGridLayout:update()
    if InputManager:isEventLeftKeyPressed() then
        self.grid[self.focus.y][self.focus.x]:setFocus(false)
        self.focus.x = self.focus.x - 1
        if self.focus.x < 1 then
            self.focus.x = 1
        end
        self.grid[self.focus.y][self.focus.x]:setFocus(true)
    elseif InputManager:isEventRightKeyPressed() then
        self.grid[self.focus.y][self.focus.x]:setFocus(false)
        self.focus.x = self.focus.x + 1
        if self.focus.x > self.numCellX then
            self.focus.x = self.numCellX
        end
        self.grid[self.focus.y][self.focus.x]:setFocus(true)
    end
end

function UIGridLayout:draw()
    for i = 1, self.numCellY do
        for j = 1, self.numCellX do
            local element = self.grid[i][j]
            if element then
                element:draw()
            end
        end
    end
end