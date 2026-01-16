local UIGridLayout = {}
UIGridLayout.__index = UIGridLayout

function UIGridLayout:new(rows, cols, cellWidth, cellHeight, padding)
    local self = setmetatable({}, UIGridLayout)
    self.rows = rows
    self.cols = cols
    self.cellWidth = cellWidth
    self.cellHeight = cellHeight
    self.padding = padding or 0
    self.elements = {}
    return self
end