local Level = require "Game.Levels.Level"
local MenuLevel = setmetatable({}, {__index = Level})
MenuLevel.__index = MenuLevel

function MenuLevel:load()
    MenuLevel.background = love.graphics.newImage("Resources/Pictures/Menu.png")
    MenuLevel.background:setFilter("nearest", "nearest")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    musicManager:playBackgroundMusic(MusicEnum.Test)
    MenuLevel.progress = 0
end
function MenuLevel:update(dt)
    local SPEED = 70
    if love.keyboard.isDown("down") then
        MenuLevel.progress = MenuLevel.progress + SPEED * dt
        if (MenuLevel.progress > 100) then
            MenuLevel.progress = 100
        end
        print("Progress: " .. MenuLevel.progress)
    end
end
function MenuLevel:draw()
    love.graphics.draw(MenuLevel.background, 0, 0)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 70, 200, MenuLevel.progress, 20)
    love.graphics.setColor(1, 1, 1)

end
function MenuLevel:unload()
end

return MenuLevel