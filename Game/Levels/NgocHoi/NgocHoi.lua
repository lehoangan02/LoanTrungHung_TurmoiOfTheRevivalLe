local Level = require("Game.Levels.Level")
local NgocHoi = setmetatable({}, Level)
NgocHoi.__index = NgocHoi

local FontLoader = require("Game.Fonts.FontLoader")
local anim8 = require "Game/Libraries/anim8"
local InputManager = require("Game.Input.InputManager")

function NgocHoi:load()

    local bf = require("Game/Libraries/breezefield-master")
    NgocHoi.worldGravity = 250
    NgocHoi.world = bf.newWorld(0, NgocHoi.worldGravity, false)

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
    NgocHoi.siege_tower_bg = love.graphics.newImage("Resources/Images/siege_tower_bg.png")
    NgocHoi.siege_tower_bg:setFilter("nearest", "nearest")
    NgocHoi.siege_tower_positionX = 100
    NgocHoi.siege_tower_positionY = 70
    NgocHoi.straw_straight = love.graphics.newImage("Resources/Images/Straw_straight.png")
    NgocHoi.straw_straight:setFilter("nearest", "nearest")
    NgocHoi.strawTimers = {0, 0, 0}
    NgocHoi.strawIntervals = {0.8, 1.3, 1.9}
    NgocHoi.strawOffsets = {0, 0, 0}
    NgocHoi.siege_tower_collider = NgocHoi.world:newCollider("Rectangle", {NgocHoi.siege_tower_positionX + NgocHoi.siege_tower:getWidth() / 2, NgocHoi.siege_tower_positionY + NgocHoi.siege_tower:getHeight() / 2, NgocHoi.siege_tower:getWidth(), NgocHoi.siege_tower:getHeight()})
    NgocHoi.siege_tower_collider:setType("static")

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
    NgocHoi.bulletX = NgocHoi.siege_tower_positionX + 85
    NgocHoi.bulletY = NgocHoi.siege_tower_positionY + 45
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

    NgocHoi.cannon2_spritesheet = love.graphics.newImage("Resources/Images/LightCannon2.png")
    NgocHoi.cannon2_spritesheet:setFilter("nearest", "nearest")
    NgocHoi.cannon2_grid = anim8.newGrid(70, 40, NgocHoi.cannon2_spritesheet:getWidth(), NgocHoi.cannon2_spritesheet:getHeight())
    NgocHoi.cannon2_animation = anim8.newAnimation(NgocHoi.cannon2_grid('1-6', 1), 0.15, 'pauseAtEnd')
    NgocHoi.TimeCannon2 = 10.5
    NgocHoi.cannon2Fired = false

    NgocHoi.cannon3_spritesheet = love.graphics.newImage("Resources/Images/LightCannon2.png")
    NgocHoi.cannon3_spritesheet:setFilter("nearest", "nearest")
    NgocHoi.cannon3_grid = anim8.newGrid(70, 40, NgocHoi.cannon3_spritesheet:getWidth(), NgocHoi.cannon3_spritesheet:getHeight())
    NgocHoi.cannon3_animation = anim8.newAnimation(NgocHoi.cannon3_grid('1-6', 1), 0.15, 'pauseAtEnd')
    NgocHoi.TimeCannon3 = 11.5
    NgocHoi.cannon3Fired = false

    NgocHoi.cannon4_spritesheet = love.graphics.newImage("Resources/Images/LightCannon2.png")
    NgocHoi.cannon4_spritesheet:setFilter("nearest", "nearest")
    NgocHoi.cannon4_grid = anim8.newGrid(70, 40, NgocHoi.cannon4_spritesheet:getWidth(), NgocHoi.cannon4_spritesheet:getHeight())
    NgocHoi.cannon4_animation = anim8.newAnimation(NgocHoi.cannon4_grid('1-6', 1), 0.15, 'pauseAtEnd')
    NgocHoi.TimeCannon4 = 12.0
    NgocHoi.cannon4Fired = false

    NgocHoi.groundWidth = NgocHoi.ground:getWidth()
    NgocHoi.groundPositionX = 0
    NgocHoi.groundPositionY = 200

    NgocHoi.shakeTime = 0
    NgocHoi.shakeDuration = 0
    NgocHoi.shakeMagnitude = 0
    NgocHoi.shakeX = 0
    NgocHoi.shakeY = 0

    

    local Ball = require("Game.Levels.NgocHoi.Ball")
    NgocHoi.cannonBall1 = Ball.new(NgocHoi.world, -230)
    NgocHoi.cannonBall1Fired = false
    NgocHoi.TimeCannon1 = 9.0

