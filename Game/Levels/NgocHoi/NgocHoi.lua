local Level = require("Game.Levels.Level")
local NgocHoi = setmetatable({}, Level)
NgocHoi.__index = NgocHoi

local FontLoader = require("Game.Fonts.FontLoader")

function NgocHoi:load()

    NgocHoi.TitleTime = 2.5
    NgocHoi.TitleAlpha = 1
    NgocHoi.FadeSpeed = 0.9
    NgocHoi.TitleTimer = 0

    NgocHoi.cameraX = 120
    NgocHoi.cameraY = -65
    local camera = require("Game.Libraries.camera")
    NgocHoi.cam = camera()
    NgocHoi.cam:lookAt(NgocHoi.cameraX, NgocHoi.cameraY)

    NgocHoi.wheel = love.graphics.newImage("Resources/Images/wheel.png")
    NgocHoi.wheel:setFilter("nearest", "nearest")
    NgocHoi.wheelRotation = 0
    NgocHoi.siege_tower = love.graphics.newImage("Resources/Images/siege_tower.png")
    NgocHoi.siege_tower:setFilter("nearest", "nearest")
    NgocHoi.straw_straight = love.graphics.newImage("Resources/Images/Straw_straight.png")
    NgocHoi.straw_straight:setFilter("nearest", "nearest")
    NgocHoi.straw = love.graphics.newImage("Resources/Images/Straw.png")
    NgocHoi.straw:setFilter("nearest", "nearest")
    NgocHoi.ground = love.graphics.newImage("Resources/Images/Ground.png")
    NgocHoi.ground:setFilter("nearest", "nearest")
    NgocHoi.soldier = love.graphics.newImage("Resources/Images/Soldier-24ex.png")
    NgocHoi.soldier:setFilter("nearest", "nearest")
    NgocHoi.groundWidth = NgocHoi.ground:getWidth()
    NgocHoi.groundPositionX = 0
end

function NgocHoi:update(dt)
    local LevelEnum = require("Game.Levels.LevelEnum")
    NgocHoi.TitleTimer = NgocHoi.TitleTimer + dt
    if (NgocHoi.TitleTimer > NgocHoi.TitleTime) then
        NgocHoi.TitleAlpha = NgocHoi.TitleAlpha - NgocHoi.FadeSpeed * dt
        if (NgocHoi.TitleAlpha < 0) then
            NgocHoi.TitleAlpha = 0
        end
        local cameraTargetY = 120
        local offsetY = cameraTargetY - NgocHoi.cameraY
        NgocHoi.cameraY = NgocHoi.cameraY + offsetY * 0.7 * dt
    end
    local rotationSpeed = 120
    NgocHoi.wheelRotation = NgocHoi.wheelRotation + rotationSpeed * dt
    NgocHoi.cam:lookAt(NgocHoi.cameraX, NgocHoi.cameraY)
    NgocHoi.groundPositionX = NgocHoi.groundPositionX - 17 * dt
    if (NgocHoi.groundPositionX <= -NgocHoi.groundWidth) then
        NgocHoi.groundPositionX = NgocHoi.groundPositionX + NgocHoi.groundWidth
    end
    return LevelEnum.Nothing
end

function NgocHoi:draw(windowWidth, windowHeight)
    love.graphics.clear(1, 1, 1, 1)

    local scale = math.min(windowHeight / (BASE_H or 240), windowWidth / (BASE_W or 240))
    love.graphics.scale(scale, scale)
    love.graphics.translate((windowWidth / 2) * (1-scale) / scale, (windowHeight / 2) * (1-scale) / scale)

    NgocHoi.cam:attach()
        local wheelWidth = NgocHoi.wheel:getWidth()
        local wheelHeight = NgocHoi.wheel:getHeight()
        love.graphics.draw(NgocHoi.ground, NgocHoi.groundPositionX, 200)
        love.graphics.draw(NgocHoi.ground, NgocHoi.groundPositionX + NgocHoi.groundWidth, 200)
        love.graphics.draw(NgocHoi.ground, NgocHoi.groundPositionX - NgocHoi.groundWidth, 200)
        love.graphics.draw(NgocHoi.wheel, 120 + wheelWidth/2, 203 + wheelHeight/2, math.rad(30 + NgocHoi.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
        love.graphics.draw(NgocHoi.wheel, 160 + wheelWidth/2, 203 + wheelHeight/2, math.rad(45 + NgocHoi.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
        love.graphics.draw(NgocHoi.siege_tower, 100, 65)
        love.graphics.draw(NgocHoi.wheel, 110 + wheelWidth/2, 205 + wheelHeight/2, math.rad(60 + NgocHoi.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
        love.graphics.draw(NgocHoi.wheel, 150 + wheelWidth/2, 205 + wheelHeight/2, math.rad(0 + NgocHoi.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
        
        love.graphics.draw(NgocHoi.straw, 100, 63)
        love.graphics.draw(NgocHoi.straw, 140, 63)

        love.graphics.draw(NgocHoi.soldier, 68, 182)
        love.graphics.draw(NgocHoi.straw_straight, 65, 180)
        love.graphics.draw(NgocHoi.straw_straight, 32, 181)
        love.graphics.draw(NgocHoi.straw_straight, -2, 180)
        
    NgocHoi.cam:detach()

    
 
    love.graphics.push()
    local fontLoader = FontLoader:getInstance()
    local defaultFont = love.graphics.getFont()
    local font = fontLoader:loadFont("Texturina", 20)
    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, NgocHoi.TitleAlpha)
    love.graphics.setFont(font)
    love.graphics.print("Ngoc Hoi, 1789", 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(defaultFont)
    love.graphics.pop()
end

function NgocHoi:unload()
    
end

return NgocHoi