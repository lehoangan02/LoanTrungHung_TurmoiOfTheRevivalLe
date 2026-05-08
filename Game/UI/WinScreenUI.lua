local UIElement = require("Game.UI.UIElement")
local WinBanner = require("Game.UI.WinBanner")
local HoldTextButton = require("Game.UI.Button.HoldTextButton")

local WinScreenUI = setmetatable({}, {__index = UIElement})
WinScreenUI.__index = WinScreenUI

function WinScreenUI.new(onComplete)
    local self = setmetatable(UIElement:new(0, 0, BASE_W, BASE_H), WinScreenUI)
    
    self.winBanner = WinBanner.new("Resources/Images/Win_banner.png", "You Won!")
    self.holdButton = HoldTextButton:new(0, 0, 80, 20, onComplete, {r = 1, g = 0.8, b = 0, a = 1}, "Continue")
    self.holdButton:setFocus(true)
    
    self.winBanner:addChild(self.holdButton)
    
    return self
end

-- Pass text here to update it before triggering the animation
function WinScreenUI:trigger(bannerText, buttonText)
    if bannerText then
        self.winBanner.text = bannerText
    end
    if buttonText then
        self.holdButton.text = buttonText
    end
    self.winBanner:trigger()
end

function WinScreenUI:update(dt)
    self.winBanner:update(dt)
end

function WinScreenUI:draw(scale, fontScale, offsetX, offsetY)
    self.winBanner:draw(scale, fontScale, offsetX, offsetY)
end

return WinScreenUI
