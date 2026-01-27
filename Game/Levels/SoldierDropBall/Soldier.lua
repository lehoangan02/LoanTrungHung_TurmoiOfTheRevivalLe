local Soldier = {}
Soldier.__index = Soldier

local anim8 = require "Game/Libraries/anim8"

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
    Soldier.idleAnimation:update(dt)
end

function Soldier:draw()
    Soldier.idleAnimation:draw(Soldier.idleSpriteSheet, Soldier.positionX, Soldier.positionY)
end

return Soldier