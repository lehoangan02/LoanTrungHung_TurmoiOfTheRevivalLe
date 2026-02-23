local LoadRoleSoldier = {}
LoadRoleSoldier.__index = LoadRoleSoldier

local anim8 = require "Game/Libraries/anim8"

local InputManager = require "Game/Managers/InputManager"

local SoldierStateEnum = {
    Idle = 0,
    LoadCharge = 1,
    WalkLeft = 2,
    PickingBall = 3,
    WalkRight = 4,
    LiftingBall = 5
}

function LoadRoleSoldier:load()
    LoadRoleSoldier.state = SoldierStateEnum.Idle

    LoadRoleSoldier.crankValue = 0

    LoadRoleSoldier.positionX = 0
    LoadRoleSoldier.positionY = 0

    LoadRoleSoldier.topCannonBallSprite = love.graphics.newImage("Resources/Images/TopCannonBall.png")
    LoadRoleSoldier.topCannonBallSprite:setFilter("nearest", "nearest")

    LoadRoleSoldier.idleSpriteSheet = love.graphics.newImage("Resources/Images/SoldierIdle.png")
    LoadRoleSoldier.idleSpriteSheet:setFilter("nearest", "nearest")
    local idleGrid = anim8.newGrid(240, 240, LoadRoleSoldier.idleSpriteSheet:getWidth(), LoadRoleSoldier.idleSpriteSheet:getHeight())
    LoadRoleSoldier.idleAnimation = anim8.newAnimation(idleGrid("1-8", 1), 0.2)

    LoadRoleSoldier.walkingSpriteSheet = love.graphics.newImage("Resources/Images/SoldierWalking.png")
    LoadRoleSoldier.walkingSpriteSheet:setFilter("nearest", "nearest")
    local walkingGrid = anim8.newGrid(240, 240, LoadRoleSoldier.walkingSpriteSheet:getWidth(), LoadRoleSoldier.walkingSpriteSheet:getHeight())
    LoadRoleSoldier.walkingAnimation = anim8.newAnimation(walkingGrid("1-10", 1), 0.1)

    LoadRoleSoldier.pickingBallSpriteSheet = love.graphics.newImage("Resources/Images/SoldierPick.png")
    LoadRoleSoldier.pickingBallSpriteSheet:setFilter("nearest", "nearest")
    local pickingBallGrid = anim8.newGrid(240, 240, LoadRoleSoldier.pickingBallSpriteSheet:getWidth(), LoadRoleSoldier.pickingBallSpriteSheet:getHeight())
    LoadRoleSoldier.pickingBallAnimation = anim8.newAnimation(pickingBallGrid("1-14", 1), 0.2)

    LoadRoleSoldier.carryingBallSpriteSheet = love.graphics.newImage("Resources/Images/SoldierCarryBall.png")
    LoadRoleSoldier.carryingBallSpriteSheet:setFilter("nearest", "nearest")
    local carryingBallGrid = anim8.newGrid(240, 240, LoadRoleSoldier.carryingBallSpriteSheet:getWidth(), LoadRoleSoldier.carryingBallSpriteSheet:getHeight())
    LoadRoleSoldier.carryingBallAnimation = anim8.newAnimation(carryingBallGrid("1-10", 1), 0.1)

    
end

return LoadRoleSoldier