local TextButton = require("Game.UI.Button.TextButton")
local HoldTextButton = setmetatable({}, TextButton)
HoldTextButton.__index = HoldTextButton

local FontLoader = require("Game.Fonts.FontLoader")
local fontLoader = FontLoader:getInstance()

local InputManager = require("Game.Input.InputManager")

function HoldTextButton:new(x, y , width, height, onComplete, color, text)
    local instance = TextButton.new(self, x, y, width, height)
    instance.onComplete = onComplete
    instance.progress = 0
    instance.color = color or {r = 1, g = 1, b = 1, a = 1}
    instance.centerX = x + width / 2
    instance.centerY = y + height / 2
    instance.text = text or ""
    instance.infocus = false
    return instance
end

function HoldTextButton:update(dt)
    local isHeld = self.infocus and InputManager:isLeftRudderPressed()
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

function HoldTextButton:draw(scale, offsetX, offsetY)
    local prevLineWidth = love.graphics.getLineWidth()
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)
   
    local borderRadius = math.min(self.maxRoundedness, self.progress) + self.defaultRoundedness

    if self.infocus then
        love.graphics.setColor(0, 0, 0, 1)
    else
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    end
    love.graphics.setLineWidth(2)
    love.graphics.rectangle(
        "line",
        self.x - self.pad,
        self.y - self.pad,
        self.width + self.pad * 2,
        self.height + self.pad * 2,
        borderRadius,
        borderRadius
    )

    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    local r = math.min(self.maxRoundedness, self.progress)
    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.progress / 100 * self.width,
        self.height,
        r,
        r
    )
    love.graphics.pop()
    love.graphics.push()
    local defaultFont = love.graphics.getFont()
    local font = fontLoader:loadFont("Itim", 16 * scale)
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 1)

    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local screenCenterX = offsetX + self.centerX * scale
    local screenCenterY = offsetY + self.centerY * scale

    local textX = math.floor(screenCenterX - textWidth / 2)
    local textY = math.floor(screenCenterY - textHeight / 2)

    love.graphics.print(self.text, textX, textY)

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(defaultFont)
    love.graphics.setLineWidth(prevLineWidth)
end

return HoldTextButton