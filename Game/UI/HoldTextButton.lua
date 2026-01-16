local HoldTextButton = {}
HoldTextButton.__index = HoldTextButton

local FontLoader = require("Game.Fonts.FontLoader")
local fontLoader = FontLoader:getInstance()
local font = fontLoader:loadFonts()

if not font then
    error("Failed to load font in HoldTextButton")
end

function HoldTextButton:new(x, y , width, height, onComplete, color, text)
    local self = setmetatable({}, HoldTextButton)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.onComplete = onComplete
    self.progress = 0
    self.color = color or {r = 1, g = 1, b = 1, a = 1}
    self.centerX = x + width / 2
    self.centerY = y + height / 2
    self.text = text or ""
    return self
end

function HoldTextButton:update(dt, isHeld)
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

function HoldTextButton:draw()
    love.graphics.push()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    local r = math.min(8, self.progress / 2)
    love.graphics.rectangle("fill", self.x, self.y, self.progress / 100 * self.width, self.height, r)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setColor(0, 0, 0, 1)
    local FontLoader = require("Game.Fonts.FontLoader")
    local fontLoader = FontLoader:getInstance()
    local font = fontLoader:loadFonts()
    love.graphics.setFont(font)
    love.graphics.print(self.text, self.centerX, self.centerY)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end
return HoldTextButton