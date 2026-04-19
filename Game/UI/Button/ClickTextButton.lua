local TextButton = require("Game.UI.Button.TextButton")

local ClickTextButton = setmetatable({}, TextButton)
ClickTextButton.__index = ClickTextButton

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

    
end