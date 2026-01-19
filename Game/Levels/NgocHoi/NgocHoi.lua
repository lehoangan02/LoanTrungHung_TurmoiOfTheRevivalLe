local Level = require("Game.Levels.Level")
local NgocHoi = setmetatable({}, Level)
NgocHoi.__index = NgocHoi

local FontLoader = require("Game.Fonts.FontLoader")
local anim8 = require "Game/Libraries/anim8"

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
    NgocHoi.strawTimers = {0, 0, 0}
    NgocHoi.strawIntervals = {0.8, 1.3, 1.9}
    NgocHoi.strawOffsets = {0, 0, 0}


    NgocHoi.straw = love.graphics.newImage("Resources/Images/Straw.png")
    NgocHoi.straw:setFilter("nearest", "nearest")
    NgocHoi.ground = love.graphics.newImage("Resources/Images/Ground.png")
    NgocHoi.ground:setFilter("nearest", "nearest")
    NgocHoi.soldier_spritesheet = love.graphics.newImage("Resources/Images/Soldier-24-sprite-sheet.png")
    NgocHoi.soldier_spritesheet:setFilter("nearest", "nearest")
    NgocHoi.soldier_grid = anim8.newGrid(24, 37, NgocHoi.soldier_spritesheet:getWidth(), NgocHoi.soldier_spritesheet:getHeight())
    NgocHoi.soldier_animations = {}
    for i = 1, 3 do
        local anim = anim8.newAnimation(
            NgocHoi.soldier_grid('1-12', 1),
            0.2
        )
        anim:gotoFrame((i - 1) * 4 + 1)
        NgocHoi.soldier_animations[i] = anim
    end

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
    for i = 1, 3 do
        NgocHoi.soldier_animations[i]:update(dt)
    end

    for i = 1, 3 do
        NgocHoi.strawTimers[i] = NgocHoi.strawTimers[i] + dt
        if NgocHoi.strawTimers[i] >= NgocHoi.strawIntervals[i] then
            NgocHoi.strawTimers[i] = NgocHoi.strawTimers[i] - NgocHoi.strawIntervals[i]
            NgocHoi.strawOffsets[i] = math.random() < 0.5 and 0 or 2
        end
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

        NgocHoi.soldier_animations[1]:draw(NgocHoi.soldier_spritesheet, 70, 183)
        NgocHoi.soldier_animations[2]:draw(NgocHoi.soldier_spritesheet, 35, 186)
        NgocHoi.soldier_animations[3]:draw(NgocHoi.soldier_spritesheet, 0, 187)


        love.graphics.draw(NgocHoi.straw_straight, 65, 178 + NgocHoi.strawOffsets[1])
        love.graphics.draw(NgocHoi.straw_straight, 32, 180 + NgocHoi.strawOffsets[2])
        love.graphics.draw(NgocHoi.straw_straight, -2, 182 + NgocHoi.strawOffsets[3])
        
    NgocHoi.cam:detach()

    
 
    love.graphics.push()
    local fontLoader = FontLoader:getInstance()
    local defaultFont = love.graphics.getFont()
    local font = fontLoader:loadFont("Texturina", 20)
    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, NgocHoi.TitleAlpha)
    love.graphics.setFont(font)
    love.graphics.print("Ngọc Hồi, 1789", 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(defaultFont)
    love.graphics.pop()
end

function NgocHoi:unload()
    
end

return NgocHoi