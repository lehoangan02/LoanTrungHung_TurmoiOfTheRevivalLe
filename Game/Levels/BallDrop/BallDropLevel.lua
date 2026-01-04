local Level = require "Game.Levels.Level"
local BallDropLevel = setmetatable({}, {__index = Level})
BallDropLevel.__index = BallDropLevel

function BallDropLevel:load()
    local sti = require "Game/Libraries/sti"
    local anim8 = require "Game/Libraries/anim8"
    BallDropLevel.gameMap = sti("Game/Maps/testMap.lua")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    -- musicManager:playBackgroundMusic(MusicEnum.Sakura_Cherry_Blossom)
    BallDropLevel.ballImage = love.graphics.newImage("Resources/Images/Cannon_ball.png")
    BallDropLevel.ballImage:setFilter("nearest", "nearest")
    BallDropLevel.explodeSpriteSheet = love.graphics.newImage("Resources/Images/explode_large.png")
    BallDropLevel.explodeGrid = anim8.newGrid(32, 32, BallDropLevel.explodeSpriteSheet:getWidth(), BallDropLevel.explodeSpriteSheet:getHeight())
    BallDropLevel.explodeAnimation = anim8.newAnimation(BallDropLevel.explodeGrid('1-4', 1), 0.2, 'pauseAtEnd')
    BallDropLevel.exploded = false
    BallDropLevel.ballRotation = 0
    BallDropLevel.ballRadius = 7
    BallDropLevel.ballMoveSpeed = 100
    BallDropLevel.worldRotateSpeed = 2
    BallDropLevel.ballX = 100
    BallDropLevel.ballY = 50
    BallDropLevel.cameraX = 120
    BallDropLevel.cameraY = BallDropLevel.ballY
    BallDropLevel.upperCameraLimitY = nil
    BallDropLevel.lowerCameraLimitY = nil
    BallDropLevel.currentZoom = 1.0
    BallDropLevel.zoomSpeed = 0.15
    local camera = require("Game.Libraries.camera")
    BallDropLevel.cam = camera()
    local wf = require("Game/Libraries/windfield")
    BallDropLevel.worldGravity = 200
    BallDropLevel.world = wf.newWorld(0, BallDropLevel.worldGravity, false)
    BallDropLevel.worldRotation = 0
    BallDropLevel.walls = {}
    if BallDropLevel.gameMap.layers["StaticCollidable"] then
        for i, obj in pairs(BallDropLevel.gameMap.layers["StaticCollidable"].objects) do
            local wall = BallDropLevel.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(BallDropLevel.walls, wall)
        end
    end
    BallDropLevel.enemies = {}
    BallDropLevel.world:addCollisionClass("Enemies")
    if BallDropLevel.gameMap.layers["Enemies"] then
        for i, obj in pairs(BallDropLevel.gameMap.layers["EnemiesCollidable"].objects)
        do
            local enemy = BallDropLevel.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            enemy:setType("static")
            enemy:setCollisionClass("Enemies")
            table.insert(BallDropLevel.enemies, enemy)
        end
    end
    BallDropLevel.ballCollider = BallDropLevel.world:newCircleCollider(BallDropLevel.ballX, BallDropLevel.ballY, BallDropLevel.ballRadius)
    BallDropLevel.ballCollider:setRestitution(0.6)
end
function BallDropLevel:update(dt)
    BallDropLevel.gameMap:update(dt)
    BallDropLevel.world:update(dt)
    BallDropLevel:adjustGravity()
    if not BallDropLevel.exploded then
        BallDropLevel:rotateBall(dt)
        BallDropLevel:controlEnvironment(dt)
        BallDropLevel.ballX, BallDropLevel.ballY = BallDropLevel.ballCollider:getPosition()
        if BallDropLevel.ballCollider:enter("Enemies") then
            print("Collided with enemies")
            BallDropLevel:explodeBall()
        end
    end
    InputManager = require("Game.Input.InputManager")
    if InputManager:isEventFKeyPressed() and not BallDropLevel.exploded then
        BallDropLevel:explodeBall()
    end

    BallDropLevel.explodeAnimation:update(dt)
    BallDropLevel:trackBall(dt)
end

function BallDropLevel:explodeBall()
    BallDropLevel.exploded = true
    BallDropLevel.explodeAnimation:gotoFrame(1)
    BallDropLevel.explodeAnimation:resume()
    BallDropLevel.ballCollider:destroy()
end

function BallDropLevel:adjustGravity()
    local gx, gy
    gx = BallDropLevel.worldGravity * math.sin(BallDropLevel.worldRotation)
    gy = BallDropLevel.worldGravity * math.cos(BallDropLevel.worldRotation)
    BallDropLevel.world:setGravity(gx, gy)
end

function BallDropLevel:trackBall(dt)
    local lookAhead = 30
    local upperThres = 40
    local lowerThres = -40
    local targetY
    local deltaY = BallDropLevel.ballY - BallDropLevel.cameraY
    local deltaX = BallDropLevel.ballX - BallDropLevel.cameraX
    local lookAheadStrength = 0.8
    local localLookStrengthY = 0.5
    if (deltaY > upperThres) then
        targetY = BallDropLevel.ballY + lookAhead
        BallDropLevel.cameraY = BallDropLevel.cameraY + (targetY - BallDropLevel.cameraY) * dt * lookAheadStrength
    elseif (deltaY < lowerThres) then
        targetY = BallDropLevel.ballY - lookAhead / 2
        BallDropLevel.cameraY = BallDropLevel.cameraY + (targetY - BallDropLevel.cameraY) * dt * lookAheadStrength
    else 
        targetY = BallDropLevel.ballY
        BallDropLevel.cameraY = BallDropLevel.cameraY + (targetY - BallDropLevel.cameraY) * dt * localLookStrengthY
    end
    local localLookStrengthX = 0.1
    local targetX = BallDropLevel.ballX * 0.4 + 120 * 0.6
    BallDropLevel.cameraX = BallDropLevel.cameraX + (targetX - BallDropLevel.cameraX) * dt * localLookStrengthX
    
    local desiredZoom = 1.0

    if BallDropLevel.ballX < 60 or BallDropLevel.ballX > 180 then
        desiredZoom = 1.1
    end

    BallDropLevel.currentZoom =
        BallDropLevel.currentZoom +
        (desiredZoom - BallDropLevel.currentZoom) * dt * BallDropLevel.zoomSpeed

    BallDropLevel.cam:zoomTo(BallDropLevel.currentZoom)

    BallDropLevel.cam:lookAt(BallDropLevel.cameraX, BallDropLevel.cameraY)
