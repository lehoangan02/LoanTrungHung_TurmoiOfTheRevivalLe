local Level = require("Game.Levels.Level")
local BlastFortLevel = setmetatable({}, {__index = Level})
BlastFortLevel.__index = BlastFortLevel

local bf = require("Game/Libraries/breezefield-master")
local DEBUG = false

local StatefulObject = require("Game.Components.StatefulObject")
local InterpolationEnum = require("Game.Custom.InterpolationEnum")
local LoadScreen = require("Game.Levels.LoadScreen.LoadScreen")
local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")

function BlastFortLevel:load()

    print("Loading blast fort level!")
    BlastFortLevel.loadScreen = LoadScreen.new("Resources/Images/Hoangho_gt.jpg")

    BlastFortLevel.loadScreen:reset()

    BlastFortLevel.loadScreen:addTask(function()
        print("Dummy task 1 - waiting...")
        love.timer.sleep(0.1)
        print("Dummy task 1 - done!")
    end, 20)

    BlastFortLevel.loadScreen:addTask(function()
        print("Dummy task 2 - waiting...")
        love.timer.sleep(0.15)
        print("Dummy task 2 - done!")
    end, 25)

    BlastFortLevel.loadScreen:addTask(function()
        print("Dummy task 3 - waiting...")
        love.timer.sleep(0.2)
        print("Dummy task 3 - done!")
    end, 30)

    BlastFortLevel.loadScreen:addTask(function()
        print("Dummy task 4 - loading actual level...")
        love.timer.sleep(0.2)
        print("Dummy task 4 - done!")
    end, 25)

    BlastFortLevel.loadScreen:start()

    BlastFortLevel.worldGravity = 250
    BlastFortLevel.world = bf.newWorld(0, BlastFortLevel.worldGravity, true)

    BlastFortLevel.timer = 0

    BlastFortLevel.controlBooleans = {}
    BlastFortLevel.controlBooleans.pulledTowerToPosition = false

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
    BlastFortLevel.towerFrontStatefulObject:setPosition(-100, -100, 1)
    BlastFortLevel.towerFrontStatefulObject:setState(1)
    BlastFortLevel.towerFrontStatefulObject:setInterpolation(InterpolationEnum.InterpolationTypeEnum.Linear, InterpolationEnum.InterpolationDirection.InOut, 1)
    BlastFortLevel.towerFrontStatefulObject:cloneState(1)
    BlastFortLevel.towerFrontStatefulObject:setPosition(0, 0, 2)
    BlastFortLevel.towerBackStatefulObject = StatefulObject:new()
    BlastFortLevel.towerBackStatefulObject:addSprite(BlastFortLevel.backTowerSprite)
    print("Set the first time")
    BlastFortLevel.towerBackStatefulObject:setPosition(-100, -100, 1)
    BlastFortLevel.towerBackStatefulObject:setState(1)
    BlastFortLevel.towerBackStatefulObject:setInterpolation(InterpolationEnum.InterpolationTypeEnum.Linear, InterpolationEnum.InterpolationDirection.InOut, 1)
    BlastFortLevel.towerBackStatefulObject:cloneState(1)
    BlastFortLevel.towerBackStatefulObject:setPosition(0, 0, 2)



    BlastFortLevel.targetSize = { centerX = 160, centerY = 140, width = 4, height = 30 }
    BlastFortLevel.targetCollider = BlastFortLevel.world:newCollider("Rectangle",
    { BlastFortLevel.targetSize.centerX, BlastFortLevel.targetSize.centerY, BlastFortLevel.targetSize.width, BlastFortLevel.targetSize.height})
    BlastFortLevel.targetCollider:setAngle(math.rad(-22))
    BlastFortLevel.targetCollider.body:setGravityScale(0)
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
        BlastFortLevel.controlBooleans.pulledTowerToPosition = true
        print("Moved!")
    end
    BlastFortLevel.towerBackStatefulObject:update(dt)
    BlastFortLevel.towerFrontStatefulObject:update(dt)

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
    BlastFortLevel.world:draw()
    love.graphics.pop()
end

function BlastFortLevel:unload()
end

return BlastFortLevel
