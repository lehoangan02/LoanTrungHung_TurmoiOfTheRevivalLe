local Soldier = {}
Soldier.__index = Soldier

local anim8 = require "Game/Libraries/anim8"

local InputManager = require("Game.Input.InputManager")

local SoldierStateEnum = {
    Idle = 0,
    Walking = 1,
    PickingBall = 2,
    CarryingBall = 3,
    PrepareDrop = 4,
    DroppingBall = 5,
}

function Soldier:load()

    Soldier.state = SoldierStateEnum.Idle

    Soldier.crankValue = 0

    Soldier.positionX = 0
    Soldier.positionY = 0

    Soldier.topCannonBallSprite = love.graphics.newImage("Resources/Images/TopCannonBall.png")
    Soldier.topCannonBallSprite:setFilter("nearest", "nearest")

    Soldier.idleSpriteSheet = love.graphics.newImage("Resources/Images/SoldierIdle.png")
    Soldier.idleSpriteSheet:setFilter("nearest", "nearest")
    local idleGrid = anim8.newGrid(240, 240, Soldier.idleSpriteSheet:getWidth(), Soldier.idleSpriteSheet:getHeight())
    Soldier.idleAnimation = anim8.newAnimation(idleGrid('1-8',1), 0.2)

    Soldier.walkingSpriteSheet = love.graphics.newImage("Resources/Images/SoldierWalking.png")
    Soldier.walkingSpriteSheet:setFilter("nearest", "nearest")
    local walkingGrid = anim8.newGrid(240, 240, Soldier.walkingSpriteSheet:getWidth(), Soldier.walkingSpriteSheet:getHeight())
    Soldier.walkingAnimation = anim8.newAnimation(walkingGrid('1-10',1), 0.1)

    Soldier.pickingBallSpriteSheet = love.graphics.newImage("Resources/Images/SoldierPick.png")
    Soldier.pickingBallSpriteSheet:setFilter("nearest", "nearest")
    local pickingBallGrid = anim8.newGrid(240, 240, Soldier.pickingBallSpriteSheet:getWidth(), Soldier.pickingBallSpriteSheet:getHeight())
    Soldier.pickingBallAnimation = anim8.newAnimation(pickingBallGrid('1-14',1), 0.2)

    Soldier.carryingBallSpriteSheet = love.graphics.newImage("Resources/Images/SoldierCarryBall.png")
    Soldier.carryingBallSpriteSheet:setFilter("nearest", "nearest")
    local carryingBallGrid = anim8.newGrid(240, 240, Soldier.carryingBallSpriteSheet:getWidth(), Soldier.carryingBallSpriteSheet:getHeight())
    Soldier.carryingBallAnimation = anim8.newAnimation(carryingBallGrid('1-10',1), 0.12)

    Soldier.prepareDropBallSpriteSheet = love.graphics.newImage("Resources/Images/SoldierPrepareDrop.png")
    Soldier.prepareDropBallSpriteSheet:setFilter("nearest", "nearest")
    local prepareDropBallGrid = anim8.newGrid(240, 240, Soldier.prepareDropBallSpriteSheet:getWidth(), Soldier.prepareDropBallSpriteSheet:getHeight())
    Soldier.prepareDropBallAnimation = anim8.newAnimation(prepareDropBallGrid('1-3',1), 0.12, 'pauseAtEnd')

end

