local UIElement = require("Game.UI.UIElement")
local HoldTextButton = setmetatable({}, UIElement)
HoldTextButton.__index = HoldTextButton

local FontLoader = require("Game.Fonts.FontLoader")
local fontLoader = FontLoader:getInstance()
local font = fontLoader:loadDefaultFonts()

local InputManager = require("Game.Input.InputManager")

if not font then
    error("Failed to load font in HoldTextButton")
end

function HoldTextButton:new(x, y , width, height, onComplete, color, text)
    local self = setmetatable({}, HoldTextButton)
    self.x = x or 0
    self.y = y or 0
    self.width = width
    self.height = height
    self.onComplete = onComplete
    self.progress = 0
    self.color = color or {r = 1, g = 1, b = 1, a = 1}
    self.centerX = x + width / 2
    self.centerY = y + height / 2
    self.text = text or ""
    self.infocus = false
    return self
end

function HoldTextButton:setPosition(x, y)
    self.x = x
    self.y = y
    self.centerX = x + self.width / 2
    self.centerY = y + self.height / 2
end

function HoldTextButton:setFocus(isFocused)
    self.infocus = isFocused
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

function HoldTextButton:draw()

    local pad = 3
    local borderRadius = math.min(8, self.progress / 2) + pad

    if self.infocus then
        love.graphics.setColor(0, 0, 0, 1)
    else
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
    end
    love.graphics.setLineWidth(2)
    love.graphics.rectangle(
        "line",
        self.x - pad,
        self.y - pad,
        self.width + pad * 2,
        self.height + pad * 2,
        borderRadius
    )

    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
    local r = math.min(8, self.progress / 2)
    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.progress / 100 * self.width,
        self.height,
        r
    )
    local defaultFont = love.graphics.getFont()
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 1)

    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local textX = math.floor(self.centerX - textWidth / 2)
    local textY = math.floor(self.centerY - textHeight / 2)

    love.graphics.print(self.text, textX, textY)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(defaultFont)
end

return HoldTextButton