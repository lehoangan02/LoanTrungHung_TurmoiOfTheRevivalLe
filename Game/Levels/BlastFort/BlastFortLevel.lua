local Level = require("Game.Levels.Level")
local BlastFortLevel = setmetatable({}, {__index = Level})
BlastFortLevel.__index = BlastFortLevel

local bf = require("Game/Libraries/breezefield-master")
local DEBUG = false

local StatefulObject = require("Game.Components.StatefulObject")
local InterpolationEnum = require("Game.Custom.InterpolationEnum")
local LoadScreen = require("Game.Levels.LoadScreen.LoadScreen")
local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")
local TrajectoryVisualization = require("Game.Components.TrajectoryVisualization")
local Ball = require("Game.Levels.NgocHoi.Ball")
local InputManager = require("Game.Input.InputManager")

function BlastFortLevel:load()

    print("Loading blast fort level!")
    BlastFortLevel.loadScreen = LoadScreen.new("Resources/Images/Hoangho_gt.jpg")

    BlastFortLevel.loadScreen:reset()

    BlastFortLevel.loadScreen:addTask(function(asyncWait)
        print("Dummy task 1 - waiting...")
        asyncWait(0.1)
        print("Dummy task 1 - done!")
    end, 20)

    BlastFortLevel.loadScreen:addTask(function(asyncWait)
        print("Dummy task 2 - waiting...")
        asyncWait(0.15)
        print("Dummy task 2 - done!")
    end, 25)

    BlastFortLevel.loadScreen:addTask(function(asyncWait)
        print("Dummy task 3 - waiting...")
        asyncWait(0.2)
        print("Dummy task 3 - done!")
    end, 30)

    BlastFortLevel.loadScreen:addTask(function(asyncWait)
        print("Dummy task 4 - loading actual level...")
        asyncWait(0.2)
        print("Dummy task 4 - done!")
    end, 25)

    BlastFortLevel.loadScreen:start()

    BlastFortLevel.worldGravity = 250
    BlastFortLevel.world = bf.newWorld(0, BlastFortLevel.worldGravity, true)

    BlastFortLevel.timer = 0

    BlastFortLevel.controlBooleans = {}
    BlastFortLevel.controlBooleans.pulledTowerToPosition = false
    BlastFortLevel.controlBooleans.displayTrajectoryVisualization = false

    BlastFortLevel.intactSprite = love.graphics.newImage("Resources/Images/CannonBlastFort.png")
    BlastFortLevel.intactSprite:setFilter("nearest", "nearest")
    BlastFortLevel.blownSprite = love.graphics.newImage("Resources/Images/CannonBlownFort.png")
    BlastFortLevel.blownSprite:setFilter("nearest", "nearest")
    BlastFortLevel.fortStatefulObject = StatefulObject:new()
    BlastFortLevel.fortStatefulObject:addSprite(BlastFortLevel.intactSprite)
    BlastFortLevel.fortStatefulObject:addSprite(BlastFortLevel.blownSprite)
    BlastFortLevel.fortStatefulObject:setState(1)

    BlastFortLevel.frontTowerSprite = love.graphics.newImage("Resources/Images/SmallTowerFront.png")
    BlastFortLevel.frontTowerSprite:setFilter("nearest", "nearest")
    BlastFortLevel.backTowerSprite = love.graphics.newImage("Resources/Images/SmallTowerBack.png")
    BlastFortLevel.backTowerSprite:setFilter("nearest", "nearest")
    BlastFortLevel.towerFrontStatefulObject = StatefulObject:new()
    BlastFortLevel.towerFrontStatefulObject:addSprite(BlastFortLevel.frontTowerSprite)
    print("Set the first time")
    BlastFortLevel.towerFrontStatefulObject:setPosition(-100, 0, 1)
    BlastFortLevel.towerFrontStatefulObject:setState(1)
    BlastFortLevel.towerFrontStatefulObject:setInterpolation(InterpolationEnum.InterpolationTypeEnum.EaseCubic, InterpolationEnum.InterpolationDirection.InOut, 2, 1)
    BlastFortLevel.towerFrontStatefulObject:cloneState(1)
    BlastFortLevel.towerFrontStatefulObject:setPosition(0, 0, 2)
    BlastFortLevel.towerFrontStatefulObject:setInterpolation(InterpolationEnum.InterpolationTypeEnum.EaseCubic, InterpolationEnum.InterpolationDirection.InOut, 2, 1)
    BlastFortLevel.towerBackStatefulObject = StatefulObject:new()
    BlastFortLevel.towerBackStatefulObject:addSprite(BlastFortLevel.backTowerSprite)
    print("Set the first time")
    BlastFortLevel.towerBackStatefulObject:setPosition(-100, 0, 1)
    BlastFortLevel.towerBackStatefulObject:setState(1)
    BlastFortLevel.towerBackStatefulObject:setInterpolation(InterpolationEnum.InterpolationTypeEnum.EaseCubic, InterpolationEnum.InterpolationDirection.InOut, 2, 1)
    BlastFortLevel.towerBackStatefulObject:cloneState(1)
    BlastFortLevel.towerBackStatefulObject:setPosition(0, 0, 2)

    BlastFortLevel.LAUNCH_SPEED = 230
    BlastFortLevel.trajectoryVisualization = TrajectoryVisualization:new(38, 130, BlastFortLevel.LAUNCH_SPEED, math.rad(-30), BlastFortLevel.worldGravity)

    BlastFortLevel.targetSize = { centerX = 158, centerY = 138, width = 4, height = 24 }
    BlastFortLevel.targetCollider = BlastFortLevel.world:newCollider("Rectangle",
    { BlastFortLevel.targetSize.centerX, BlastFortLevel.targetSize.centerY, BlastFortLevel.targetSize.width, BlastFortLevel.targetSize.height})
    BlastFortLevel.targetCollider:setAngle(math.rad(12))
    BlastFortLevel.targetCollider.body:setGravityScale(0)
    BlastFortLevel.targetCollider:setType("static")

    BlastFortLevel.cannonBall = Ball.new(BlastFortLevel.world, BlastFortLevel.LAUNCH_SPEED, function(duration, magnitude) end)
    BlastFortLevel.targetCollider.parent = BlastFortLevel
    function BlastFortLevel.targetCollider:enter(other, collision)
        if other.isBall then
            print("Target hit!")
            BlastFortLevel.fortStatefulObject:setState(2)
            other.parent.to_explode = true
            BlastFortLevel.fortStatefulObject:setState(2)
            BlastFortLevel.targetCollider:destroy()
            BlastFortLevel.controlBooleans.displayTrajectoryVisualization = false
        end
    end

    BlastFortLevel.groundCollider = BlastFortLevel.world:newCollider("Rectangle",
        {120, 180, 240, 5}
    )
    BlastFortLevel.groundCollider:setGravityScale(0)
    BlastFortLevel.groundCollider:setType("static")
    function BlastFortLevel.groundCollider:enter(other, collision)
        if other.isBall then
            print("Ball hit the ground")
            other.parent.to_explode = true
            BlastFortLevel.controlBooleans.displayTrajectoryVisualization = false
        end
    end
