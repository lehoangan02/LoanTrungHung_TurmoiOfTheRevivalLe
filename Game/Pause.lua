local Pause = {}
Pause.__index = Pause

function Pause.new(windowWidth, windowHeight)
    local self = setmetatable({}, Pause)
    self.isPaused = false
    self.panelY = -200
    self.targetPanelY = (windowHeight - 200) / 2
    self.panelX = (windowWidth - 300) / 2
    self.panelWidth = 300
    self.panelHeight = 200
    self.windowWidth = windowWidth
    self.windowHeight = windowHeight
    self.options = {"Resume", "Quit"}
    self.selected = 1
    self.animating = false
    self.animationTime = 0
    self.animationDuration = 0.5
    self.easing = false
    return self
end

function Pause:draw()
    
    love.graphics.push()
    love.graphics.clear(1, 1, 1, 1)
    local scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode = ResizeWindowTransform.getTransform(windowWidth, windowHeight, BASE_W, BASE_H)
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    -- Overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, self.windowWidth, self.windowHeight)
    -- Panel
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Paused", panelX, panelY + 20, panelWidth, "center")
    -- Options
    for i, option in ipairs(self.options) do
        if i == self.selected then
            love.graphics.setColor(1, 1, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.printf(option, panelX, panelY + 60 + (i-1)*40, panelWidth, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function Pause:toggle()
    self.isPaused = not self.isPaused
    if (self.isPaused) then Pause:movePanelDown()
    else Pause:movePanelUp() end
end

local function easeOutCubic(t)
    return 1 - (1 - t)^3
end

function Pause:movePanelDown()
    self.animating = true
    self.animationTime = 0
    self.easing = true
    self.panelY = -self.panelHeight
end

function Pause:movePanelUp()
    self.animating = false
    self.easing = false
    self.panelY = -self.panelHeight
end

function Pause:update(dt)
    if self.animating then
        self.animationTime = self.animationTime + dt
        local t = math.min(self.animationTime / self.animationDuration, 1)
        if self.easing then
            local ease = easeOutCubic(t)
            self.panelY = -self.panelHeight + (self.targetPanelY + self.panelHeight) * ease
        end
        if t >= 1 then
            self.panelY = self.targetPanelY
            self.animating = false
        end
    end
end

return Pause
