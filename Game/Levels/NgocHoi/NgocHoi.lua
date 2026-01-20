local Level = require("Game.Levels.Level")
local NgocHoi = setmetatable({}, Level)
NgocHoi.__index = NgocHoi

local FontLoader = require("Game.Fonts.FontLoader")
local anim8 = require "Game/Libraries/anim8"
local InputManager = require("Game.Input.InputManager")

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

    NgocHoi.bullet_spritesheet = love.graphics.newImage("Resources/Images/Bullet.png")
    NgocHoi.bullet_spritesheet:setFilter("nearest", "nearest")
    NgocHoi.bullet_grid = anim8.newGrid(50, 9, NgocHoi.bullet_spritesheet:getWidth(), NgocHoi.bullet_spritesheet:getHeight())
    NgocHoi.bullet_animation = anim8.newAnimation(NgocHoi.bullet_grid('1-3', 1), 0.1, 'pauseAtEnd')
    NgocHoi.bulletX = 185
    NgocHoi.bulletY = 110
    NgocHoi.TimeBullet1 = 6
    NgocHoi.Bullet1Fired = false
    NgocHoi.TimeBullet2 = 7
    NgocHoi.Bullet2Fired = false
    NgocHoi.TimeBullet3 = 7.5
    NgocHoi.Bullet3Fired = false
    NgocHoi.BulletTimer = 0

    NgocHoi.missed_bullet_spritesheet = love.graphics.newImage("Resources/Images/Missed_bullet.png")
    NgocHoi.missed_bullet_spritesheet:setFilter("nearest", "nearest")
    NgocHoi.missed_bullet_grid = anim8.newGrid(240, 3, NgocHoi.missed_bullet_spritesheet:getWidth(), NgocHoi.missed_bullet_spritesheet:getHeight())
    NgocHoi.missed_bullet_animation = anim8.newAnimation(NgocHoi.missed_bullet_grid('1-3', 1), 0.1, 'pauseAtEnd')
    NgocHoi.missed_bulletX = 0
    NgocHoi.missed_bulletY = 120
    NgocHoi.missed_bullet_fired = false
    NgocHoi.Time_missed_bullet = 8.5

    NgocHoi.groundWidth = NgocHoi.ground:getWidth()
    NgocHoi.groundPositionX = 0

    NgocHoi.shakeTime = 0
    NgocHoi.shakeDuration = 0
    NgocHoi.shakeMagnitude = 0
    NgocHoi.shakeX = 0
    NgocHoi.shakeY = 0

end

function NgocHoi:shake(duration, magnitude)
    NgocHoi.shakeDuration = duration
    NgocHoi.shakeTime = duration
    NgocHoi.shakeMagnitude = magnitude
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
    -- NgocHoi.cam:lookAt(NgocHoi.cameraX, NgocHoi.cameraY)

    NgocHoi.cam:lookAt(
        NgocHoi.cameraX + NgocHoi.shakeX,
        NgocHoi.cameraY + NgocHoi.shakeY
    )


    NgocHoi.groundPositionX = NgocHoi.groundPositionX - 17 * dt
    if (NgocHoi.groundPositionX <= -NgocHoi.groundWidth) then
        NgocHoi.groundPositionX = NgocHoi.groundPositionX + NgocHoi.groundWidth
    end
    for i = 1, 3 do
        NgocHoi.soldier_animations[i]:update(dt)
    end

    NgocHoi.bullet_animation:update(dt)
    NgocHoi.missed_bullet_animation:update(dt)

    for i = 1, 3 do
        NgocHoi.strawTimers[i] = NgocHoi.strawTimers[i] + dt
        if NgocHoi.strawTimers[i] >= NgocHoi.strawIntervals[i] then
            NgocHoi.strawTimers[i] = NgocHoi.strawTimers[i] - NgocHoi.strawIntervals[i]
            NgocHoi.strawOffsets[i] = math.random() < 0.5 and 0 or 2
        end
    end

    if NgocHoi.shakeTime > 0 then
    NgocHoi.shakeTime = NgocHoi.shakeTime - dt
        local t = NgocHoi.shakeTime / NgocHoi.shakeDuration
        local strength = NgocHoi.shakeMagnitude * t

        NgocHoi.shakeX = love.math.random(-strength, strength)
        NgocHoi.shakeY = love.math.random(-strength, strength)
    else
        NgocHoi.shakeX = 0
        NgocHoi.shakeY = 0
    end

    NgocHoi.BulletTimer = NgocHoi.BulletTimer + dt
    if NgocHoi.BulletTimer >= NgocHoi.TimeBullet1 and NgocHoi.BulletTimer < NgocHoi.TimeBullet2 then
        if NgocHoi.Bullet1Fired == false then
            NgocHoi.Bullet1Fired = true
            NgocHoi:shake(0.08, 1)
            NgocHoi.bullet_animation:gotoFrame(1)
            NgocHoi.bullet_animation:resume()
        end
    elseif NgocHoi.BulletTimer >= NgocHoi.TimeBullet2 and NgocHoi.BulletTimer < NgocHoi.TimeBullet3 then
        if NgocHoi.Bullet2Fired == false then
            NgocHoi.Bullet2Fired = true
            NgocHoi:shake(0.08, 1)
            NgocHoi.bullet_animation:gotoFrame(1)
            NgocHoi.bullet_animation:resume()
            NgocHoi.bulletX = 187
            NgocHoi.bulletY = 170
        end
    elseif NgocHoi.BulletTimer >= NgocHoi.TimeBullet3 then
        if NgocHoi.Bullet3Fired == false then
            NgocHoi.Bullet3Fired = true
            NgocHoi:shake(0.08, 1)
            NgocHoi.bullet_animation:gotoFrame(1)
            NgocHoi.bullet_animation:resume()
            NgocHoi.bulletX = 183
            NgocHoi.bulletY = 180
        end
    end

    if NgocHoi.BulletTimer >= NgocHoi.Time_missed_bullet then
        if NgocHoi.missed_bullet_fired == false then
            NgocHoi.missed_bullet_fired = true
            NgocHoi.missed_bullet_animation:gotoFrame(1)
            NgocHoi.missed_bullet_animation:resume()
        end
    end

    return LevelEnum.Nothing
end

function NgocHoi:draw(windowWidth, windowHeight)
    love.graphics.push()
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

        if NgocHoi.bullet_animation.status ~= "paused" then
            NgocHoi.bullet_animation:draw(NgocHoi.bullet_spritesheet, NgocHoi.bulletX, NgocHoi.bulletY)
        end

        if NgocHoi.missed_bullet_animation.status ~= "paused" then
            NgocHoi.missed_bullet_animation:draw(NgocHoi.missed_bullet_spritesheet, NgocHoi.missed_bulletX, NgocHoi.missed_bulletY)
        end

    NgocHoi.cam:detach()
    love.graphics.pop()

    
 
    love.graphics.push()
    local fontLoader = FontLoader:getInstance()
    local defaultFont = love.graphics.getFont()
    local font = fontLoader:loadFont("Texturina", math.floor(scale * 20))
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