end

function BallDropLevel:rotateBall(dt)
    local velX, velY = BallDropLevel.ballCollider:getLinearVelocity()

    local gx, gy = BallDropLevel.world:getGravity()
    local glen = math.sqrt(gx*gx + gy*gy)
    if glen > 0 then
        local gnx = gx / glen
        local gny = gy / glen

        local tx = -gny
        local ty = gnx

        local tangentialSpeed = -(velX * tx + velY * ty) * 3
        local rotateSpeedLimit = 120
        if tangentialSpeed > rotateSpeedLimit then
            tangentialSpeed = rotateSpeedLimit
        elseif tangentialSpeed < -rotateSpeedLimit then
            tangentialSpeed = -rotateSpeedLimit
        end

        BallDropLevel.ballRotation =
            BallDropLevel.ballRotation + (tangentialSpeed / BallDropLevel.ballRadius) * dt
    
    end
end

function BallDropLevel:controlEnvironment(dt)
    InputManager = require("Game.Input.InputManager")
    if InputManager:isRightRudderPressed() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation + dt * BallDropLevel.worldRotateSpeed
        BallDropLevel.cam:rotate(dt * BallDropLevel.worldRotateSpeed)
    elseif InputManager:isLeftRudderPressed() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation - dt * BallDropLevel.worldRotateSpeed
        BallDropLevel.cam:rotate(-dt * BallDropLevel.worldRotateSpeed)
    end
    local handCrankMultiplier = 3
    if InputManager:isEventKY040RightTurned() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation + dt * BallDropLevel.worldRotateSpeed * handCrankMultiplier
        BallDropLevel.cam:rotate(dt * BallDropLevel.worldRotateSpeed * handCrankMultiplier)
    elseif InputManager:isEventKY040LeftTurned() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation - dt * BallDropLevel.worldRotateSpeed * handCrankMultiplier
        BallDropLevel.cam:rotate(-dt * BallDropLevel.worldRotateSpeed * handCrankMultiplier)
    end
    local joystickMultiplier = 4
    BallDropLevel.worldRotation = BallDropLevel.worldRotation + InputManager:getLeftStickRotation() * dt * BallDropLevel.worldRotateSpeed * joystickMultiplier
    BallDropLevel.cam:rotate(InputManager:getLeftStickRotation() * dt * BallDropLevel.worldRotateSpeed * joystickMultiplier)
    BallDropLevel.worldRotation = BallDropLevel.worldRotation + InputManager:getRightStickRotation() * dt * BallDropLevel.worldRotateSpeed * joystickMultiplier
    BallDropLevel.cam:rotate(InputManager:getRightStickRotation() * dt * BallDropLevel.worldRotateSpeed * joystickMultiplier)

    local triggerMultiplier = 0.8
    local leftTriggerValue = InputManager:getLeftTriggerValue()
    BallDropLevel.worldRotation = BallDropLevel.worldRotation + leftTriggerValue * dt * BallDropLevel.worldRotateSpeed * triggerMultiplier
    BallDropLevel.cam:rotate(leftTriggerValue * dt * BallDropLevel.worldRotateSpeed * triggerMultiplier)
    local rightTriggerValue = InputManager:getRightTriggerValue()
    BallDropLevel.worldRotation = BallDropLevel.worldRotation - rightTriggerValue * dt * BallDropLevel.worldRotateSpeed * triggerMultiplier
    BallDropLevel.cam:rotate(-rightTriggerValue * dt * BallDropLevel.worldRotateSpeed * triggerMultiplier)
end
function BallDropLevel:draw(windowWidth, windowHeight)
    love.graphics.clear(176/255, 174/255, 167/255, 1)
    local scaleX = windowHeight / BASE_H
    local scaleY = windowWidth / BASE_W
    local centerX = windowWidth / 2
    local centerY = windowHeight / 2
    local scale = math.min(scaleX, scaleY)
    love.graphics.scale(scale, scale)
    love.graphics.translate(centerX * (1-scale) / scale, centerY * (1-scale) / scale)
    BallDropLevel.cam:attach()
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Background"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Wall"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["NonCollidable"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Enemies"])
        BallDropLevel.world:draw()
        if not BallDropLevel.exploded then
            love.graphics.draw(BallDropLevel.ballImage, BallDropLevel.ballX, BallDropLevel.ballY, BallDropLevel.ballRotation, 1, 1, 8, 8)
        end
        if BallDropLevel.exploded and BallDropLevel.explodeAnimation.status ~= "paused" then
            BallDropLevel.explodeAnimation:draw(BallDropLevel.explodeSpriteSheet, BallDropLevel.ballX - 16, BallDropLevel.ballY - 16)
        end
    BallDropLevel.cam:detach()
    -- draw fps
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end
function BallDropLevel:unload()
end

return BallDropLevel