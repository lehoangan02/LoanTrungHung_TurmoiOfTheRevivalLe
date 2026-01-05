local Level = require "Game.Levels.Level"
local BallClass = require "Game.Levels.BallDrop.Ball"
local BallDropLevel = setmetatable({}, {__index = Level})
BallDropLevel.__index = BallDropLevel

local TiledUtils = require "Game.Custom.TiledUtility"

function BallDropLevel:load()
    local sti = require "Game/Libraries/sti"
    BallDropLevel.gameMap = sti("Game/Maps/testMap.lua")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    
    BallDropLevel.ballMoveSpeed = 100
    BallDropLevel.worldRotateSpeed = 2
    BallDropLevel.cameraX = 120
    BallDropLevel.cameraY = 50
    BallDropLevel.currentZoom = 1.0
    BallDropLevel.zoomSpeed = 0.15
    
    local camera = require("Game.Libraries.camera")
    BallDropLevel.cam = camera()
    
    local bf = require("Game/Libraries/breezefield-master")
    BallDropLevel.worldGravity = 200
    BallDropLevel.world = bf.newWorld(0, BallDropLevel.worldGravity, false)
    
    -- Collision categories for breezefield (using love.physics categories/masks)
    BallDropLevel.CATEGORY_BALL = 1
    BallDropLevel.CATEGORY_ENEMIES = 2
    BallDropLevel.CATEGORY_STARS = 3
    BallDropLevel.CATEGORY_WALLS = 4
    
    BallDropLevel.worldRotation = 0
    BallDropLevel.cameraRotation = 0
    BallDropLevel.rotationSharpness = 12
    
    BallDropLevel.walls = {}
    if BallDropLevel.gameMap.layers["StaticCollidable"] then
        for i, obj in pairs(BallDropLevel.gameMap.layers["StaticCollidable"].objects) do
            local wall = BallDropLevel.world:newCollider("Rectangle", {obj.x + obj.width/2, obj.y + obj.height/2, obj.width, obj.height})
            wall:setType("static")
            wall.fixture:setCategory(BallDropLevel.CATEGORY_WALLS)
            table.insert(BallDropLevel.walls, wall)
        end
    end
    
    BallDropLevel.enemies = {}
    if BallDropLevel.gameMap.layers["EnemiesCollidable"] then
        for i, obj in pairs(BallDropLevel.gameMap.layers["EnemiesCollidable"].objects) do
            local enemy = BallDropLevel.world:newCollider("Rectangle", {obj.x + obj.width/2, obj.y + obj.height/2, obj.width, obj.height})
            enemy:setType("static")
            enemy.fixture:setCategory(BallDropLevel.CATEGORY_ENEMIES)
            enemy.isEnemy = true
            table.insert(BallDropLevel.enemies, enemy)
        end
    end

    BallDropLevel.stars = {}
    if BallDropLevel.gameMap.layers["Stars"] then
        for i, obj in pairs(BallDropLevel.gameMap.layers["Stars"].objects) do
            local star = BallDropLevel.world:newCollider("Rectangle", {obj.x + obj.width/2, obj.y + obj.height/2, obj.width, obj.height})
            star:setType("static")
            star.fixture:setCategory(BallDropLevel.CATEGORY_STARS)
            star.fixture:setSensor(true) 
            star.tiledObject = obj
            star.isStar = true
            table.insert(BallDropLevel.stars, star)
        end
    end
    BallDropLevel.starActivateAnimation = require("Game.Levels.StarAnimation").new()

    BallDropLevel.ball = BallClass.new(BallDropLevel.world, 100, 50)
end

function BallDropLevel:update(dt)
    BallDropLevel.gameMap:update(dt)
    BallDropLevel.world:update(dt)
    BallDropLevel:adjustGravity()
    
    BallDropLevel.ball:update(dt, BallDropLevel.world)

    InputManager = require("Game.Input.InputManager")
    if InputManager:isEventFKeyPressed() and not BallDropLevel.ball.exploded then
        BallDropLevel.ball:explode()
    end

    BallDropLevel.starActivateAnimation:update(dt)

    BallDropLevel:controlEnvironment(dt)

    local angleGap = BallDropLevel.worldRotation - BallDropLevel.cameraRotation
    local angleCamStep = angleGap * dt * BallDropLevel.rotationSharpness
    BallDropLevel.cam:rotate(angleCamStep)
    BallDropLevel.cameraRotation = BallDropLevel.cameraRotation + angleCamStep

    BallDropLevel:trackBall(dt)
end

