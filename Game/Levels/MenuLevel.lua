local Level = require "Game.Levels.Level"
local MenuLevel = setmetatable({}, {__index = Level})
MenuLevel.__index = MenuLevel

function MenuLevel.load()
    MenuLevel.background = love.graphics.newImage("Resources/Pictures/Menu.png")
    MenuLevel.background:setFilter("nearest", "nearest")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    musicManager:playBackgroundMusic(MusicEnum.Test)
end
function MenuLevel.update(dt)
end
function MenuLevel.draw()
    love.graphics.draw(MenuLevel.background, 0, 0)
end
function MenuLevel.unload()
end

return MenuLevel