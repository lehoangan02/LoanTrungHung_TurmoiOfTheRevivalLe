-- USAGE EXAMPLE (as seen in PlaygroundLevel):
-- 1. Require and instantiate the screen UI in your level's load function:
--      local WinScreenUI = require("Game.UI.WinScreenUI")
--      self.winScreen = WinScreenUI.new(function() print("Continue clicked!") end)
--
-- 2. Call the trigger method when you want it to pop up:
--      self.winScreen:trigger("You won!", "Next Level")
--
-- 3. Update and draw in your level's update/draw loops:
--      self.winScreen:update(dt)
--      self.winScreen:draw(scale, fontScale, offsetX, offsetY)

local UIElement = require("Game.UI.UIElement")
local WinBanner = require("Game.UI.Banner.WinBanner")
local HoldTextButton = require("Game.UI.Button.HoldTextButton")

local WinScreenUI = setmetatable({}, {__index = UIElement})
WinScreenUI.__index = WinScreenUI

function WinScreenUI.new(onComplete)
    local self = setmetatable(UIElement:new(0, 0, BASE_W, BASE_H), WinScreenUI)
    
    self.winBanner = WinBanner.new("Resources/Images/Win_banner.png", "You Won!")
    
    -- First Button (Continue)
    self.holdButton = HoldTextButton:new(0, 0, 80, 20, onComplete, {r = 1, g = 0.8, b = 0, a = 1}, "Continue")
    self.holdButton:setFocus(true)
    self.winBanner:addChild(self.holdButton)
    
    -- Second Button (Main Menu)
    self.mainMenuButton = HoldTextButton:new(0, 0, 80, 20, function()
        -- You can replace this with your actual scene transition logic
        print("Returning to Main Menu...")
    end, {r = 0.8, g = 0.8, b = 0.8, a = 1}, "Main Menu")
    self.mainMenuButton:setFocus(false)
    self.winBanner:addChild(self.mainMenuButton)
    
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
    if not self.winBanner.active then return end
    
    self.winBanner:update(dt)
    
    -- Handle focus switching between the buttons
    local InputManager = require("Game.Input.InputManager")
    if InputManager:isEventUpKeyPressed() or InputManager:isEventDownKeyPressed() then
        if self.holdButton.infocus then
            self.holdButton:setFocus(false)
            self.mainMenuButton:setFocus(true)
        else
            self.holdButton:setFocus(true)
            self.mainMenuButton:setFocus(false)
        end
    end
end

function WinScreenUI:draw(scale, fontScale, offsetX, offsetY)
    self.winBanner:draw(scale, fontScale, offsetX, offsetY)
end

return WinScreenUI