function BallDropLevel:adjustGravity()
    local gx = BallDropLevel.worldGravity * math.sin(BallDropLevel.worldRotation)
    local gy = BallDropLevel.worldGravity * math.cos(BallDropLevel.worldRotation)
    BallDropLevel.world:setGravity(gx, gy)
end

function BallDropLevel:trackBall(dt)
    local lookAhead = 30
    local upperThres = 40
    local lowerThres = -40
    local targetY
    local deltaY = BallDropLevel.ball.ballY - BallDropLevel.cameraY
    local lookAheadStrength = 0.8
    local localLookStrengthY = 0.5

    if (deltaY > upperThres) then
        targetY = BallDropLevel.ball.ballY + lookAhead
        BallDropLevel.cameraY = BallDropLevel.cameraY + (targetY - BallDropLevel.cameraY) * dt * lookAheadStrength
    elseif (deltaY < lowerThres) then
        targetY = BallDropLevel.ball.ballY - lookAhead / 2
        BallDropLevel.cameraY = BallDropLevel.cameraY + (targetY - BallDropLevel.cameraY) * dt * lookAheadStrength
    else 
        targetY = BallDropLevel.ball.ballY
        BallDropLevel.cameraY = BallDropLevel.cameraY + (targetY - BallDropLevel.cameraY) * dt * localLookStrengthY
    end

    local localLookStrengthX = 0.1
    local targetX = BallDropLevel.ball.ballX * 0.4 + 120 * 0.6
    BallDropLevel.cameraX = BallDropLevel.cameraX + (targetX - BallDropLevel.cameraX) * dt * localLookStrengthX
    
    local desiredZoom = 1.0
    if BallDropLevel.ball.ballX < 60 or BallDropLevel.ball.ballX > 180 then
        desiredZoom = 1.1
    end

    BallDropLevel.currentZoom = BallDropLevel.currentZoom + (desiredZoom - BallDropLevel.currentZoom) * dt * BallDropLevel.zoomSpeed
    BallDropLevel.cam:zoomTo(BallDropLevel.currentZoom)
    BallDropLevel.cam:lookAt(BallDropLevel.cameraX, BallDropLevel.cameraY)
end

function BallDropLevel:controlEnvironment(dt)
    InputManager = require("Game.Input.InputManager")
    if InputManager:isRightRudderPressed() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation + dt * BallDropLevel.worldRotateSpeed
    elseif InputManager:isLeftRudderPressed() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation - dt * BallDropLevel.worldRotateSpeed
    end
    
    if InputManager:isEventKY040RightTurned() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation + dt * BallDropLevel.worldRotateSpeed * InputManager:getHandCrankMultiplier()
    elseif InputManager:isEventKY040LeftTurned() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation - dt * BallDropLevel.worldRotateSpeed * InputManager:getHandCrankMultiplier()
    end

    local stickRot = InputManager:getLeftStickRotation() + InputManager:getRightStickRotation()
    BallDropLevel.worldRotation = BallDropLevel.worldRotation + stickRot * dt * BallDropLevel.worldRotateSpeed * InputManager:getJoystickMultiplier()

    local triggerVal = InputManager:getLeftTriggerValue() - InputManager:getRightTriggerValue()
    BallDropLevel.worldRotation = BallDropLevel.worldRotation + triggerVal * dt * BallDropLevel.worldRotateSpeed * InputManager:getTriggerMultiplier()
end

function BallDropLevel:draw(windowWidth, windowHeight)
    love.graphics.clear(176/255, 174/255, 167/255, 1)
    
    local scale = math.min(windowHeight / (BASE_H or 240), windowWidth / (BASE_W or 320))
    love.graphics.scale(scale, scale)
    love.graphics.translate((windowWidth / 2) * (1-scale) / scale, (windowHeight / 2) * (1-scale) / scale)
    
    BallDropLevel.cam:attach()
        local layers = BallDropLevel.gameMap.layers
        if layers["Background"] then BallDropLevel.gameMap:drawLayer(layers["Background"]) end
        if layers["Wall"] then BallDropLevel.gameMap:drawLayer(layers["Wall"]) end
        if layers["NonCollidable"] then BallDropLevel.gameMap:drawLayer(layers["NonCollidable"]) end
        if layers["Enemies"] then BallDropLevel.gameMap:drawLayer(layers["Enemies"]) end
        
        TiledUtils.drawTileObjectLayer(BallDropLevel.gameMap, "Stars")
        BallDropLevel.starActivateAnimation:draw()
        
        BallDropLevel.world:draw() 
        BallDropLevel.ball:draw()
    BallDropLevel.cam:detach()

    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function BallDropLevel:unload()
    if BallDropLevel.world then
        BallDropLevel.world:destroy()
        BallDropLevel.world = nil
    end
end

return BallDropLevel