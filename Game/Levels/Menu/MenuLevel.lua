local Level = require "Game.Levels.Level"
local MenuLevel = setmetatable({}, {__index = Level})
MenuLevel.__index = MenuLevel

function MenuLevel:load()
    MenuLevel.background = love.graphics.newImage("Resources/Images/Menu.png")
    MenuLevel.background:setFilter("nearest", "nearest")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    -- musicManager:playBackgroundMusic(MusicEnum.Test)
    print("Menu Level loaded")
    local HoldButton = require("Game.UI.HoldButton")
    MenuLevel.startButton = HoldButton:new(70, 200, 100, 20, function()
        print("Start Button Completed")
    end)
end
function MenuLevel:update(dt)
    if love.keyboard.isDown("down") then
        MenuLevel.startButton:update(dt, true)
    else
        MenuLevel.startButton:update(dt, false)
    end
    local LevelEnum = require("Game.Levels.LevelEnum")
    return LevelEnum.Nothing
end
function MenuLevel:draw()
    love.graphics.draw(MenuLevel.background, 0, 0)
    MenuLevel.startButton:draw()
end
function MenuLevel:unload()
end

return MenuLevel