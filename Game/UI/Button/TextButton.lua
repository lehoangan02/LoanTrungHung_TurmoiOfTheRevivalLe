local UIElement = require("Game.UI.UIElement")

local TextuButton = setmetatable({}, UIElement)
TextuButton.__index = TextuButton

local FontLoader = require("Game.Fonts.FontLoader")
local fontLoader = FontLoader:getInstance()

local InputManager = require("Game.Input.InputManager")

function TextuButton:new(x, y, width, height, onComplete, color, text)
    self.new(x, y, width, height)
end

function TextuButton:setPosition(x, y)
    self.x = x
    self.y = y
    self.centerX = x + self.width / 2
    self.centerY = y + self.height / 2
end

function TextuButton:update(dt)
    error("Abstract function must be implemented")
end

function TextuButton:draw(scale, offsetX, offsetY)
    error("Abstract function must be implemented")
end
function TextuButton:setFocus(isFocused)
    self.infocus = isFocused
end