local Level = require("Game.Levels.Level")
local NgocHoi = setmetatable({}, Level)
NgocHoi.__index = NgocHoi

local FontLoader = require("Game.Fonts.FontLoader")

function NgocHoi:load()
    NgocHoi.wheel = love.graphics.newImage("Resources/Images/wheel.png")
    NgocHoi.siege_tower = love.graphics.newImage("Resources/Images/siege_tower.png")
end

function NgocHoi:update(dt)
    local LevelEnum = require("Game.Levels.LevelEnum")
    return LevelEnum.Nothing
end

function NgocHoi:draw(windowWidth, windowHeight)
    love.graphics.clear(1, 1, 1, 1)
    love.graphics.draw(NgocHoi.siege_tower, 100, 60)
    love.graphics.draw(NgocHoi.wheel, 110, 200)

    love.graphics.push()
    local fontLoader = FontLoader:getInstance()
    local defaultFont = love.graphics.getFont()
    local font = fontLoader:loadFont("Texturina", 20)
    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(font)
    love.graphics.print("Ngoc Hoi, 1789", 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function NgocHoi:unload()
    
end

return NgocHoi