end

function BlastFortLevel:update(dt)
    if not BlastFortLevel.loadScreen:isDone() then
        BlastFortLevel.loadScreen:update(dt)
        return LevelEnum.Nothing
    end
    BlastFortLevel.timer = BlastFortLevel.timer + dt
    if BlastFortLevel.timer >= 1 and BlastFortLevel.controlBooleans.pulledTowerToPosition == false then
        BlastFortLevel.towerBackStatefulObject:setState(2)
        BlastFortLevel.towerFrontStatefulObject:setState(2)
        -- print("Moved!")
    end
    if BlastFortLevel.towerFrontStatefulObject:isLocatedAtIndexPosition(2) then 
        if BlastFortLevel.controlBooleans.pulledTowerToPosition == false then
            BlastFortLevel.controlBooleans.displayTrajectoryVisualization = true
        end
        BlastFortLevel.controlBooleans.pulledTowerToPosition = true
        
    end
    BlastFortLevel.towerBackStatefulObject:update(dt)
    BlastFortLevel.towerFrontStatefulObject:update(dt)
    BlastFortLevel.trajectoryVisualization:update(dt)
    BlastFortLevel.cannonBall:update(dt)

    if BlastFortLevel.controlBooleans.displayTrajectoryVisualization then
        if InputManager:isEventFKeyPressed() and BlastFortLevel.controlBooleans.pulledTowerToPosition then
            print("Fired cannonball!")
            BlastFortLevel.cannonBall:toss(38, 130, math.deg(-BlastFortLevel.trajectoryVisualization.launchAngle))
        end
    end

    BlastFortLevel.world:update(dt)

    return LevelEnum.Nothing
end

function BlastFortLevel:draw(windowWidth, windowHeight)
    if not BlastFortLevel.loadScreen:isDone() then
        BlastFortLevel.loadScreen:draw()
        return
    end

    love.graphics.push()
    local scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode = ResizeWindowTransform.getTransform(windowWidth, windowHeight, BASE_W, BASE_H)
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    BlastFortLevel.fortStatefulObject:draw(0, 0)
    BlastFortLevel.towerBackStatefulObject:drawAutonomously()
    BlastFortLevel.towerFrontStatefulObject:drawAutonomously()
    if BlastFortLevel.controlBooleans.displayTrajectoryVisualization then 
        BlastFortLevel.trajectoryVisualization:draw(windowWidth, windowHeight)
    end
    BlastFortLevel.cannonBall:draw()
    BlastFortLevel.world:draw()
    love.graphics.pop()
end

function BlastFortLevel:unload()
end

return BlastFortLevel
