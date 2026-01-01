local Level = require "Game.Levels.Level"
local BallDropLevel = setmetatable({}, {__index = Level})
BallDropLevel.__index = BallDropLevel

function BallDropLevel:load()
    local sti = require "Game/Libraries/sti"
    BallDropLevel.gameMap = sti("Game/Maps/testMap.lua")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    musicManager:playBackgroundMusic(MusicEnum.Test)
    BallDropLevel.progress = 0
end
function BallDropLevel:update(dt)
    
end
function BallDropLevel:draw()
    BallDropLevel.gameMap:draw()
end
function BallDropLevel:unload()
end

return BallDropLevel