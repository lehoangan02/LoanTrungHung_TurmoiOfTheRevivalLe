local Level = require "Game.Levels.Level"
local MenuLevel = setmetatable({}, {__index = Level})
MenuLevel.__index = MenuLevel

local Color = require("Game.UI.Color")

function MenuLevel:load()
    MenuLevel.background = love.graphics.newImage("Resources/Images/MenuScreen.png")
    MenuLevel.background:setFilter("nearest", "nearest")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    -- musicManager:playBackgroundMusic(MusicEnum.Test)
    print("Menu Level loaded")
    local HoldTextButton = require("Game.UI.HoldTextButton")
    MenuLevel.startButton = HoldTextButton:new(70, 200, 100, 20, function()
        print("Start Button Completed")
    end, Color.Red, "START")
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
    -- draw black helloworld text
    

end
function MenuLevel:unload()
end

return MenuLevel