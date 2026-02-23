local DropRoleSoldier = {}
DropRoleSoldier.__index = DropRoleSoldier

local anim8 = require "Game/Libraries/anim8"

local InputManager = require("Game.Input.InputManager")

local SoldierStateEnum = {
    Idle = 0,
    Walking = 1,
    PickingBall = 2,
    CarryingBall = 3,
    PrepareDrop = 4,
    DroppingBall = 5,
    DroppedBall = 6
}

function DropRoleSoldier:load()

    DropRoleSoldier.state = SoldierStateEnum.Idle

    DropRoleSoldier.crankValue = 0

    DropRoleSoldier.positionX = 0
    DropRoleSoldier.positionY = 0

    DropRoleSoldier.topCannonBallSprite = love.graphics.newImage("Resources/Images/TopCannonBall.png")
    DropRoleSoldier.topCannonBallSprite:setFilter("nearest", "nearest")

    DropRoleSoldier.idleSpriteSheet = love.graphics.newImage("Resources/Images/SoldierIdle.png")
    DropRoleSoldier.idleSpriteSheet:setFilter("nearest", "nearest")
    local idleGrid = anim8.newGrid(240, 240, DropRoleSoldier.idleSpriteSheet:getWidth(), DropRoleSoldier.idleSpriteSheet:getHeight())
    DropRoleSoldier.idleAnimation = anim8.newAnimation(idleGrid('1-8',1), 0.2)

    DropRoleSoldier.walkingSpriteSheet = love.graphics.newImage("Resources/Images/SoldierWalking.png")
    DropRoleSoldier.walkingSpriteSheet:setFilter("nearest", "nearest")
    local walkingGrid = anim8.newGrid(240, 240, DropRoleSoldier.walkingSpriteSheet:getWidth(), DropRoleSoldier.walkingSpriteSheet:getHeight())
    DropRoleSoldier.walkingAnimation = anim8.newAnimation(walkingGrid('1-10',1), 0.1)

    DropRoleSoldier.pickingBallSpriteSheet = love.graphics.newImage("Resources/Images/SoldierPick.png")
    DropRoleSoldier.pickingBallSpriteSheet:setFilter("nearest", "nearest")
    local pickingBallGrid = anim8.newGrid(240, 240, DropRoleSoldier.pickingBallSpriteSheet:getWidth(), DropRoleSoldier.pickingBallSpriteSheet:getHeight())
    DropRoleSoldier.pickingBallAnimation = anim8.newAnimation(pickingBallGrid('1-14',1), 0.2)

    DropRoleSoldier.carryingBallSpriteSheet = love.graphics.newImage("Resources/Images/SoldierCarryBall.png")
    DropRoleSoldier.carryingBallSpriteSheet:setFilter("nearest", "nearest")
    local carryingBallGrid = anim8.newGrid(240, 240, DropRoleSoldier.carryingBallSpriteSheet:getWidth(), DropRoleSoldier.carryingBallSpriteSheet:getHeight())
    DropRoleSoldier.carryingBallAnimation = anim8.newAnimation(carryingBallGrid('1-10',1), 0.12)

    DropRoleSoldier.prepareDropBallSpriteSheet = love.graphics.newImage("Resources/Images/SoldierPrepareDrop.png")
    DropRoleSoldier.prepareDropBallSpriteSheet:setFilter("nearest", "nearest")
    local prepareDropBallGrid = anim8.newGrid(240, 240, DropRoleSoldier.prepareDropBallSpriteSheet:getWidth(), DropRoleSoldier.prepareDropBallSpriteSheet:getHeight())
    DropRoleSoldier.prepareDropBallAnimation = anim8.newAnimation(prepareDropBallGrid('1-3',1), 0.12, 'pauseAtEnd')

    DropRoleSoldier.droppedBallSprite = love.graphics.newImage("Resources/Images/SoldierDropped.png")
    DropRoleSoldier.droppedBallSprite:setFilter("nearest", "nearest")
    DropRoleSoldier.overlappingFloorLayerSprite = love.graphics.newImage("Resources/Images/OverlappingFloorLayer.png")
    DropRoleSoldier.overlappingFloorLayerSprite:setFilter("nearest", "nearest")
    
    DropRoleSoldier.gravity = 70
    DropRoleSoldier.ballPositionY = -3

end

