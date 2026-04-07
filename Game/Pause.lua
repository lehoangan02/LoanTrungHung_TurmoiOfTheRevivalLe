local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")

local OVERLAY_ALPHA = 0.5
local Pause = {}
Pause.__index = Pause

function Pause.new(windowWidth, windowHeight)
    local self = setmetatable({}, Pause)
    self.isPaused = false
    self.panelY = -200
    self.targetPanelY = (BASE_H - 200) / 2
    self.panelX = (BASE_W - 300) / 2
    self.panelWidth = 300
    self.panelHeight = 200
    self.windowWidth = windowWidth
    self.windowHeight = windowHeight
    self.options = {"Resume", "Quit"}
    self.selected = 1
    self.animating = false
    self.animationTime = 0
    self.animationDuration = 0.5
    self.animationCurrentDuration = 0.5
    self.overlayAlpha = 0
    self.fadingIn = false
    return self
end

function Pause:draw(windowWidth, windowHeight)
    love.graphics.push()
    local scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode = ResizeWindowTransform.getTransform(windowWidth, windowHeight, BASE_W, BASE_H)
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    -- Overlay
    love.graphics.setColor(0, 0, 0, self.overlayAlpha)
    love.graphics.rectangle("fill", 0, 0, BASE_W, BASE_H)
    -- Panel
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", self.panelX, self.panelY, self.panelWidth, self.panelHeight, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Paused", self.panelX, self.panelY + 20, self.panelWidth, "center")
    -- Options
    for i, option in ipairs(self.options) do
        if i == self.selected then
            love.graphics.setColor(1, 1, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.printf(option, self.panelX, self.panelY + 60 + (i-1)*40, self.panelWidth, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function Pause:toggle()
    self.isPaused = not self.isPaused
    if (self.isPaused) then self:movePanelDown()
    else self:movePanelUp() end
end

local function easeOutCubic(t)
    return 1 - (1 - t)^3
end

function Pause:movePanelDown()
    self.animating = true
    self.animationTime = 0
    self.animationCurrentDuration = self.animationDuration
    self.fadingIn = true
    self.panelY = -self.panelHeight
end

function Pause:movePanelUp()
    self.animating = true
    self.animationTime = 0
    self.animationCurrentDuration = self.animationDuration * 0.4
    self.fadingIn = false
    self.panelStartY = self.panelY
end

function Pause:update(dt)
    if self.animating then
        self.animationTime = self.animationTime + dt
        local t = math.min(self.animationTime / self.animationCurrentDuration, 1)
        if self.fadingIn then
            local ease = easeOutCubic(t)
            self.panelY = -self.panelHeight + (self.targetPanelY + self.panelHeight) * ease
            self.overlayAlpha = OVERLAY_ALPHA * ease
        else
            self.panelY = self.panelStartY + (-self.panelHeight - self.panelStartY) * t
            self.overlayAlpha = OVERLAY_ALPHA * (1 - t)
        end
        if t >= 1 then
            self.panelY = self.fadingIn and self.targetPanelY or -self.panelHeight
            self.overlayAlpha = self.fadingIn and OVERLAY_ALPHA or 0
            self.animating = false
        end
    end
end

return Pause
