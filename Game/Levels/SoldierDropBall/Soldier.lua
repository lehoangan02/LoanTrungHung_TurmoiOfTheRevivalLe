local Soldier = {}
Soldier.__index = Soldier

local anim8 = require "Game/Libraries/anim8"

local InputManager = require("Game.Input.InputManager")

local SoldierStateEnum = {
    Idle = 0,
    Walking = 1,
    PickingBall = 2,
    CarryingBall = 3,
    DroppingBall = 4,
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

end

function Soldier:update(dt)
    -- print("Soldier State: " .. Soldier.state)
    -- print("Soldier PositionX: " .. Soldier.positionX)
    if Soldier.stop then
        return
    end
    
    Soldier.crankValue = Soldier.crankValue + InputManager:getCrankValue()

    local moveSpeed = 1000
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
    end

    if (Soldier.state == SoldierStateEnum.Idle) then
        Soldier.idleAnimation:update(dt)
    elseif (Soldier.state == SoldierStateEnum.Walking) then
        if (Soldier.positionX ~= 0) then
            Soldier.walkingAnimation:update(dt * - InputManager:getCrankValue() * 60)
        end
    elseif (Soldier.state == SoldierStateEnum.PickingBall) then
        Soldier.pickingBallAnimation:update(dt * - InputManager:getCrankValue() * 60)
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

    if (Soldier.pickingBallAnimation.position == 14 and Soldier.state == SoldierStateEnum.PickingBall) then
        print("Picked the ball!")
        print("Crank Value: ", Soldier.crankValue)
    end
end

function Soldier:draw()
    if (Soldier.state == SoldierStateEnum.Idle) then
        Soldier.idleAnimation:draw(Soldier.idleSpriteSheet, Soldier.positionX, Soldier.positionY)
    elseif (Soldier.state == SoldierStateEnum.Walking) then
        Soldier.walkingAnimation:draw(Soldier.walkingSpriteSheet, Soldier.positionX, Soldier.positionY)
    elseif (Soldier.state == SoldierStateEnum.PickingBall) then
        Soldier.pickingBallAnimation:draw(Soldier.pickingBallSpriteSheet, Soldier.positionX, Soldier.positionY)
    end

    if (Soldier.state == SoldierStateEnum.Idle or Soldier.state == SoldierStateEnum.Walking) then
        love.graphics.draw(Soldier.topCannonBallSprite, 0, 0)
    end
end

return Soldier