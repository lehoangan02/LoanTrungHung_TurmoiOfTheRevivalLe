local Level = require("Game.Levels.Level")
local LoadCannonLevel = setmetatable({}, {__index = Level})
LoadCannonLevel.__index = LoadCannonLevel

local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")

local bf = require("Game/Libraries/breezefield-master")
local DEBUG = false

function LoadCannonLevel:load()
    LoadCannonLevel.worldGravity = 250
    LoadCannonLevel.world = bf.newWorld(0, LoadCannonLevel.worldGravity, true)

    LoadCannonLevel.cameraX = 120
    LoadCannonLevel.cameraY = 120

    local camera = require("Game.Libraries.camera")
    LoadCannonLevel.cam = camera()
    LoadCannonLevel.cam:lookAt(LoadCannonLevel.cameraX, LoadCannonLevel.cameraY)
    
    LoadCannonLevel.shakeTime = 0
    LoadCannonLevel.shakeDuration = 0
    LoadCannonLevel.shakeMagnitude = 0
    LoadCannonLevel.shakeX = 0
    LoadCannonLevel.shakeY = 0

    LoadCannonLevel.roomSprite = love.graphics.newImage("Resources/Images/LowerSiegeTower.png")
    LoadCannonLevel.roomSprite:setFilter("nearest", "nearest")

    LoadCannonLevel.cannonSprite = love.graphics.newImage("Resources/Images/LowerCannon.png")
    LoadCannonLevel.cannonSprite:setFilter("nearest", "nearest")


    LoadCannonLevel.soldier = require("Game.Levels.LoadCannon.LoadRoleSoldier")
    LoadCannonLevel.soldier:load(
        function() LoadCannonLevel.spawnCannonBall() end,
        function() return LoadCannonLevel.isCannonBallInStraw() end,
        function(visible) LoadCannonLevel.setCannonBallVisible(visible) end,
        function(dur, mag) LoadCannonLevel:shake(dur, mag) end
    )

    LoadCannonLevel.strawDampingImage = love.graphics.newImage("Resources/Images/StrawDamping.png")
    LoadCannonLevel.strawDampingImage:setFilter("nearest", "nearest")

    LoadCannonLevel.cannonBallImage = love.graphics.newImage("Resources/Images/CannonBall.png")
    LoadCannonLevel.cannonBallImage:setFilter("nearest", "nearest")

    LoadCannonLevel.isBallSpawned = false

    LoadCannonLevel.strawDampingCollider = LoadCannonLevel.world:newCollider("Rectangle", {95, 152, 30, 6})
    LoadCannonLevel.strawDampingCollider:setType("static")

    LoadCannonLevel.backCannonBallsSprite = love.graphics.newImage("Resources/Images/BackCannonBalls.png")
    LoadCannonLevel.backCannonBallsSprite:setFilter("nearest", "nearest")

end

function LoadCannonLevel:shake(duration, magnitude)
    LoadCannonLevel.shakeDuration = duration
    LoadCannonLevel.shakeTime = duration
    LoadCannonLevel.shakeMagnitude = magnitude
end

function LoadCannonLevel:spawnCannonBall()
    if LoadCannonLevel.isBallSpawned then
        return
    end
    print("Spawning cannon ball")
    LoadCannonLevel.isBallSpawned = true
    local radius = 4
    LoadCannonLevel.cannonBallCollider = LoadCannonLevel.world:newCollider("Circle", {95, 0, radius})
    LoadCannonLevel.cannonBallCollider:setType("dynamic")
    LoadCannonLevel.cannonBallCollider:setRestitution(0.3)
    LoadCannonLevel.cannonBallVisible = true
end

function LoadCannonLevel:isCannonBallInStraw()
    if not LoadCannonLevel.isBallSpawned then
        return false
    end
    local _, ballY = LoadCannonLevel.cannonBallCollider:getPosition()
    local _, ballSpeedY = LoadCannonLevel.cannonBallCollider:getLinearVelocity()
    local result =  ballY > 144 and ballY < 145 and ballSpeedY >= 0 and ballSpeedY < 1
    if DEBUG then
        print("Ball is in straw: " .. tostring(result) .. ", Ball Y: " .. ballY .. ", Ball Speed Y: " .. ballSpeedY)
    end
    return result
end

function LoadCannonLevel.setCannonBallVisible(visible)
    LoadCannonLevel.cannonBallVisible = visible
    print("Setting cannon ball visible: " .. tostring(visible))
end

function LoadCannonLevel:update(dt)
    local LevelEnum = require("Game.Levels.LevelEnum")
    local res = LoadCannonLevel.soldier:update(dt)
    LoadCannonLevel.world:update(dt)
    if LoadCannonLevel.isBallSpawned and DEBUG then
        local _, ballY = LoadCannonLevel.cannonBallCollider:getPosition()
        print("Ball Y position: " .. ballY)
    end
    
    if LoadCannonLevel.shakeTime and LoadCannonLevel.shakeTime > 0 then
        LoadCannonLevel.shakeTime = LoadCannonLevel.shakeTime - dt
        local t = LoadCannonLevel.shakeTime / LoadCannonLevel.shakeDuration
        local strength = LoadCannonLevel.shakeMagnitude * t
        LoadCannonLevel.shakeX = love.math.random(-strength, strength)
        LoadCannonLevel.shakeY = love.math.random(-strength, strength)
        if LoadCannonLevel.shakeX == 0 then LoadCannonLevel.shakeX = strength end
        if LoadCannonLevel.shakeY == 0 then LoadCannonLevel.shakeY = strength end
    else
        LoadCannonLevel.shakeX = 0
        LoadCannonLevel.shakeY = 0
    end

    LoadCannonLevel.cam:lookAt(
        LoadCannonLevel.cameraX + LoadCannonLevel.shakeX,
        LoadCannonLevel.cameraY + LoadCannonLevel.shakeY
    )
    
    if not res then
        return LevelEnum.Nothing
    else
        return LevelEnum.TowerBlastFort
    end
end

function LoadCannonLevel:draw(windowWidth, windowHeight)
    local scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode = ResizeWindowTransform.getTransform(windowWidth, windowHeight, BASE_W, BASE_H)
    love.graphics.translate(offsetXCameraMode, offsetYCameraMode)
    love.graphics.scale(scale, scale)

    LoadCannonLevel.cam:attach()
        
        love.graphics.draw(self.roomSprite, 0, 0)
        LoadCannonLevel.soldier:draw()
        if self.isBallSpawned and LoadCannonLevel.cannonBallVisible then
            local ballX, ballY = LoadCannonLevel.cannonBallCollider:getPosition()
            love.graphics.draw(LoadCannonLevel.cannonBallImage, ballX, ballY, 0, 1, 1, LoadCannonLevel.cannonBallImage:getWidth() / 2, LoadCannonLevel.cannonBallImage:getHeight() / 2)
        end
        if LoadCannonLevel.cannonBallVisible then
            love.graphics.draw(self.backCannonBallsSprite, 0, 0)
        end
        love.graphics.draw(self.cannonSprite, 0, 0)
        love.graphics.draw(LoadCannonLevel.strawDampingImage, 2, -1)
        love.graphics.draw(LoadCannonLevel.strawDampingImage, 0, 0)
        
        LoadCannonLevel.world:draw()
        
    LoadCannonLevel.cam:detach()
end

function LoadCannonLevel:unload()
end

return LoadCannonLevel