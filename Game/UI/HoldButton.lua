local HoldButton = {}
HoldButton.__index = HoldButton

function HoldButton:new(x, y , width, height, onComplete)
    local self = setmetatable({}, HoldButton)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.onComplete = onComplete
    self.progress = 0
    return self
end

function HoldButton:update(dt, isHeld)
    local SPEED = 230
    local DECAY_SPEED = 20
    local remaining = (100 - self.progress) / 100
    if remaining < 0.3 then
        remaining = 0.3
    end
    if isHeld then
        self.progress = self.progress + SPEED * dt * remaining
        if (self.progress >= 100) then
            self.progress = 100
            if self.onComplete then
                self.onComplete()
            end
        end
    else
        self.progress = self.progress - DECAY_SPEED * dt
        if (self.progress < 0) then
            self.progress = 0
        end
    end
end

function HoldButton:draw()
    love.graphics.setColor(1, 0, 0)
    local r = math.min(8, self.progress / 2)
    love.graphics.rectangle("fill", self.x, self.y, self.progress / 100 * self.width, self.height, r)
    love.graphics.setColor(1, 1, 1)
end
return HoldButton