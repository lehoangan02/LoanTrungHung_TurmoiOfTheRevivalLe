local Level = require "Game.Levels.Level"
local MenuLevel = setmetatable({}, {__index = Level})
MenuLevel.__index = MenuLevel

local Color = require("Game.UI.Color")
local HoldTextButton = require("Game.UI.Button.HoldTextButton")
local UIGridLayout = require("Game.UI.UIGridLayout")
local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")

function MenuLevel:load()
    MenuLevel.nextLevel = nil
    MenuLevel.background = love.graphics.newImage("Resources/Images/MenuScreen.png")
    MenuLevel.background:setFilter("nearest", "nearest")
    
    MenuLevel.backgroundQuads = {}
    local bgWidth, bgHeight = MenuLevel.background:getDimensions()
    local frameWidth = 240
    local frameHeight = 240
    for i = 0, 11 do
        table.insert(MenuLevel.backgroundQuads, love.graphics.newQuad(i * frameWidth, 0, frameWidth, frameHeight, bgWidth, bgHeight))
    end
    MenuLevel.currentBgFrame = 1
    MenuLevel.bgAnimTimer = 0
    MenuLevel.bgFrameDuration = 0.1 -- Tweak this value to change animation speed
    MenuLevel.isTransitioning = false
    MenuLevel.targetLevel = nil

    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    -- musicManager:playBackgroundMusic(MusicEnum.Test)
    print("Menu Level loaded")
    MenuLevel.startButton = HoldTextButton:new(70, 200, 100, 20, function()
        print("Start Button Completed")
        MenuLevel.isTransitioning = true
        MenuLevel.targetLevel = require("Game.Levels.LevelEnum").NgocHoi
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
    
    if MenuLevel.isTransitioning then
        MenuLevel.bgAnimTimer = MenuLevel.bgAnimTimer + dt
        if MenuLevel.currentBgFrame < 12 then
            if MenuLevel.bgAnimTimer >= MenuLevel.bgFrameDuration then
                MenuLevel.bgAnimTimer = MenuLevel.bgAnimTimer - MenuLevel.bgFrameDuration
                MenuLevel.currentBgFrame = MenuLevel.currentBgFrame + 1
                if MenuLevel.currentBgFrame == 12 then
                    MenuLevel.bgAnimTimer = 0 -- Reset timer for the transition delay
                end
            end
        else
            if MenuLevel.bgAnimTimer >= 0.5 then
                MenuLevel.nextLevel = MenuLevel.targetLevel
            end
        end
    else
        MenuLevel.buttonGrid:update(dt)
    end

    if (MenuLevel.nextLevel ~= nil) then
        return MenuLevel.nextLevel
    end
    return LevelEnum.Nothing
end
function MenuLevel:draw(windowWidth, windowHeight)
    love.graphics.push()
    love.graphics.clear(1, 1, 1, 1)
    local scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode = ResizeWindowTransform.getTransform(windowWidth, windowHeight, BASE_W, BASE_H)
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    love.graphics.draw(MenuLevel.background, MenuLevel.backgroundQuads[MenuLevel.currentBgFrame], 0, 0)
    love.graphics.pop()
    if not MenuLevel.isTransitioning then
        MenuLevel.buttonGrid:draw(scale, offsetX, offsetY)
        love.graphics.push()
        local FontLoader = require("Game.Fonts.FontLoader")
        local fontLoader = FontLoader:getInstance()
        local defaultFont = love.graphics.getFont()
        local fontSize = 30 * scale
        if fontSize < 1 then fontSize = 1 end
        local font = fontLoader:loadFont("BirthstoneBounce", fontSize)
        love.graphics.setFont(font)
        love.graphics.setColor(0, 0, 0, 1)
        
        local text = "Loạn Trung Hưng"
        local textWidth = font:getWidth(text)
        love.graphics.print(text, math.floor(windowWidth / 2 - textWidth / 2), math.floor(offsetY + 6 * scale))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(defaultFont)

        love.graphics.pop()
    end
end
function MenuLevel:unload()
end

return MenuLevel