function DropRoleSoldier:update(dt)
    -- print("Soldier State: " .. DropRoleSoldier.state)
    -- print("Soldier PositionX: " .. DropRoleSoldier.positionX)
    DropRoleSoldier.crankValue = DropRoleSoldier.crankValue + InputManager:getCrankValue()

    local moveSpeed = 1000
    local carrySpeed = 800
    if (DropRoleSoldier.state == SoldierStateEnum.Idle) then
        if (InputManager:getCrankValue() < -0.01) then
            DropRoleSoldier.state = SoldierStateEnum.Walking
            DropRoleSoldier.positionX = DropRoleSoldier.positionX + InputManager:getCrankValue() * moveSpeed * dt
        end
    elseif (DropRoleSoldier.state == SoldierStateEnum.Walking) then
        local crankVal = InputManager:getCrankValue()
        DropRoleSoldier.positionX = DropRoleSoldier.positionX + crankVal * moveSpeed * dt
        if (DropRoleSoldier.positionX > 0) then
            DropRoleSoldier.positionX = 0
        end
    elseif (DropRoleSoldier.state == SoldierStateEnum.CarryingBall) then
        local crankVal = InputManager:getCrankValue()
        DropRoleSoldier.positionX = DropRoleSoldier.positionX + crankVal * carrySpeed * dt
    end

    if (DropRoleSoldier.state == SoldierStateEnum.Idle) then
        DropRoleSoldier.idleAnimation:update(dt)
    elseif (DropRoleSoldier.state == SoldierStateEnum.Walking) then
        if (DropRoleSoldier.positionX ~= 0) then
            DropRoleSoldier.walkingAnimation:update(dt * - InputManager:getCrankValue() * 60)
        end
    elseif (DropRoleSoldier.state == SoldierStateEnum.PickingBall) then
        DropRoleSoldier.pickingBallAnimation:update(dt * - InputManager:getCrankValue() * 60)
    elseif (DropRoleSoldier.state == SoldierStateEnum.CarryingBall) then
        DropRoleSoldier.carryingBallAnimation:update(dt * - InputManager:getCrankValue() * 60)
    elseif (DropRoleSoldier.state == SoldierStateEnum.PrepareDrop) then
        DropRoleSoldier.prepareDropBallAnimation:update(dt * - InputManager:getCrankValue() * 60)
        print("Crank Value: ", DropRoleSoldier.crankValue)
    elseif (DropRoleSoldier.state == SoldierStateEnum.DroppedBall) then
        DropRoleSoldier.ballPositionY = DropRoleSoldier.ballPositionY + DropRoleSoldier.gravity * dt
        print("Ball Position Y: ", DropRoleSoldier.ballPositionY)
    end

    if (DropRoleSoldier.crankValue > 0 and DropRoleSoldier.state == SoldierStateEnum.Walking) then
        DropRoleSoldier.crankValue = 0
        DropRoleSoldier.positionX = 0
        DropRoleSoldier.state = SoldierStateEnum.Idle
        DropRoleSoldier.idleAnimation:gotoFrame(1)
    end
    
    if (DropRoleSoldier.crankValue < -2.5 and DropRoleSoldier.state == SoldierStateEnum.Walking) then
        print("Reached the pick point!")
        print("Current animation frame: ", DropRoleSoldier.walkingAnimation.position)
        print("Crank Value: ", DropRoleSoldier.crankValue)
        DropRoleSoldier.state = SoldierStateEnum.PickingBall
        DropRoleSoldier.pickingBallAnimation:gotoFrame(1)
        DropRoleSoldier.crankValue = -2.5
        DropRoleSoldier.positionX = 0
    end

    if (DropRoleSoldier.crankValue > -2.5 and DropRoleSoldier.state == SoldierStateEnum.PickingBall) then
        DropRoleSoldier.crankValue = -2.5
        DropRoleSoldier.positionX = -42
        DropRoleSoldier.state = SoldierStateEnum.Walking
        DropRoleSoldier.walkingAnimation:gotoFrame(2)
    end

    if (DropRoleSoldier.crankValue < -5 and DropRoleSoldier.state == SoldierStateEnum.PickingBall) then
        print("Current animation frame: ", DropRoleSoldier.pickingBallAnimation.position)
        DropRoleSoldier.crankValue = -5
        DropRoleSoldier.positionX = 0
        DropRoleSoldier.state = SoldierStateEnum.CarryingBall
        DropRoleSoldier.carryingBallAnimation:gotoFrame(1)
    end

    if (DropRoleSoldier.crankValue > -5 and DropRoleSoldier.state == SoldierStateEnum.CarryingBall) then
        DropRoleSoldier.crankValue = -5
        DropRoleSoldier.positionX = 0
        DropRoleSoldier.state = SoldierStateEnum.PickingBall
        DropRoleSoldier.walkingAnimation:gotoFrame(13)
    end

    if (DropRoleSoldier.crankValue < -7.4 and DropRoleSoldier.state == SoldierStateEnum.CarryingBall) then
        print("Current animation frame: ", DropRoleSoldier.carryingBallAnimation.position)
        print("Crank Value: ", DropRoleSoldier.crankValue)
        DropRoleSoldier.crankValue = -7.4
        print("Current positionX: ", DropRoleSoldier.positionX)
        DropRoleSoldier.positionX = -33
        DropRoleSoldier.state = SoldierStateEnum.PrepareDrop
    end

    if (DropRoleSoldier.crankValue > -7.4 and DropRoleSoldier.state == SoldierStateEnum.PrepareDrop) then
        DropRoleSoldier.crankValue = -7
        DropRoleSoldier.positionX = -33
        DropRoleSoldier.state = SoldierStateEnum.CarryingBall
        DropRoleSoldier.carryingBallAnimation:gotoFrame(7)
    end

    if (DropRoleSoldier.state == SoldierStateEnum.PrepareDrop and DropRoleSoldier.crankValue < -8) then
        DropRoleSoldier.state = SoldierStateEnum.DroppedBall
        print("Crank Value: ", DropRoleSoldier.crankValue)
    end

    local LevelEnum = require("Game.Levels.LevelEnum")

    if (DropRoleSoldier.ballPositionY > 50) then
        return LevelEnum.BallDrop
    end

    return LevelEnum.Nothing
