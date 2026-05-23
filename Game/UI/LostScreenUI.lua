-- USAGE EXAMPLE:
-- 1. Require and instantiate the screen UI in your level's load function:
--      local LostScreenUI = require("Game.UI.LostScreenUI")
--      self.lostScreen = LostScreenUI.new(function() print("Retry clicked!") end)
--
-- 2. Call the trigger method when you want it to pop up:
--      self.lostScreen:trigger("You Lost!", "Retry")
--
-- 3. Update and draw in your level's update/draw loops:
--      self.lostScreen:update(dt)
--      self.lostScreen:draw(scale, fontScale, offsetX, offsetY)

local UIElement = require("Game.UI.UIElement")
local LostBanner = require("Game.UI.Banner.LostBanner")
local HoldTextButton = require("Game.UI.Button.HoldTextButton")

local LostScreenUI = setmetatable({}, {__index = UIElement})
LostScreenUI.__index = LostScreenUI

function LostScreenUI.new(onComplete)
    local self = setmetatable(UIElement:new(0, 0, BASE_W, BASE_H), LostScreenUI)
    
    self.lostBanner = LostBanner.new("Resources/Images/Lost_banner.png", "You Lost!")
    
    -- First Button (Continue)
    self.holdButton = HoldTextButton:new(0, 0, 80, 20, onComplete, {r = 1, g = 0.8, b = 0, a = 1}, "Retry")
    self.holdButton:setFocus(true)
    self.lostBanner:addChild(self.holdButton)
    
    -- Second Button (Main Menu)
    self.mainMenuButton = HoldTextButton:new(0, 0, 80, 20, function()
        local LevelEnum = require("Game.Levels.LevelEnum")
        local GameManager = require("Game.GameManager")
        GameManager:loadLevel(LevelEnum.StartMenu)
    end, {r = 0.8, g = 0.8, b = 0.8, a = 1}, "Main Menu")
    self.mainMenuButton:setFocus(false)
    self.lostBanner:addChild(self.mainMenuButton)
    
    return self
end

-- Pass text here to update it before triggering the animation
function LostScreenUI:trigger(bannerText, buttonText)
    if bannerText then
        self.lostBanner.text = bannerText
    end
    if buttonText then
        self.holdButton.text = buttonText
    end
    self.lostBanner:trigger()
end

function LostScreenUI:update(dt)
    if not self.lostBanner.active then return end
    
    self.lostBanner:update(dt)
    
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

function LostScreenUI:draw(scale, fontScale, offsetX, offsetY)
    self.lostBanner:draw(scale, fontScale, offsetX, offsetY)
end

return LostScreenUI
