local Soldier = {}
Soldier.__index = Soldier

local anim8 = require "Game/Libraries/anim8"

local InputManager = require("Game.Input.InputManager")

local SoldierStateEnum = {
    Idle = 0,
    Walking = 1,
}

function Soldier:load()

    Soldier.state = SoldierStateEnum.Idle

    Soldier.positionX = 0
    Soldier.positionY = 0

    Soldier.idleSpriteSheet = love.graphics.newImage("Resources/Images/SoldierIdle.png")
    Soldier.idleSpriteSheet:setFilter("nearest", "nearest")
    local idleGrid = anim8.newGrid(240, 240, Soldier.idleSpriteSheet:getWidth(), Soldier.idleSpriteSheet:getHeight())
    Soldier.idleAnimation = anim8.newAnimation(idleGrid('1-8',1), 0.2)

    Soldier.walkingSpriteSheet = love.graphics.newImage("Resources/Images/SoldierWalking.png")
    Soldier.walkingSpriteSheet:setFilter("nearest", "nearest")
    local walkingGrid = anim8.newGrid(240, 240, Soldier.walkingSpriteSheet:getWidth(), Soldier.walkingSpriteSheet:getHeight())
    Soldier.walkingAnimation = anim8.newAnimation(walkingGrid('1-10',1), 0.1)

end

function Soldier:update(dt)
    -- print("Soldier State: " .. Soldier.state)
    -- print("Soldier PositionX: " .. Soldier.positionX)
    if Soldier.stop then
        return
    end

    local moveSpeed = 1200
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
    end
    
    if (Soldier.positionX < -42) then
        print("Reached the pick point!")
        print("Current animation frame: ", Soldier.walkingAnimation.position)
        Soldier.stop = true
    end
end

function Soldier:draw()
    if (Soldier.state == SoldierStateEnum.Idle) then
        Soldier.idleAnimation:draw(Soldier.idleSpriteSheet, Soldier.positionX, Soldier.positionY)
    elseif (Soldier.state == SoldierStateEnum.Walking) then
        Soldier.walkingAnimation:draw(Soldier.walkingSpriteSheet, Soldier.positionX, Soldier.positionY)
    end
end

return Soldier