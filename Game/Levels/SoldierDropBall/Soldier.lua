local Soldier = {}
Soldier.__index = Soldier

local anim8 = require "Game/Libraries/anim8"

function Soldier:load()
    Soldier.idleSpriteSheet = love.graphics.newImage("Resources/Images/SoldierIdle.png")
    Soldier.idleSpriteSheet:setFilter("nearest", "nearest")
    local idleGrid = anim8.newGrid(240, 240, Soldier.idleSpriteSheet:getWidth(), Soldier.idleSpriteSheet:getHeight())
    Soldier.idleAnimation = anim8.newAnimation(idleGrid('1-8',1), 0.2)
end

function Soldier:update(dt)
    Soldier.idleAnimation:update(dt)
end

function Soldier:draw(x, y)
    Soldier.idleAnimation:draw(Soldier.idleSpriteSheet, x, y)
end

return Soldier