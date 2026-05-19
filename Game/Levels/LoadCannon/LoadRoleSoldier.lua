local LoadRoleSoldier = {}
LoadRoleSoldier.__index = LoadRoleSoldier

local anim8 = require "Game/Libraries/anim8"

local InputManager = require("Game.Input.InputManager")

local DEBUG = true

local SoldierStateEnum = {
    Idle = 0,
    CarryCharge = 1,
    LoadCharge = 2,
    WalkLeft = 3,
    PickingBall = 4,
    WalkRight = 5,
    LiftingBall = 6,
    Falling = 7
}

function LoadRoleSoldier:load(spawnBallFunction, isCannonBallInStrawFunction, setCannonBallVisibleFunction, shakeFunction, onLostAnimationComplete)
    LoadRoleSoldier.onLostAnimationComplete = onLostAnimationComplete

    LoadRoleSoldier.spawnBallFunction = spawnBallFunction
    LoadRoleSoldier.isCannonBallInStrawFunction = isCannonBallInStrawFunction
    LoadRoleSoldier.setCannonBallVisibleFunction = setCannonBallVisibleFunction
    LoadRoleSoldier.shakeFunction = shakeFunction

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

    LoadRoleSoldier.loadingChargeSpriteSheet = love.graphics.newImage("Resources/Images/SoldierLiftCharge.png")
    LoadRoleSoldier.loadingChargeSpriteSheet:setFilter("nearest", "nearest")
    local loadingChargeGrid = anim8.newGrid(LoadRoleSoldier.loadingChargeSpriteSheet:getWidth() / 38, 36, LoadRoleSoldier.loadingChargeSpriteSheet:getWidth(), LoadRoleSoldier.loadingChargeSpriteSheet:getHeight())
    LoadRoleSoldier.loadingChargeAnimation = anim8.newAnimation(loadingChargeGrid("1-38", 1), 0.1)

    LoadRoleSoldier.loadingCannonSpriteSheet = love.graphics.newImage("Resources/Images/SoldierLiftCannonBall.png")
    LoadRoleSoldier.loadingCannonSpriteSheet:setFilter("nearest", "nearest")
    local loadingCannonGrid = anim8.newGrid(LoadRoleSoldier.loadingCannonSpriteSheet:getWidth() / 38, 112, LoadRoleSoldier.loadingCannonSpriteSheet:getWidth(), LoadRoleSoldier.loadingCannonSpriteSheet:getHeight())
    LoadRoleSoldier.loadingCannonAnimation = anim8.newAnimation(loadingCannonGrid("1-38", 1), 0.1)

    LoadRoleSoldier.fallingSpriteSheet = love.graphics.newImage("Resources/Images/SoldierFall.png")
    LoadRoleSoldier.fallingSpriteSheet:setFilter("nearest", "nearest")
    local fallingGrid = anim8.newGrid(240, 240, LoadRoleSoldier.fallingSpriteSheet:getWidth(), LoadRoleSoldier.fallingSpriteSheet:getHeight())
    LoadRoleSoldier.fallingAnimation = anim8.newAnimation(fallingGrid("1-5", 1), 0.1, 'pauseAtEnd')

    LoadRoleSoldier.startedWarningForBullet = false
    LoadRoleSoldier.warningImage = love.graphics.newImage("Resources/Images/Warning.png")
    LoadRoleSoldier.warningImage:setFilter("nearest", "nearest")
    
    LoadRoleSoldier.warningTimer = 0
    LoadRoleSoldier.warningDuration = 2.8

    LoadRoleSoldier.blinkingTimer = 0
    LoadRoleSoldier.warningVisible = true

    -- Second Warning Setup
    LoadRoleSoldier.startedWarning2 = false
    LoadRoleSoldier.warningTimer2 = 0
    LoadRoleSoldier.warningDuration2 = 2.8
    LoadRoleSoldier.blinkingTimer2 = 0
    LoadRoleSoldier.warningVisible2 = true
    LoadRoleSoldier.warning2X = -125 -- Set the configurable X position here
    LoadRoleSoldier.warning2Y = -50  -- Set the configurable Y position here

    -- Setup Yellow Bullet Animation
    LoadRoleSoldier.bulletAnimFired = false
    LoadRoleSoldier.bullet_spritesheet = love.graphics.newImage("Resources/Images/Bullet_Yellow.png")
    LoadRoleSoldier.bullet_spritesheet:setFilter("nearest", "nearest")
    LoadRoleSoldier.bullet_grid = anim8.newGrid(50, 9, LoadRoleSoldier.bullet_spritesheet:getWidth(), LoadRoleSoldier.bullet_spritesheet:getHeight())
    LoadRoleSoldier.bullet_animation = anim8.newAnimation(LoadRoleSoldier.bullet_grid('1-3', 1), 0.1, 'pauseAtEnd')