end

function NgocHoi:shake(duration, magnitude)
    NgocHoi.shakeDuration = duration
    NgocHoi.shakeTime = duration
    NgocHoi.shakeMagnitude = magnitude
end


function NgocHoi:update(dt)
    local LevelEnum = require("Game.Levels.LevelEnum")
    NgocHoi.world:update(dt)
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
        if NgocHoi.shakeX == 0 then NgocHoi.shakeX = strength end
        if NgocHoi.shakeY == 0 then NgocHoi.shakeY = strength end
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
            NgocHoi.bulletX = NgocHoi.siege_tower_positionX + 87
            NgocHoi.bulletY = NgocHoi.siege_tower_positionY + 105
        end
    elseif NgocHoi.BulletTimer >= NgocHoi.TimeBullet3 then
        if NgocHoi.Bullet3Fired == false then
            NgocHoi.Bullet3Fired = true
            NgocHoi:shake(0.08, 1)
            NgocHoi.bullet_animation:gotoFrame(1)
            NgocHoi.bullet_animation:resume()
            NgocHoi.bulletX = NgocHoi.siege_tower_positionX + 80
            NgocHoi.bulletY = NgocHoi.siege_tower_positionY + 115
        end
    end

    if NgocHoi.BulletTimer >= NgocHoi.Time_missed_bullet then
        if NgocHoi.missed_bullet_fired == false then
            NgocHoi.missed_bullet_fired = true
            NgocHoi.missed_bullet_animation:gotoFrame(1)
            NgocHoi.missed_bullet_animation:resume()
        end
    end

    if NgocHoi.BulletTimer >= NgocHoi.TimeCannon1 then
        if not NgocHoi.cannonBall1Fired then NgocHoi.cannonBall1:toss(240, 25, -10) end
        NgocHoi.cannonBall1Fired = true
    end

    NgocHoi.cannonBall1:update(dt)
    local _, y = NgocHoi.cannonBall1:getPosition()
    if (y ~= nil and y > 200) then
        NgocHoi.cannonBall1:deactivate()
        NgocHoi:shake(0.2, 3)
    end

    if NgocHoi.BulletTimer >= NgocHoi.TimeCannon2 then
        if not NgocHoi.cannon2Fired then
            NgocHoi.cannon2_animation:gotoFrame(1)
            NgocHoi.cannon2_animation:resume()
            NgocHoi.cannon2Fired = true
        end
    end

    if NgocHoi.cannon2_animation.position == 4 then
        NgocHoi:shake(0.1, 1)
    end

    if NgocHoi.BulletTimer >= NgocHoi.TimeCannon3 then
        if not NgocHoi.cannon3Fired then
            NgocHoi.cannon3_animation:gotoFrame(1)
            NgocHoi.cannon3_animation:resume()
            NgocHoi.cannon3Fired = true
        end
    end

    if NgocHoi.cannon3_animation.position == 4 then
        NgocHoi:shake(0.1, 1)
    end

    if NgocHoi.BulletTimer >= NgocHoi.TimeCannon4 then
        if not NgocHoi.cannon4Fired then
            NgocHoi.cannon4_animation:gotoFrame(1)
            NgocHoi.cannon4_animation:resume()
            NgocHoi.cannon4Fired = true
        end
    end

    if NgocHoi.cannon4_animation.position == 4 then
        NgocHoi:shake(0.1, 1)
    end

    if InputManager:isEventFKeyPressed() then
        NgocHoi.cannon2_animation:gotoFrame(1)
        NgocHoi.cannon2_animation:resume()
    end

    NgocHoi.cannon2_animation:update(dt)
    NgocHoi.cannon3_animation:update(dt)
    NgocHoi.cannon4_animation:update(dt)

    return LevelEnum.Nothing
end

