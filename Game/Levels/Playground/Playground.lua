local Level = require("Game.Levels.Level")
local PlayGround = setmetatable({}, {__index = Level})
PlayGround.__index = PlayGround

local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")

function PlayGround:load()
    -- local DialogCloud = require("Game.Components.DialogCloud")
    -- self.dialog = DialogCloud.new(
    --     "Chiến thắng!",
    local DialogCloud = require("Game.Components.DialogCloud")
    self.dialog = DialogCloud.new(
        "Chiến thắng!",
        50,
        50,
        100,
        100
    )

    local WinScreenUI = require("Game.UI.WinScreenUI")
    self.winScreen = WinScreenUI.new(function()
        print("Banner Button Held!")
    end)
end

function PlayGround:update(dt)
    local InputManager = require("Game.Input.InputManager")
    if (InputManager:isEventFKeyPressed()) then
        print("F key pressed, starting dialogue")
        -- self.dialog:startDialogue()
        self.winScreen:trigger("You won!", "Next Level")
    end
    self.dialog:update(dt)
    self.winScreen:update(dt)
    return LevelEnum.Nothing
end

function PlayGround:draw(windowWidth, windowHeight)
    -- love.graphics.clear(0.8, 0.8, 0.8, 0.5)
    love.graphics.clear(1, 1, 1, 1)
    local scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode = ResizeWindowTransform.getTransform(windowWidth, windowHeight, BASE_W, BASE_H)
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)
    self.dialog:draw(scale, fontScale, offsetX, offsetY)
    self.winScreen:draw(scale, fontScale, offsetX, offsetY)
    love.graphics.pop()
    
end

function PlayGround:unload()
    print("PlayGround Level Unloaded")
end

return PlayGround