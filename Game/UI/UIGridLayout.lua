local UIGridLayout = {}
UIGridLayout.__index = UIGridLayout

local InputManager = require("Game.Input.InputManager")

function UIGridLayout:new(x, y, width, height, rows, cols)
    local self = setmetatable({}, UIGridLayout)
    self.x = x
    self.y = y
    self.rows = rows
    self.cols = cols
    self.width = width
    self.height = height
    self.cellWidth = width / cols
    self.cellHeight = height / rows
    self.grid = {}
    for i = 1, rows do
        self.grid[i] = {}
        for j = 1, cols do
            self.grid[i][j] = nil
        end
    end
    self.focus = {x = 1, y = 1}
    return self
end

function UIGridLayout:addUIElement(element, cellIndexX, cellIndexY)
    if cellIndexX < 1 or cellIndexX > self.cols or cellIndexY < 1 or cellIndexY > self.rows then
        error("Cell index out of bounds")
    end
    self.grid[cellIndexY][cellIndexX] = element
    local centerX = self.x + (cellIndexX - 1) * self.cellWidth + self.cellWidth
    local leftX = centerX - element.width
    local centerY = self.y + (cellIndexY - 1) * self.cellHeight + self.cellHeight
    local topY = centerY - element.height
    element:setPosition(leftX, topY)
end

function UIGridLayout:update(dt)
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
        if self.focus.x > self.cols then
            self.focus.x = self.cols
        end
        self.grid[self.focus.y][self.focus.x]:setFocus(true)
    elseif InputManager:isEventUpKeyPressed() then
        self.grid[self.focus.y][self.focus.x]:setFocus(false)
        self.focus.y = self.focus.y - 1
        if self.focus.y < 1 then
            self.focus.y = 1
        end
        self.grid[self.focus.y][self.focus.x]:setFocus(true)
    elseif InputManager:isEventDownKeyPressed() then
        self.grid[self.focus.y][self.focus.x]:setFocus(false)
        self.focus.y = self.focus.y + 1
        if self.focus.y > self.rows then
            self.focus.y = self.rows
        end
        self.grid[self.focus.y][self.focus.x]:setFocus(true)
    end
    for i = 1, self.rows do
        for j = 1, self.cols do
            local element = self.grid[i][j]
            element:update(dt)
        end
    end
end

function UIGridLayout:draw()
    for i = 1, self.rows do
        for j = 1, self.cols do
            local element = self.grid[i][j]
            if element then
                element:draw()
            end
        end
    end
end

return UIGridLayout