function Soldier:update(dt)
    -- print("Soldier State: " .. Soldier.state)
    -- print("Soldier PositionX: " .. Soldier.positionX)
    if Soldier.stop then
        return
    end
    
    Soldier.crankValue = Soldier.crankValue + InputManager:getCrankValue()

    local moveSpeed = 1000
    local carrySpeed = 800
    if (Soldier.state == SoldierStateEnum.Idle) then
        if (InputManager:getCrankValue() < -0.01) then
            Soldier.state = SoldierStateEnum.Walking
            Soldier.positionX = Soldier.positionX + InputManager:getCrankValue() * moveSpeed * dt
        end
    elseif (Soldier.state == SoldierStateEnum.Walking) then
        local crankVal = InputManager:getCrankValue()
        Soldier.positionX = Soldier.positionX + crankVal * moveSpeed * dt
        if (Soldier.positionX > 0) then
            Soldier.positionX = 0
        end
    elseif (Soldier.state == SoldierStateEnum.CarryingBall) then
        local crankVal = InputManager:getCrankValue()
        Soldier.positionX = Soldier.positionX + crankVal * carrySpeed * dt
    end

    if (Soldier.state == SoldierStateEnum.Idle) then
        Soldier.idleAnimation:update(dt)
    elseif (Soldier.state == SoldierStateEnum.Walking) then
        if (Soldier.positionX ~= 0) then
            Soldier.walkingAnimation:update(dt * - InputManager:getCrankValue() * 60)
        end
    elseif (Soldier.state == SoldierStateEnum.PickingBall) then
        Soldier.pickingBallAnimation:update(dt * - InputManager:getCrankValue() * 60)
    elseif (Soldier.state == SoldierStateEnum.CarryingBall) then
        Soldier.carryingBallAnimation:update(dt * - InputManager:getCrankValue() * 60)
    elseif (Soldier.state == SoldierStateEnum.PrepareDrop) then
        Soldier.prepareDropBallAnimation:update(dt * - InputManager:getCrankValue() * 60)
        print("Crank Value: ", Soldier.crankValue)
    end

    if (Soldier.crankValue > 0 and Soldier.state == SoldierStateEnum.Walking) then
        Soldier.crankValue = 0
        Soldier.positionX = 0
        Soldier.state = SoldierStateEnum.Idle
        Soldier.idleAnimation:gotoFrame(1)
    end
    
    if (Soldier.crankValue < -2.5 and Soldier.state == SoldierStateEnum.Walking) then
        print("Reached the pick point!")
        print("Current animation frame: ", Soldier.walkingAnimation.position)
        print("Crank Value: ", Soldier.crankValue)
        Soldier.state = SoldierStateEnum.PickingBall
        Soldier.pickingBallAnimation:gotoFrame(1)
        Soldier.crankValue = -2.5
        Soldier.positionX = 0
    end

    if (Soldier.crankValue > -2.5 and Soldier.state == SoldierStateEnum.PickingBall) then
        Soldier.crankValue = -2.5
        Soldier.positionX = -42
        Soldier.state = SoldierStateEnum.Walking
        Soldier.walkingAnimation:gotoFrame(2)
    end

    if (Soldier.crankValue < -5 and Soldier.state == SoldierStateEnum.PickingBall) then
        print("Current animation frame: ", Soldier.pickingBallAnimation.position)
        Soldier.crankValue = -5
        Soldier.positionX = 0
        Soldier.state = SoldierStateEnum.CarryingBall
        Soldier.carryingBallAnimation:gotoFrame(1)
    end

    if (Soldier.crankValue > -5 and Soldier.state == SoldierStateEnum.CarryingBall) then
        Soldier.crankValue = -5
        Soldier.positionX = 0
        Soldier.state = SoldierStateEnum.PickingBall
        Soldier.walkingAnimation:gotoFrame(13)
    end

    if (Soldier.crankValue < -7.4 and Soldier.state == SoldierStateEnum.CarryingBall) then
        print("Current animation frame: ", Soldier.carryingBallAnimation.position)
        print("Crank Value: ", Soldier.crankValue)
        Soldier.crankValue = -7.4
        print("Current positionX: ", Soldier.positionX)
        Soldier.positionX = -33
        Soldier.state = SoldierStateEnum.PrepareDrop
    end

    if (Soldier.crankValue > -7.4 and Soldier.state == SoldierStateEnum.PrepareDrop) then
        Soldier.crankValue = -7
        Soldier.positionX = -33
        Soldier.state = SoldierStateEnum.CarryingBall
        Soldier.carryingBallAnimation:gotoFrame(7)
    end

    if (Soldier.state == SoldierStateEnum.PrepareDrop and Soldier.crankValue < -8) then
        print("Crank Value: ", Soldier.crankValue)
        Soldier.stop = true
    end
end

function Soldier:draw()
    if (Soldier.state == SoldierStateEnum.Idle) then
        Soldier.idleAnimation:draw(Soldier.idleSpriteSheet, Soldier.positionX, Soldier.positionY)
    elseif (Soldier.state == SoldierStateEnum.Walking) then
        Soldier.walkingAnimation:draw(Soldier.walkingSpriteSheet, Soldier.positionX, Soldier.positionY)
    elseif (Soldier.state == SoldierStateEnum.PickingBall) then
        Soldier.pickingBallAnimation:draw(Soldier.pickingBallSpriteSheet, Soldier.positionX, Soldier.positionY)
    elseif (Soldier.state == SoldierStateEnum.CarryingBall) then
        Soldier.carryingBallAnimation:draw(Soldier.carryingBallSpriteSheet, Soldier.positionX, Soldier.positionY)
    elseif (Soldier.state == SoldierStateEnum.PrepareDrop) then
        Soldier.prepareDropBallAnimation:draw(Soldier.prepareDropBallSpriteSheet, Soldier.positionX, Soldier.positionY)
    end

    if (Soldier.state == SoldierStateEnum.Idle or Soldier.state == SoldierStateEnum.Walking) then
        love.graphics.draw(Soldier.topCannonBallSprite, 0, 0)
    end
end

return Soldier