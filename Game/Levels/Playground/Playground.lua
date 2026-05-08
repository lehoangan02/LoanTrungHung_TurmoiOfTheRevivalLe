local Level = require("Game.Levels.Level")
local PlayGround = setmetatable({}, {__index = Level})
PlayGround.__index = PlayGround

local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")

function PlayGround:load()
    -- local DialogCloud = require("Game.Components.DialogCloud")
    -- self.dialog = DialogCloud.new(
    --     "Chiến thắng!",
    --     50,
    --     50,
    --     100,
    --     100
    -- )

    local WinBanner = require("Game.Components.WinBanner")
    self.winBanner = WinBanner.new("Resources/Images/Win_banner.png", "You Won!")
    
    local HoldTextButton = require("Game.UI.Button.HoldTextButton")
    self.holdButton = HoldTextButton:new(0, 0, 80, 20, function()
        print("Banner Button Held!")
    end, {r = 1, g = 0.8, b = 0, a = 1}, "Continue")
    
    -- Set infocus to true so it reacts to 'D' (or whatever LeftRudder is mapped to)
    self.holdButton:setFocus(true)
    
    -- Link it to the banner!
    self.winBanner:addChild(self.holdButton)
end

function PlayGround:update(dt)
    local InputManager = require("Game.Input.InputManager")
    if (InputManager:isEventFKeyPressed()) then
        -- print("F key pressed, starting dialogue")
        -- self.dialog:startDialogue()
        self.winBanner:trigger()
    end
    -- self.dialog:update(dt)
    self.winBanner:update(dt)
    return LevelEnum.Nothing
end

function PlayGround:draw(windowWidth, windowHeight)
    love.graphics.clear(0.8, 0.8, 0.8, 0.5)
    local scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode = ResizeWindowTransform.getTransform(windowWidth, windowHeight, BASE_W, BASE_H)
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)
    -- self.dialog:draw(scale, fontScale, offsetX, offsetY)
    self.winBanner:draw(scale, fontScale, offsetX, offsetY)
    love.graphics.pop()
    
end

function PlayGround:unload()
    print("PlayGround Level Unloaded")
end

return PlayGround