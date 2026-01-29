local Level = require("Game.Levels.Level")
local PlayGround = setmetatable({}, {__index = Level})
PlayGround.__index = PlayGround

function PlayGround:load()
    local DialogCloud = require("Game.Components.DialogCloud")
    self.dialog = DialogCloud.new(
        "Welcome to the Playground Level!",
        50,
        50,
        300,
        100
    )
end

function PlayGround:update(dt)
    self.dialog:update(dt)
    return LevelEnum.Nothing
end

function PlayGround:draw(windowWidth, windowHeight)
    self.dialog:draw()
end

function PlayGround:unload()
    print("PlayGround Level Unloaded")
end

return PlayGround