local Level = require "Game.Levels.Level"
local MenuLevel = setmetatable({}, {__index = Level})
MenuLevel.__index = MenuLevel

local Color = require("Game.UI.Color")
local HoldTextButton = require("Game.UI.HoldTextButton")
local UIGridLayout = require("Game.UI.UIGridLayout")

function MenuLevel:load()
    MenuLevel.background = love.graphics.newImage("Resources/Images/MenuScreen.png")
    MenuLevel.background:setFilter("nearest", "nearest")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    -- musicManager:playBackgroundMusic(MusicEnum.Test)
    print("Menu Level loaded")
    MenuLevel.startButton = HoldTextButton:new(70, 200, 100, 20, function()
        print("Start Button Completed")
    end, Color:new(200/255, 200/255, 200/255, 1), "START")
    MenuLevel.continueButton = HoldTextButton:new(70, 250, 100, 20, function()
        print("Continue Button Completed")
    end, Color:new(200/255, 200/255, 200/255, 1), "CONTINUE")
    MenuLevel.buttonGrid = UIGridLayout:new(70, 155, 100, 70, 2, 1)
    MenuLevel.buttonGrid:addUIElement(MenuLevel.startButton, 1, 1)
    MenuLevel.buttonGrid:addUIElement(MenuLevel.continueButton, 1, 2)
end
function MenuLevel:update(dt) 
    local LevelEnum = require("Game.Levels.LevelEnum")
    MenuLevel.buttonGrid:update(dt)
    return LevelEnum.Nothing
end
function MenuLevel:draw()
    love.graphics.draw(MenuLevel.background, 0, 0)
    MenuLevel.buttonGrid:draw()
    local FontLoader = require("Game.Fonts.FontLoader")
    local fontLoader = FontLoader:getInstance()
    local font = fontLoader:loadFont("BirthstoneBounce", 30)
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 1)
    local centerX = love.graphics.getWidth() / 2
    local text = "Loạn Trung Hưng"
    local textWidth = font:getWidth(text)
    love.graphics.print(text, centerX - textWidth / 2, 10)
    love.graphics.setColor(1, 1, 1, 1)

end
function MenuLevel:unload()
end

return MenuLevel