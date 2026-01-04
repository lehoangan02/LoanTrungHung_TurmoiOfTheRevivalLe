local Level = require "Game.Levels.Level"
local BallDropLevel = setmetatable({}, { __index = Level })
BallDropLevel.__index = BallDropLevel

local InputManager = require("Game.Input.InputManager")
local Ball = require("Game.Levels.BallDrop.Ball")

function BallDropLevel:load()
    local sti = require "Game/Libraries/sti"
    BallDropLevel.gameMap = sti("Game/Maps/testMap.lua")

    BallDropLevel.worldGravity = 200
    BallDropLevel.worldRotation = 0

    local wf = require("Game/Libraries/windfield")
    BallDropLevel.world = wf.newWorld(0, BallDropLevel.worldGravity, false)
    BallDropLevel.world:addCollisionClass("Enemies")

    BallDropLevel.walls = {}
    if BallDropLevel.gameMap.layers["StaticCollidable"] then
        for _, obj in pairs(BallDropLevel.gameMap.layers["StaticCollidable"].objects) do
            local wall = BallDropLevel.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(BallDropLevel.walls, wall)
        end
    end

    BallDropLevel.enemies = {}
    if BallDropLevel.gameMap.layers["EnemiesCollidable"] then
        for _, obj in pairs(BallDropLevel.gameMap.layers["EnemiesCollidable"].objects) do
            local enemy = BallDropLevel.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            enemy:setType("static")
            enemy:setCollisionClass("Enemies")
            table.insert(BallDropLevel.enemies, enemy)
        end
    end

    BallDropLevel.ball = Ball:new(BallDropLevel.world, 100, 50)

    BallDropLevel.cameraX = 120
    BallDropLevel.cameraY = 50
    BallDropLevel.currentZoom = 1.0
    BallDropLevel.zoomSpeed = 0.15

    local camera = require("Game.Libraries.camera")
    BallDropLevel.cam = camera()
end

function BallDropLevel:update(dt)
    BallDropLevel.gameMap:update(dt)
    BallDropLevel.world:update(dt)

    BallDropLevel:adjustGravity()
    BallDropLevel:controlEnvironment(dt)

    BallDropLevel.ball:update(dt, BallDropLevel.world)

    if InputManager:isEventFKeyPressed() then
        BallDropLevel.ball:explode()
    end

    local bx, by = BallDropLevel.ball:getPosition()
    if bx then
        BallDropLevel:trackBall(dt, bx, by)
    end
end

function BallDropLevel:adjustGravity()
    local gx = BallDropLevel.worldGravity * math.sin(BallDropLevel.worldRotation)
    local gy = BallDropLevel.worldGravity * math.cos(BallDropLevel.worldRotation)
    BallDropLevel.world:setGravity(gx, gy)
end

function BallDropLevel:trackBall(dt, ballX, ballY)
    local lookAhead = 30
    local deltaY = ballY - BallDropLevel.cameraY

    local targetY = ballY
    if deltaY > 40 then
        targetY = ballY + lookAhead
    elseif deltaY < -40 then
        targetY = ballY - lookAhead / 2
    end

    BallDropLevel.cameraY = BallDropLevel.cameraY + (targetY - BallDropLevel.cameraY) * dt * 0.6

    local targetX = ballX * 0.4 + 120 * 0.6
    BallDropLevel.cameraX = BallDropLevel.cameraX + (targetX - BallDropLevel.cameraX) * dt * 0.1

    local desiredZoom = 1.0
    if ballX < 60 or ballX > 180 then
        desiredZoom = 1.1
    end

    BallDropLevel.currentZoom =
        BallDropLevel.currentZoom +
        (desiredZoom - BallDropLevel.currentZoom) * dt * BallDropLevel.zoomSpeed

    BallDropLevel.cam:zoomTo(BallDropLevel.currentZoom)
    BallDropLevel.cam:lookAt(BallDropLevel.cameraX, BallDropLevel.cameraY)
end

function BallDropLevel:controlEnvironment(dt)
    local baseSpeed = 2

    if InputManager:isRightRudderPressed() then
        BallDropLevel.worldRotation =
            BallDropLevel.worldRotation + dt * baseSpeed
        BallDropLevel.cam:rotate(dt * baseSpeed)

    elseif InputManager:isLeftRudderPressed() then
        BallDropLevel.worldRotation =
            BallDropLevel.worldRotation - dt * baseSpeed
        BallDropLevel.cam:rotate(-dt * baseSpeed)
    end

    local handCrankMultiplier = 3

    if InputManager:isEventKY040RightTurned() then
        BallDropLevel.worldRotation =
            BallDropLevel.worldRotation + dt * baseSpeed * handCrankMultiplier
        BallDropLevel.cam:rotate(dt * baseSpeed * handCrankMultiplier)

    elseif InputManager:isEventKY040LeftTurned() then
        BallDropLevel.worldRotation =
            BallDropLevel.worldRotation - dt * baseSpeed * handCrankMultiplier
        BallDropLevel.cam:rotate(-dt * baseSpeed * handCrankMultiplier)
    end

    local joystickMultiplier = 4
    local stickRotation =
        InputManager:getLeftStickRotation() +
        InputManager:getRightStickRotation()

    BallDropLevel.worldRotation =
        BallDropLevel.worldRotation +
        stickRotation * dt * baseSpeed * joystickMultiplier

    BallDropLevel.cam:rotate(
        stickRotation * dt * baseSpeed * joystickMultiplier
    )

    local triggerMultiplier = 0.8

    local leftTrigger = InputManager:getLeftTriggerValue()
    BallDropLevel.worldRotation =
        BallDropLevel.worldRotation +
        leftTrigger * dt * baseSpeed * triggerMultiplier
    BallDropLevel.cam:rotate(
        leftTrigger * dt * baseSpeed * triggerMultiplier
    )

    local rightTrigger = InputManager:getRightTriggerValue()
    BallDropLevel.worldRotation =
        BallDropLevel.worldRotation -
        rightTrigger * dt * baseSpeed * triggerMultiplier
    BallDropLevel.cam:rotate(
        -rightTrigger * dt * baseSpeed * triggerMultiplier
    )
end


function BallDropLevel:draw(windowWidth, windowHeight)
    love.graphics.clear(176/255, 174/255, 167/255, 1)

    BallDropLevel.cam:attach()
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Background"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Wall"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["NonCollidable"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Enemies"])
        BallDropLevel.world:draw()
        BallDropLevel.ball:draw()
    BallDropLevel.cam:detach()

    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

function BallDropLevel:unload()
end

return BallDropLevel