function NgocHoi:draw(windowWidth, windowHeight)
    love.graphics.push()
    love.graphics.clear(1, 1, 1, 1)
    -- love.graphics.clear(0.6, 0.6, 0.6, 1)
    

    local scale = math.min(windowHeight / (BASE_H or 240), windowWidth / (BASE_W or 240))
    love.graphics.scale(scale, scale)
    love.graphics.translate((windowWidth / 2) * (1-scale) / scale, (windowHeight / 2) * (1-scale) / scale)

    NgocHoi.cam:attach()
        NgocHoi.world:draw()

        
        local wheelWidth = NgocHoi.wheel:getWidth()
        local wheelHeight = NgocHoi.wheel:getHeight()
        love.graphics.draw(NgocHoi.siege_tower_bg, NgocHoi.siege_tower_positionX, NgocHoi.siege_tower_positionY)
        NgocHoi.cannon2_animation:draw(NgocHoi.cannon2_spritesheet, NgocHoi.siege_tower_positionX + 40, NgocHoi.siege_tower_positionY - 2)
        NgocHoi.cannon3_animation:draw(NgocHoi.cannon3_spritesheet, NgocHoi.siege_tower_positionX + 44, NgocHoi.siege_tower_positionY + 51)
        NgocHoi.cannon4_animation:draw(NgocHoi.cannon4_spritesheet, NgocHoi.siege_tower_positionX + 41, NgocHoi.siege_tower_positionY + 77)
        love.graphics.draw(NgocHoi.ground, NgocHoi.groundPositionX, NgocHoi.groundPositionY)
        love.graphics.draw(NgocHoi.ground, NgocHoi.groundPositionX + NgocHoi.groundWidth, 200)
        love.graphics.draw(NgocHoi.ground, NgocHoi.groundPositionX - NgocHoi.groundWidth, 200)
        love.graphics.draw(NgocHoi.wheel, NgocHoi.siege_tower_positionX + 20 + wheelWidth/2, NgocHoi.siege_tower_positionY + 135 + 3 + wheelHeight/2, math.rad(30 + NgocHoi.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
        love.graphics.draw(NgocHoi.wheel, NgocHoi.siege_tower_positionX + 60 + wheelWidth/2, NgocHoi.siege_tower_positionY + 135 + 3 + wheelHeight/2, math.rad(45 + NgocHoi.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
        love.graphics.draw(NgocHoi.siege_tower, NgocHoi.siege_tower_positionX, NgocHoi.siege_tower_positionY)
        love.graphics.draw(NgocHoi.wheel, NgocHoi.siege_tower_positionX + 10 + wheelWidth/2, NgocHoi.siege_tower_positionY + 135 + 5 + wheelHeight/2, math.rad(60 + NgocHoi.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
        love.graphics.draw(NgocHoi.wheel, NgocHoi.siege_tower_positionX + 50 + wheelWidth/2, NgocHoi.siege_tower_positionY + 135 + 5 + wheelHeight/2, math.rad(0 + NgocHoi.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
        
        

        love.graphics.draw(NgocHoi.straw, 100, NgocHoi.siege_tower_positionY - 2)
        love.graphics.draw(NgocHoi.straw, 140, NgocHoi.siege_tower_positionY - 2)

        NgocHoi.soldier_animations[1]:draw(NgocHoi.soldier_spritesheet, 70, 183)
        NgocHoi.soldier_animations[2]:draw(NgocHoi.soldier_spritesheet, 35, 185)
        NgocHoi.soldier_animations[3]:draw(NgocHoi.soldier_spritesheet, 0, 181)


        love.graphics.draw(NgocHoi.straw_straight, 65, 178 + NgocHoi.strawOffsets[1])
        love.graphics.draw(NgocHoi.straw_straight, 32, 179 + NgocHoi.strawOffsets[2])
        love.graphics.draw(NgocHoi.straw_straight, -2, 176 + NgocHoi.strawOffsets[3])

        if NgocHoi.bullet_animation.status ~= "paused" then
            NgocHoi.bullet_animation:draw(NgocHoi.bullet_spritesheet, NgocHoi.bulletX, NgocHoi.bulletY)
        end

        if NgocHoi.missed_bullet_animation.status ~= "paused" then
            NgocHoi.missed_bullet_animation:draw(NgocHoi.missed_bullet_spritesheet, NgocHoi.missed_bulletX, NgocHoi.missed_bulletY)
        end

        
        NgocHoi.cannonBall1:draw()

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