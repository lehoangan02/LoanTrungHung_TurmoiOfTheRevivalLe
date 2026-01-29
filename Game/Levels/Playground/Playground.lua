local PlayGround = {}

local Level = require("Game.Levels.Level")
PlayGround.setmetatable({}, {__index = Level})
PlayGround.__index = PlayGround

function PlayGround:load()
    print("PlayGround Level Loaded")
end

function PlayGround:update(dt)
    return LevelEnum.Nothing
end

function PlayGround:unload()
    print("PlayGround Level Unloaded")
end

return PlayGround