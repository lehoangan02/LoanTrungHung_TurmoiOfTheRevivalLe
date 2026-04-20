local UIElement = require("Game.UI.UIElement")

local TextButton = setmetatable({}, UIElement)
TextButton.__index = TextButton

local FontLoader = require("Game.Fonts.FontLoader")
local fontLoader = FontLoader:getInstance()

local InputManager = require("Game.Input.InputManager")

function TextButton:new(x, y, width, height, onComplete, color, text)
    local instance = UIElement.new(self, x, y, width, height)
    instance.pad = 3
    instance.defaultRoundedness = 3
    instance.maxRoundedness = 8
    return instance
end

function TextButton:setPosition(x, y)
    self.x = x
    self.y = y
    self.centerX = x + self.width / 2
    self.centerY = y + self.height / 2
end

function TextButton:update(dt)
    error("Abstract function must be implemented")
end

function TextButton:draw(scale, offsetX, offsetY)
    error("Abstract function must be implemented")
end
function TextButton:setFocus(isFocused)
    self.infocus = isFocused
end

return TextButton