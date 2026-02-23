local LoadRoleSoldier = {}
LoadRoleSoldier.__index = LoadRoleSoldier

local anim8 = require "Game/Libraries/anim8"

local InputManager = require "Game.Input.InputManager"

local SoldierStateEnum = {
    Idle = 0,
    CarryCharge = 1,
    LoadCharge = 2,
    WalkLeft = 3,
    PickingBall = 4,
    WalkRight = 5,
    LiftingBall = 6
}

function LoadRoleSoldier:load()
    LoadRoleSoldier.state = SoldierStateEnum.Idle

    LoadRoleSoldier.crankValue = 0

    LoadRoleSoldier.initPositionX = 0

    LoadRoleSoldier.positionX = LoadRoleSoldier.initPositionX
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
    LoadRoleSoldier.carryingBallAnimation = anim8.newAnimation(carryingBallGrid("1-10", 1), 0.12)

    LoadRoleSoldier.carryingChargeSpriteSheet = love.graphics.newImage("Resources/Images/SoldierCarryCharge.png")
    LoadRoleSoldier.carryingChargeSpriteSheet:setFilter("nearest", "nearest")
    local carryingChargeGrid = anim8.newGrid(240, 240, LoadRoleSoldier.carryingChargeSpriteSheet:getWidth(), LoadRoleSoldier.carryingChargeSpriteSheet:getHeight())
    LoadRoleSoldier.carryingChargeAnimation = anim8.newAnimation(carryingChargeGrid("1-10", 1), 0.12)


end

function LoadRoleSoldier:update(dt)
    LoadRoleSoldier.crankValue = LoadRoleSoldier.crankValue + InputManager:getCrankValue()

    local moveSpeed = 1000
    local carrySpeed = 800

    if (LoadRoleSoldier.state == SoldierStateEnum.Idle) then
        if (InputManager:getCrankValue() < LoadRoleSoldier.initPositionX -0.01) then
            LoadRoleSoldier.state = SoldierStateEnum.CarryCharge
            LoadRoleSoldier.positionX = LoadRoleSoldier.positionX + InputManager:getCrankValue() * moveSpeed * dt
        end
    elseif (LoadRoleSoldier.state == SoldierStateEnum.CarryCharge) then
        local crankVal = InputManager:getCrankValue()
        LoadRoleSoldier.positionX = LoadRoleSoldier.positionX - crankVal * moveSpeed * dt

    end

    if (LoadRoleSoldier.state == SoldierStateEnum.Idle) then
        LoadRoleSoldier.idleAnimation:update(dt)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.CarryCharge) then
        LoadRoleSoldier.carryingChargeAnimation:update(dt * - InputManager:getCrankValue() * 60)
    end

    if (LoadRoleSoldier.crankValue > LoadRoleSoldier.initPositionX) then
        LoadRoleSoldier.crankValue = LoadRoleSoldier.initPositionX
        LoadRoleSoldier.positionX = LoadRoleSoldier.initPositionX
        LoadRoleSoldier.state = SoldierStateEnum.Idle
        LoadRoleSoldier.idleAnimation:gotoFrame(1)
    end
end

function LoadRoleSoldier:draw()
    if (LoadRoleSoldier.state == SoldierStateEnum.Idle) then
        LoadRoleSoldier.idleAnimation:draw(LoadRoleSoldier.idleSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.CarryCharge) then
        print("Drawing in state CarryCharge with crankValue: " .. LoadRoleSoldier.crankValue)
        LoadRoleSoldier.carryingChargeAnimation:draw(LoadRoleSoldier.carryingChargeSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY, 0, -1, 1, BASE_W - 9, 0)
    end
end
return LoadRoleSoldier