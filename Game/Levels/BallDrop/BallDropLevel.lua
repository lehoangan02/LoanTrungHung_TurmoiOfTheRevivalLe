local Level = require "Game.Levels.Level"
local BallClass = require "Game.Levels.BallDrop.Ball"
local BallDropLevel = setmetatable({}, {__index = Level})
BallDropLevel.__index = BallDropLevel

local LoadScreen = require "Game.Levels.LoadScreen.LoadScreen"
local TiledUtils = require "Game.Custom.TiledUtility"
local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")
local Blocker = require "Game.Levels.BallDrop.Blocker"
local Lever = require "Game.Levels.BallDrop.Lever"

function BallDropLevel:load()

    BallDropLevel.loadScreen = LoadScreen.new("Resources/Images/White_tiger_Hang_Trong.jpg")
    BallDropLevel.loadScreen:reset()

    BallDropLevel.loadScreen:addTask(function()
        print("Dummy task 1 - waiting...")
        love.timer.sleep(0.1)
        print("Dummy task 1 - done!")
    end, 20)

    BallDropLevel.loadScreen:addTask(function()
        print("Dummy task 2 - waiting...")
        love.timer.sleep(0.15)
        print("Dummy task 2 - done!")
    end, 25)

    BallDropLevel.loadScreen:addTask(function()
        print("Dummy task 3 - waiting...")
        love.timer.sleep(0.2)
        print("Dummy task 3 - done!")
    end, 30)

    BallDropLevel.loadScreen:addTask(function()
        print("Dummy task 4 - loading actual level...")
        love.timer.sleep(0.2)
        print("Dummy task 4 - done!")
    end, 25)

    BallDropLevel.loadScreen:start()

    local sti = require "Game/Libraries/sti"
    BallDropLevel.gameMap = sti("Game/Maps/testMap.lua")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    
    BallDropLevel.ballMoveSpeed = 100
    BallDropLevel.worldRotateSpeed = 1.5
    BallDropLevel.cameraX = 60
    BallDropLevel.cameraY = 300
    BallDropLevel.currentZoom = 1.0
    BallDropLevel.zoomSpeed = 0.15
    
    local camera = require("Game.Libraries.camera")
    BallDropLevel.cam = camera()
    
    local bf = require("Game/Libraries/breezefield-master")
    BallDropLevel.worldGravity = 200
    BallDropLevel.world = bf.newWorld(0, BallDropLevel.worldGravity, false)
    
    BallDropLevel.CATEGORY_BALL = 1
    BallDropLevel.CATEGORY_ENEMIES = 2
    BallDropLevel.CATEGORY_STARS = 3
    BallDropLevel.CATEGORY_WALLS = 4
    
    BallDropLevel.worldRotation = 0
    BallDropLevel.cameraRotation = 0
    BallDropLevel.rotationSharpness = 12
    
    BallDropLevel.walls = {}
    BallDropLevel.magnets = {}
    
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

    BallDropLevel.blocker = Blocker.new(BallDropLevel.world, BallDropLevel.gameMap, "Blocker", "BlockerCollidable", 1)

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

    BallDropLevel.ball = BallClass.new(BallDropLevel.world, BallDropLevel.cameraX, BallDropLevel.cameraY)

    local Hinge = require "Game.Levels.BallDrop.Hinge"
    BallDropLevel.hinge1 = Hinge.new(BallDropLevel.world, BallDropLevel.gameMap, "Hinge", 1, 2, 10000, 140, 0.8)
    BallDropLevel.hinge2 = Hinge.new(BallDropLevel.world, BallDropLevel.gameMap, "Hinge", 3, 4, 15000, 200, 0.7)
    BallDropLevel.hinge3 = Hinge.new(BallDropLevel.world, BallDropLevel.gameMap, "Hinge", 5, 6, 15000, 200, 0.7)
    BallDropLevel.hinge4 = Hinge.new(BallDropLevel.world, BallDropLevel.gameMap, "Hinge", 7, 8, 15000, 200, 0.7)

    BallDropLevel.lever1 = Lever.new(
        BallDropLevel.world,
        53,
        1296,
        30,
        6,
        math.rad(-20),
        math.rad(-20),
        math.rad(45),
        "left"
    )

    BallDropLevel.spikeBlockImage = love.graphics.newImage("Resources/Images/SpikeBlock.png")
    BallDropLevel.spikeBlockImage:setFilter("nearest", "nearest")
    local spikeBlockWidth = BallDropLevel.spikeBlockImage:getWidth()
    local spikeBlockHeight = BallDropLevel.spikeBlockImage:getHeight()
    BallDropLevel.spikeBlockInitPosition = {x = 125, y = 1295}
    BallDropLevel.spikeBlockCollider = BallDropLevel.world:newCollider("Rectangle", {BallDropLevel.spikeBlockInitPosition.x, BallDropLevel.spikeBlockInitPosition.y, spikeBlockWidth, spikeBlockHeight})
    BallDropLevel.spikeBlockCollider:setType("dynamic")
    BallDropLevel.spikeBlockCollider.fixture:setFriction(0)
    BallDropLevel.spikeBlockCollider.isEnemy = true

    if BallDropLevel.gameMap.layers["StaticCollidable"] then
        for i, obj in pairs(BallDropLevel.gameMap.layers["StaticCollidable"].objects) do
            local wall = BallDropLevel.world:newCollider("Rectangle", {obj.x + obj.width/2, obj.y + obj.height/2, obj.width, obj.height})
            wall:setType("static")
            wall.fixture:setCategory(BallDropLevel.CATEGORY_WALLS)
            
            if obj.properties and obj.properties["isMagnetBlock"] then
                print("Found magnet block at " .. obj.x .. ", " .. obj.y)
                table.insert(BallDropLevel.magnets, wall)
            end
            
            table.insert(BallDropLevel.walls, wall)
        end
    end

    BallDropLevel.successY = 1720
    BallDropLevel.success = false
    BallDropLevel.timeToLinger = 1
    
    print("Total magnets found: " .. #BallDropLevel.magnets)
    print("Spike block starts at: " .. BallDropLevel.spikeBlockInitPosition.x .. ", " .. BallDropLevel.spikeBlockInitPosition.y)

end

local function getDistanceToSegment(px, py, x1, y1, x2, y2)
    local l2 = (x1 - x2)^2 + (y1 - y2)^2
    if l2 == 0 then 
        return math.sqrt((px - x1)^2 + (py - y1)^2), x1, y1 
    end
    local t = math.max(0, math.min(1, ((px - x1) * (x2 - x1) + (py - y1) * (y2 - y1)) / l2))
    local projX = x1 + t * (x2 - x1)
    local projY = y1 + t * (y2 - y1)
    return math.sqrt((px - projX)^2 + (py - projY)^2), projX, projY
end

function BallDropLevel:applyMagneticForces(dt)
    local strength = 20000000
    local minDistance = 10 
    local sx, sy = BallDropLevel.spikeBlockCollider:getPosition()

    for i, magnet in ipairs(BallDropLevel.magnets) do
        local mx, my = magnet:getPosition()
        local dx, dy = mx - sx, my - sy
        local distSq = dx*dx + dy*dy
        local dist = math.sqrt(distSq)
        
        if distSq > (minDistance * minDistance) then
            local forceMag = strength / (distSq * dist)
            local fx = (dx / dist) * forceMag
            local fy = (dy / dist) * forceMag
            
            BallDropLevel.spikeBlockCollider:applyForce(fx, fy)
            
            -- Debug output (only occasionally to avoid spam)
            if love.timer.getTime() % 1.0 < dt then
                print(string.format("Magnet %d: dist=%.1f, force=(%.1f, %.1f)", i, dist, fx, fy))
            end
        end
    end
end

function BallDropLevel:update(dt)

    if not BallDropLevel.loadScreen:isDone() then
        BallDropLevel.loadScreen:update(dt)
        return -1
    end

    BallDropLevel:adjustGravity()
    BallDropLevel:applyMagneticForces(dt)

    BallDropLevel.gameMap:update(dt)
    BallDropLevel.world:update(dt)
    
    
    BallDropLevel.ball:update(dt, BallDropLevel.world)
    BallDropLevel.hinge1:update(dt)
    BallDropLevel.hinge2:update(dt)
    BallDropLevel.hinge3:update(dt)
    BallDropLevel.hinge4:update(dt)

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

    BallDropLevel.blocker:update(dt)
    BallDropLevel.lever1:update(dt)

    if not BallDropLevel.blocker.isWireCut and BallDropLevel.lever1.spike then
        local sx, sy = BallDropLevel.lever1.spike:getPosition()
        local wx1, wy1 = BallDropLevel.blocker.wireAnchorX, BallDropLevel.blocker.wireAnchorY
        
        local bx, by = BallDropLevel.blocker.blocker:getPosition()
        local wx2 = bx - (BallDropLevel.blocker.obj.width / 2)
        local wy2 = by

        local dist, projX, projY = getDistanceToSegment(sx, sy, wx1, wy1, wx2, wy2)
        
        if dist < 15 then
            BallDropLevel.blocker:cutWire(projX, projY)
        end
    end

    if BallDropLevel.ball.ballY > BallDropLevel.successY then
        BallDropLevel.success = true
    end

    if BallDropLevel.success then
        BallDropLevel.timeToLinger = BallDropLevel.timeToLinger - dt
        if BallDropLevel.timeToLinger <= 0 then
            return LevelEnum.SolderLoadCannon
        end
    end

    return LevelEnum.Nothing
end

function BallDropLevel:adjustGravity()
    local gx = BallDropLevel.worldGravity * math.sin(BallDropLevel.worldRotation)
    local gy = BallDropLevel.worldGravity * math.cos(BallDropLevel.worldRotation)
    BallDropLevel.world:setGravity(gx, gy)
end

function BallDropLevel:trackBall(dt)
    if not BallDropLevel.success then
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
    else 
        local targetX = 120
        local targetY = BallDropLevel.successY
        BallDropLevel.cameraX = BallDropLevel.cameraX + (targetX - BallDropLevel.cameraX) * dt * 0.5
        BallDropLevel.cameraY = BallDropLevel.cameraY + (targetY - BallDropLevel.cameraY) * dt * 0.5
        BallDropLevel.cam:lookAt(BallDropLevel.cameraX, BallDropLevel.cameraY)
    end
end

function BallDropLevel:controlEnvironment(dt)
    if not BallDropLevel.success then
        InputManager = require("Game.Input.InputManager")
        if InputManager:isRightRudderPressed() then
            BallDropLevel.worldRotation = BallDropLevel.worldRotation + dt * BallDropLevel.worldRotateSpeed
        elseif InputManager:isLeftRudderPressed() then
            BallDropLevel.worldRotation = BallDropLevel.worldRotation - dt * BallDropLevel.worldRotateSpeed
        end
        
        local crankVal = InputManager:getCrankValue()
        BallDropLevel.worldRotation = BallDropLevel.worldRotation + crankVal * BallDropLevel.worldRotateSpeed
    else 
        local targetRotation = 0
        local angleDiff = targetRotation - BallDropLevel.worldRotation
        
        while angleDiff > math.pi do angleDiff = angleDiff - 2 * math.pi end
        while angleDiff < -math.pi do angleDiff = angleDiff + 2 * math.pi end
        
        BallDropLevel.worldRotation = BallDropLevel.worldRotation + angleDiff * dt * BallDropLevel.worldRotateSpeed
    end     
end

function BallDropLevel:draw(windowWidth, windowHeight)
    love.graphics.push()
    if not BallDropLevel.loadScreen:isDone() then
        BallDropLevel.loadScreen:draw()
        return
    end

    love.graphics.clear(176/255, 174/255, 167/255, 1)
    local scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode = ResizeWindowTransform.getTransform(windowWidth, windowHeight, BASE_W, BASE_H)
    love.graphics.translate(offsetXCameraMode, offsetYCameraMode)
    love.graphics.scale(scale, scale)
    
    
    BallDropLevel.cam:attach()
        local layers = BallDropLevel.gameMap.layers
        if layers["Background"] then BallDropLevel.gameMap:drawLayer(layers["Background"]) end
        if layers["Wall"] then BallDropLevel.gameMap:drawLayer(layers["Wall"]) end
        if layers["NonCollidable"] then BallDropLevel.gameMap:drawLayer(layers["NonCollidable"]) end
        if layers["Enemies"] then BallDropLevel.gameMap:drawLayer(layers["Enemies"]) end
        if layers["Magnetic"] then BallDropLevel.gameMap:drawLayer(layers["Magnetic"]) end
        
        TiledUtils.drawTileObjectLayer(BallDropLevel.gameMap, "Stars", love.timer.getTime())
        BallDropLevel.hinge1:draw()
        BallDropLevel.hinge2:draw()
        BallDropLevel.hinge3:draw()
        BallDropLevel.hinge4:draw()
        BallDropLevel.starActivateAnimation:draw()
        
        BallDropLevel.world:draw() 
        if BallDropLevel.ball.ballY < BallDropLevel.successY + 100 then
            BallDropLevel.ball:draw()
        end
        BallDropLevel.blocker:draw()
        BallDropLevel.lever1:draw()
        local spikeBlockX, spikeBlockY = BallDropLevel.spikeBlockCollider:getPosition()
        love.graphics.draw(
            BallDropLevel.spikeBlockImage,
            spikeBlockX, spikeBlockY,
            BallDropLevel.spikeBlockCollider.body:getAngle(),
            1, 1,
            BallDropLevel.spikeBlockImage:getWidth() / 2, BallDropLevel.spikeBlockImage:getHeight() / 2
        )
        love.graphics.setColor(1, 0, 0, 1)
            -- Debug: draw a red circle at the spike block's initial position
            love.graphics.circle("fill", BallDropLevel.spikeBlockInitPosition.x, BallDropLevel.spikeBlockInitPosition.y, 5)
        love.graphics.setColor(1, 1, 1, 1)
    BallDropLevel.cam:detach()

    love.graphics.push()
    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
    love.graphics.pop()
end

function BallDropLevel:unload()
end

return BallDropLevel