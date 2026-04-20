local TextButton = require("Game.UI.Button.TextButton")

local ClickTextButton = setmetatable({}, TextButton)
ClickTextButton.__index = ClickTextButton

local FontLoader = require("Game.Fonts.FontLoader")
local fontLoader = FontLoader:getInstance()

local InputManager = require("Game.Input.InputManager")
function ClickTextButton.new(x, y, width, height, onComplete, color, text)
    local self = setmetatable({}, ClickTextButton)
    self.new(x, y, width, height)
    self.onComplete = onComplete
    self.isClicked = 0
    self.color = color or {r = 1, g = 1, b = 1, a = 1}
    self.centerX = x + width / 2
    self.centerY = y + height / 2
    self.text = text or ""
    self.infocus = false
    return self
end

function ClickTextButton:update(dt)
    if self.infocus and InputManager:isEventRightKeyPressed() and not self.isClicked then
        self.isClicked = true
        if self.onComplete then 
            self.onComplete()
        end
    else
        self.isClicked = false
    end
end

function ClickTextButton:draw(scale, offsetX, offsetY)
    local prevLineWidth = love.graphics.getLineWidth()
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    local borderRadius = math.min(8, self.progress) + self.defaultRoundedness

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
    love.graphics.rectangle(
        "fill",
        self.x, 
        self.y,
        0,
        self.height,
        self.defaultRoundedness,
        self.defaultRoundedness
    )
    love.graphics.pop()
    love.graphics.push()
    local defaultFont = love.graphics.getFont()
    local font = fontLoader:loadFont("Itim", 18 * scale)
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