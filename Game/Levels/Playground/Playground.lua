local Level = require("Game.Levels.Level")
local PlayGround = setmetatable({}, {__index = Level})
PlayGround.__index = PlayGround

function PlayGround:load()
    local DialogCloud = require("Game.Components.DialogCloud")
    self.dialog = DialogCloud.new(
        "Welcome to the Playground Level!",
        50,
        50,
        40,
        20
    )
end

function PlayGround:update(dt)
    local InputManager = require("Game.Input.InputManager")
    if (InputManager:isEventFKeyPressed()) then
        print("F key pressed, starting dialogue")
        self.dialog:startDialogue()
    end
    self.dialog:update(dt)
    return LevelEnum.Nothing
end

function PlayGround:draw(windowWidth, windowHeight)
    love.graphics.clear(0.2, 0.2, 0.2)
    local scale = math.min(windowWidth / BASE_W, windowHeight / BASE_H)
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.pop()
    self.dialog:draw(scale, windowWidth, windowHeight)
end

function PlayGround:unload()
    print("PlayGround Level Unloaded")
end

return PlayGround