end

function DropRoleSoldier:draw()
    if (DropRoleSoldier.state == SoldierStateEnum.Idle) then
        DropRoleSoldier.idleAnimation:draw(DropRoleSoldier.idleSpriteSheet, DropRoleSoldier.positionX, DropRoleSoldier.positionY)
    elseif (DropRoleSoldier.state == SoldierStateEnum.Walking) then
        DropRoleSoldier.walkingAnimation:draw(DropRoleSoldier.walkingSpriteSheet, DropRoleSoldier.positionX, DropRoleSoldier.positionY)
    elseif (DropRoleSoldier.state == SoldierStateEnum.PickingBall) then
        DropRoleSoldier.pickingBallAnimation:draw(DropRoleSoldier.pickingBallSpriteSheet, DropRoleSoldier.positionX, DropRoleSoldier.positionY)
    elseif (DropRoleSoldier.state == SoldierStateEnum.CarryingBall) then
        DropRoleSoldier.carryingBallAnimation:draw(DropRoleSoldier.carryingBallSpriteSheet, DropRoleSoldier.positionX, DropRoleSoldier.positionY)
    elseif (DropRoleSoldier.state == SoldierStateEnum.PrepareDrop) then
        DropRoleSoldier.prepareDropBallAnimation:draw(DropRoleSoldier.prepareDropBallSpriteSheet, DropRoleSoldier.positionX, DropRoleSoldier.positionY)
    elseif (DropRoleSoldier.state == SoldierStateEnum.DroppedBall) then
        love.graphics.draw(DropRoleSoldier.droppedBallSprite, DropRoleSoldier.positionX, DropRoleSoldier.positionY)

    end

    if (DropRoleSoldier.state == SoldierStateEnum.Idle or DropRoleSoldier.state == SoldierStateEnum.Walking) then
        love.graphics.draw(DropRoleSoldier.topCannonBallSprite, 0, 0)
    elseif (DropRoleSoldier.state == SoldierStateEnum.DroppedBall) then
        if (DropRoleSoldier.ballPositionY < 10) then
            love.graphics.draw(DropRoleSoldier.topCannonBallSprite, -33, DropRoleSoldier.ballPositionY)
        end
    end

    love.graphics.draw(DropRoleSoldier.overlappingFloorLayerSprite, 0, 0)
end

return DropRoleSoldier