end

function LoadRoleSoldier:update(dt)
    LoadRoleSoldier.crankValue = LoadRoleSoldier.crankValue + InputManager:getCrankValue()

    local moveSpeed = 1000
    LoadRoleSoldier.carrySpeed = 800

    if (LoadRoleSoldier.state == SoldierStateEnum.Idle or LoadRoleSoldier.state == SoldierStateEnum.Falling) then
        -- Do nothing
    elseif (LoadRoleSoldier.state == SoldierStateEnum.CarryCharge) then
        local crankVal = InputManager:getCrankValue()
        LoadRoleSoldier.positionX = LoadRoleSoldier.positionX - crankVal * moveSpeed * dt
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkLeft) then
        local crankVal = InputManager:getCrankValue()
        if (LoadRoleSoldier.crankValue <= -15.75) then 
        else
            LoadRoleSoldier.positionX = LoadRoleSoldier.positionX + crankVal * LoadRoleSoldier.carrySpeed * dt
        end
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkRight) then
        local crankVal = InputManager:getCrankValue()
        LoadRoleSoldier.positionX = LoadRoleSoldier.positionX - crankVal * LoadRoleSoldier.carrySpeed * dt
    end

    if (LoadRoleSoldier.state == SoldierStateEnum.Idle) then
        LoadRoleSoldier.idleAnimation:update(dt)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.CarryCharge) then
        LoadRoleSoldier.carryingChargeAnimation:update(dt * - InputManager:getCrankValue() * 60)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.LoadCharge) then
        LoadRoleSoldier.loadingChargeAnimation:update(dt * - InputManager:getCrankValue() * 60)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkLeft) then
        if (LoadRoleSoldier.crankValue < -15.75) then
        else
            LoadRoleSoldier.walkingAnimation:update(dt * - InputManager:getCrankValue() * 60)
        end
    elseif (LoadRoleSoldier.state == SoldierStateEnum.PickingBall) then
        LoadRoleSoldier.pickingBallAnimation:update(dt * - InputManager:getCrankValue() * 60)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkRight) then
        LoadRoleSoldier.carryingBallAnimation:update(dt * - InputManager:getCrankValue() * 60)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.LiftingBall) then
        LoadRoleSoldier.loadingCannonAnimation:update(dt * - InputManager:getCrankValue() * 60)
        if (LoadRoleSoldier.loadingCannonAnimation.position >= 38) then
            if DEBUG then
                print("Finished loading cannon ball")
            end
        end
    elseif (LoadRoleSoldier.state == SoldierStateEnum.Falling) then
        LoadRoleSoldier.fallingAnimation:update(dt)
        if LoadRoleSoldier.fallingAnimation.status == 'paused' and not LoadRoleSoldier.lostScreenTriggered then
            LoadRoleSoldier.lostScreenTriggered = true
            if LoadRoleSoldier.onLostAnimationComplete then
                LoadRoleSoldier.onLostAnimationComplete()
            end
        end
    end

    if (LoadRoleSoldier.crankValue > 0) then
        LoadRoleSoldier.crankValue = 0
        LoadRoleSoldier.positionX = LoadRoleSoldier.initPositionX
        LoadRoleSoldier.state = SoldierStateEnum.Idle
        LoadRoleSoldier.idleAnimation:gotoFrame(1)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.Idle and LoadRoleSoldier.crankValue < -0.01) then
        LoadRoleSoldier.state = SoldierStateEnum.CarryCharge
    elseif (LoadRoleSoldier.state == SoldierStateEnum.CarryCharge and LoadRoleSoldier.crankValue < -4) then
        LoadRoleSoldier.crankValue = -4
        LoadRoleSoldier.positionX = 65
        LoadRoleSoldier.state = SoldierStateEnum.LoadCharge
        LoadRoleSoldier.loadingChargeAnimation:gotoFrame(1)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.LoadCharge and LoadRoleSoldier.crankValue > -4) then
        LoadRoleSoldier.crankValue = -4
        LoadRoleSoldier.state = SoldierStateEnum.CarryCharge
        LoadRoleSoldier.carryingChargeAnimation:gotoFrame(1)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.LoadCharge and LoadRoleSoldier.crankValue < -7.75) then
        LoadRoleSoldier.crankValue = -7.75
        LoadRoleSoldier.state = SoldierStateEnum.WalkLeft
        LoadRoleSoldier.walkingAnimation:gotoFrame(1)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkLeft and LoadRoleSoldier.crankValue > -7.75) then
        LoadRoleSoldier.crankValue = -7.75
        LoadRoleSoldier.state = SoldierStateEnum.LoadCharge
        LoadRoleSoldier.loadingChargeAnimation:gotoFrame(38)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkLeft and LoadRoleSoldier.crankValue < -15.75) then
        LoadRoleSoldier.crankValue = -15.75
        LoadRoleSoldier.positionX = -43
        if (LoadRoleSoldier.isCannonBallInStrawFunction()) then
            print("Ball is in straw, picking ball")
            LoadRoleSoldier.state = SoldierStateEnum.PickingBall
            LoadRoleSoldier.pickingBallAnimation:gotoFrame(1)
            LoadRoleSoldier.setCannonBallVisibleFunction(false)
        end
    elseif (LoadRoleSoldier.state == SoldierStateEnum.PickingBall and LoadRoleSoldier.crankValue > -15.75) then
        LoadRoleSoldier.crankValue = -15.75
        LoadRoleSoldier.state = SoldierStateEnum.WalkLeft
        LoadRoleSoldier.walkingAnimation:gotoFrame(10)
        LoadRoleSoldier.setCannonBallVisibleFunction(true)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.PickingBall and LoadRoleSoldier.crankValue < -18.35) then
        LoadRoleSoldier.crankValue = -18.35
        LoadRoleSoldier.positionX = -43
        LoadRoleSoldier.state = SoldierStateEnum.WalkRight
        LoadRoleSoldier.walkingAnimation:gotoFrame(1)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkRight and LoadRoleSoldier.crankValue > -18.35) then
        LoadRoleSoldier.crankValue = -18.35
        LoadRoleSoldier.positionX = -43
        LoadRoleSoldier.state = SoldierStateEnum.PickingBall
        LoadRoleSoldier.pickingBallAnimation:gotoFrame(14)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkRight and LoadRoleSoldier.crankValue < -26.6) then
        LoadRoleSoldier.crankValue = -26.6
        LoadRoleSoldier.positionX = 65
        LoadRoleSoldier.state = SoldierStateEnum.LiftingBall
        LoadRoleSoldier.loadingCannonAnimation:gotoFrame(1)
    end

    if (LoadRoleSoldier.crankValue < -4.1 and LoadRoleSoldier.startedWarningForBullet == false) then
        LoadRoleSoldier.startedWarningForBullet = true
        LoadRoleSoldier.warningTimer = LoadRoleSoldier.warningDuration
        LoadRoleSoldier.blinkingTimer = 0
    end
    LoadRoleSoldier.bullet_animation:update(dt)

    if LoadRoleSoldier.warningTimer > 0 then
        LoadRoleSoldier.warningTimer = LoadRoleSoldier.warningTimer - dt
        
        local progress = 1 - (LoadRoleSoldier.warningTimer / LoadRoleSoldier.warningDuration)

        local blinkInterval

        if progress < 0.2 then
            blinkInterval = 0.5
        elseif progress < 0.4 then
            blinkInterval = 0.35
        elseif progress < 0.6 then
            blinkInterval = 0.2
        elseif progress < 0.8 then
            blinkInterval = 0.1
        else
            blinkInterval = 0.03
        end

        LoadRoleSoldier.blinkingTimer = LoadRoleSoldier.blinkingTimer + dt

        if LoadRoleSoldier.blinkingTimer >= blinkInterval then
            LoadRoleSoldier.blinkingTimer = 0
            LoadRoleSoldier.warningVisible = not LoadRoleSoldier.warningVisible
        end
    end

    -- Update Second Warning
    if (LoadRoleSoldier.crankValue < -12.9 and not LoadRoleSoldier.startedWarning2) then
        print("Started Second Warning at crank value: " .. LoadRoleSoldier.crankValue)
        LoadRoleSoldier.startedWarning2 = true
        LoadRoleSoldier.warningTimer2 = LoadRoleSoldier.warningDuration2
        LoadRoleSoldier.blinkingTimer2 = 0
    end

    if LoadRoleSoldier.warningTimer2 > 0 then
        LoadRoleSoldier.warningTimer2 = LoadRoleSoldier.warningTimer2 - dt
        LoadRoleSoldier.blinkingTimer2 = LoadRoleSoldier.blinkingTimer2 + dt
        
        local progress = 1 - (LoadRoleSoldier.warningTimer2 / LoadRoleSoldier.warningDuration2)
        local blinkInterval

        if progress < 0.2 then
            blinkInterval = 0.5
        elseif progress < 0.4 then
            blinkInterval = 0.35
        elseif progress < 0.6 then
            blinkInterval = 0.2
        elseif progress < 0.8 then
            blinkInterval = 0.1
        else
            blinkInterval = 0.03
        end
        
        if LoadRoleSoldier.blinkingTimer2 >= blinkInterval then
            LoadRoleSoldier.warningVisible2 = not LoadRoleSoldier.warningVisible2
            LoadRoleSoldier.blinkingTimer2 = 0
        end
        
        if LoadRoleSoldier.warningTimer2 <= 0 then
            print("Second Warning finished at crank value: " .. LoadRoleSoldier.crankValue)
            LoadRoleSoldier.warningVisible2 = false
            
            if not LoadRoleSoldier.secondWarningEnded then
                LoadRoleSoldier.secondWarningEnded = true
                if LoadRoleSoldier.spawnBallFunction then
                    LoadRoleSoldier.spawnBallFunction()
                end
            end
        end
    end    
        -- Trigger bullet animation EXACTLY when the warning finishes
        if LoadRoleSoldier.startedWarningForBullet and LoadRoleSoldier.warningTimer <= 0 and not LoadRoleSoldier.bulletAnimFired then
            LoadRoleSoldier.bulletAnimFired = true
            LoadRoleSoldier.bullet_animation:gotoFrame(1)
            LoadRoleSoldier.bullet_animation:resume()
            if LoadRoleSoldier.shakeFunction then
                LoadRoleSoldier.shakeFunction(0.2, 3) -- Give it a solid shake!
            end
            
            -- Check for player loss
            if LoadRoleSoldier.crankValue <= -6.0 and LoadRoleSoldier.crankValue >= -6.7 then
                print("Player has lost!")
                if LoadRoleSoldier.state ~= SoldierStateEnum.Falling then
                    LoadRoleSoldier.state = SoldierStateEnum.Falling
                    LoadRoleSoldier.fallingAnimation:gotoFrame(1)
                end
            end
        end

    if DEBUG then
        print("Crank Value: " .. LoadRoleSoldier.crankValue .. ", PositionX: " .. LoadRoleSoldier.positionX)
    end

    if (LoadRoleSoldier.state == SoldierStateEnum.PickingBall and LoadRoleSoldier.pickingBallAnimation.position >= #LoadRoleSoldier.pickingBallAnimation.frames) then
        if DEBUG then
            print("Finished lifting cannon ball")
        end
    end

    if (LoadRoleSoldier.state == SoldierStateEnum.LiftingBall and LoadRoleSoldier.loadingCannonAnimation.position >= 38) then
        return true
    else 
        return false
    end
end

function LoadRoleSoldier:draw()
    if (LoadRoleSoldier.state == SoldierStateEnum.Idle) then
        LoadRoleSoldier.idleAnimation:draw(LoadRoleSoldier.idleSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.CarryCharge) then
        LoadRoleSoldier.carryingChargeAnimation:draw(LoadRoleSoldier.carryingChargeSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY, 0, -1, 1, BASE_W - 9, 0)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.LoadCharge) then
        LoadRoleSoldier.loadingChargeAnimation:draw(LoadRoleSoldier.loadingChargeSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY, 0, 1, 1, -128, -119)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkLeft) then
        LoadRoleSoldier.walkingAnimation:draw(LoadRoleSoldier.walkingSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY, 0, 1, 1, - 2, 0)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.PickingBall) then
        LoadRoleSoldier.pickingBallAnimation:draw(LoadRoleSoldier.pickingBallSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY, 0, 1, 1, -44, 0)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.WalkRight) then
        LoadRoleSoldier.carryingBallAnimation:draw(LoadRoleSoldier.carryingBallSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY, 0, -1, 1, BASE_W - 8, 0)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.LiftingBall) then
        LoadRoleSoldier.loadingCannonAnimation:draw(LoadRoleSoldier.loadingCannonSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY, 0, 1, 1, -61, -64)
    elseif (LoadRoleSoldier.state == SoldierStateEnum.Falling) then
        LoadRoleSoldier.fallingAnimation:draw(LoadRoleSoldier.fallingSpriteSheet, LoadRoleSoldier.positionX, LoadRoleSoldier.positionY)
    end
    if LoadRoleSoldier.warningTimer > 0 and LoadRoleSoldier.warningVisible then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.draw(LoadRoleSoldier.warningImage, 0, 0)
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Draw Second Warning
    if LoadRoleSoldier.warningTimer2 > 0 and LoadRoleSoldier.warningVisible2 then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.draw(LoadRoleSoldier.warningImage, LoadRoleSoldier.warning2X, LoadRoleSoldier.warning2Y)
        love.graphics.setColor(1, 1, 1, 1)
    end
    
    -- Draw the yellow bullet animation
    if LoadRoleSoldier.bulletAnimFired and LoadRoleSoldier.bullet_animation.status ~= "paused" then
        local bx, by = 225, 120
        -- Adjust drawing offsets slightly
        LoadRoleSoldier.bullet_animation:draw(LoadRoleSoldier.bullet_spritesheet, bx, by, 0, 1, 1, 25, 4.5)
    end
end
return LoadRoleSoldier