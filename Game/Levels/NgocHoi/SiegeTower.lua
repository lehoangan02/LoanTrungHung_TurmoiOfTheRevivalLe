local SiegeTower = {}
SiegeTower.__index = SiegeTower

local anim8 = require "Game/Libraries/anim8"
local bf = require("Game/Libraries/breezefield-master")

local StatefulObject = require("Game.Components.StatefulObject")
local DialogCloud = require("Game.Components.DialogCloud")

function SiegeTower:new(world, x, y, onCannonFireShakeScreen)
    local self = setmetatable({}, SiegeTower)

    self.world = world

    self.siege_tower_positionX = x
    self.siege_tower_positionY = y

    self.onCannonFire = onCannonFireShakeScreen

    self.world = world
    self.sprite1 = love.graphics.newImage("Resources/Images/siege_tower.png")
    self.sprite1:setFilter("nearest", "nearest")

    self.collider = self.world:newCollider("Rectangle", { x + self.sprite1:getWidth() / 2, y + self.sprite1:getHeight() / 2, self.sprite1:getWidth(), self.sprite1:getHeight() })
    self.collider:setType("static")
    self.collider.parent = self
    function self.collider:enter(other, collision)
        if other.isBall then
            print("Siege Tower hit by cannon ball")
            other.parent.to_explode = true
            local siegeTower = self.parent
            siegeTower.frontStatefulObject:setState(2)
            siegeTower.backStatefulObject:setState(2)
            siegeTower.straw_statefulObject:setState(2)
            siegeTower.cannon2_statefulObject:setState(2)
            self.parent.startCountingDownGuy1PrepareToSpeak = true
        end
    end
    self.Timer = 0

    self.frontStatefulObject = StatefulObject:new()
    self.frontSprite1 = love.graphics.newImage("Resources/Images/siege_tower_front1.png")
    self.frontSprite1:setFilter("nearest", "nearest")
    self.frontStatefulObject:addSprite(self.frontSprite1)
    self.frontSprite2 = love.graphics.newImage("Resources/Images/siege_tower_front2.png")
    self.frontSprite2:setFilter("nearest", "nearest")
    self.frontStatefulObject:addSprite(self.frontSprite2)
    self.frontStatefulObject:setState(1)

    self.backStatefulObject = StatefulObject:new()
    self.backSprite1 = love.graphics.newImage("Resources/Images/siege_tower_back1.png")
    self.backSprite1:setFilter("nearest", "nearest")
    self.backStatefulObject:addSprite(self.backSprite1)
    self.backSprite2 = love.graphics.newImage("Resources/Images/siege_tower_back2.png")
    self.backSprite2:setFilter("nearest", "nearest")
    self.backStatefulObject:addSprite(self.backSprite2)
    self.backStatefulObject:setState(1)

    self.guy1StatefulObject = StatefulObject:new()
    self.guy1Sprite1 = love.graphics.newImage("Resources/Images/siege_tower_guy1_1.png")
    self.guy1Sprite1:setFilter("nearest", "nearest")
    self.guy1StatefulObject:addSprite(self.guy1Sprite1)
    self.guy1Sprite2 = love.graphics.newImage("Resources/Images/siege_tower_guy1_2.png")
    self.guy1Sprite2:setFilter("nearest", "nearest")
    self.guy1StatefulObject:addSprite(self.guy1Sprite2)
    self.guy1StatefulObject:setState(1)
    self.timeUntilGuy1Speak = 1
    self.timeForGuy1ToSpeak = 2
    self.startCountingDownGuy1PrepareToSpeak = false
    self.guy1DialogCloud = DialogCloud.new(
        "Cannon is disabled!",
        150,
        57,
        40,
        20,
        {0, 0, 0},
        {1, 1, 1}
    )

    self.guy2StatefulObject = StatefulObject:new()
    self.guy2Sprite1 = love.graphics.newImage("Resources/Images/siege_tower_guy2_1.png")
    self.guy2Sprite1:setFilter("nearest", "nearest")
    self.guy2StatefulObject:addSprite(self.guy2Sprite1)
    self.guy2Sprite2 = love.graphics.newImage("Resources/Images/siege_tower_guy2_2.png")
    self.guy2Sprite2:setFilter("nearest", "nearest")
    self.guy2StatefulObject:addSprite(self.guy2Sprite2)
    self.guy2StatefulObject:setState(1)
    self.timeUntilGuy2Speak = 0.5
    self.timeForGuy2ToSpeak = 2
    self.startCountingDownGuy2PrepareToSpeak = false
    self.guy2DialogCloud = DialogCloud.new(
        "Out of ammo!",
        148,
        111,
        40,
        20,
        {0, 0, 0},
        {1, 1, 1}
    )

    self.guy34Sprite = love.graphics.newImage("Resources/Images/siege_tower_guy34.png")
    self.guy34Sprite:setFilter("nearest", "nearest")

    self.wheel = love.graphics.newImage("Resources/Images/wheel.png")
    self.wheel:setFilter("nearest", "nearest")
    self.wheelRotation = 0

    self.cannon2_spritesheet = love.graphics.newImage("Resources/Images/LightCannon2.png")
    self.cannon2_spritesheet:setFilter("nearest", "nearest")
    self.cannon2_grid = anim8.newGrid(70, 40, self.cannon2_spritesheet:getWidth(), self.cannon2_spritesheet:getHeight())
    self.cannon2_animation = anim8.newAnimation(self.cannon2_grid('1-6', 1), 0.15, 'pauseAtEnd')
    self.cannon2_disabled_sprite = love.graphics.newImage("Resources/Images/disabled_cannon.png")
    self.cannon2_disabled_sprite:setFilter("nearest", "nearest")
    self.cannon2_statefulObject = StatefulObject:new()
    self.cannon2_statefulObject:addAnimation(self.cannon2_animation, self.cannon2_spritesheet)
    self.cannon2_statefulObject:addSprite(self.cannon2_disabled_sprite)
    self.cannon2_statefulObject:setState(1)
    self.TimeCannon2 = 10.5
    self.cannon2Fired = false

    self.cannon3_spritesheet = love.graphics.newImage("Resources/Images/LightCannon2.png")
    self.cannon3_spritesheet:setFilter("nearest", "nearest")
    self.cannon3_grid = anim8.newGrid(70, 40, self.cannon3_spritesheet:getWidth(), self.cannon3_spritesheet:getHeight())
    self.cannon3_animation = anim8.newAnimation(self.cannon3_grid('1-6', 1), 0.15, 'pauseAtEnd')
    self.cannon3_statefulObject = StatefulObject:new()
    self.cannon3_statefulObject:addAnimation(self.cannon3_animation, self.cannon3_spritesheet)
    self.cannon3_statefulObject:setState(1)
    self.TimeCannon3 = 11.5
    self.cannon3Fired = false

    self.cannon4_spritesheet = love.graphics.newImage("Resources/Images/LightCannon2.png")
    self.cannon4_spritesheet:setFilter("nearest", "nearest")
    self.cannon4_grid = anim8.newGrid(70, 40, self.cannon4_spritesheet:getWidth(), self.cannon4_spritesheet:getHeight())
    self.cannon4_animation = anim8.newAnimation(self.cannon4_grid('1-6', 1), 0.15, 'pauseAtEnd')
    self.cannon4_statefulObject = StatefulObject:new()
    self.cannon4_statefulObject:addAnimation(self.cannon4_animation, self.cannon4_spritesheet)
    self.cannon4_statefulObject:setState(1)
    self.TimeCannon4 = 12.0
    self.cannon4Fired = false

    self.straw = love.graphics.newImage("Resources/Images/Straw.png")
    self.straw:setFilter("nearest", "nearest")
    self.straw2 = love.graphics.newImage("Resources/Images/Straw_2.png")
    self.straw2:setFilter("nearest", "nearest")
    self.straw_statefulObject = StatefulObject:new()
    self.straw_statefulObject:addSprite(self.straw)
    self.straw_statefulObject:addSprite(self.straw2)
    self.straw_statefulObject:setState(1)

    self.ammo_sprite = love.graphics.newImage("Resources/Images/ammo.png")
    self.ammo_sprite:setFilter("nearest", "nearest")

    return self
end

function SiegeTower:update(dt)
    local rotationSpeed = 120
    self.wheelRotation = self.wheelRotation + rotationSpeed * dt

    self.Timer = self.Timer + dt

    local animationCannon2 = self.cannon2_statefulObject:getCurrentAnimation()
    if animationCannon2 ~= nil then
        if self.Timer >= self.TimeCannon2 and not self.cannon2Fired then
            animationCannon2:gotoFrame(1)
            animationCannon2:resume()
            self.cannon2Fired = true
        end
        if animationCannon2.position == 4 then
            self.onCannonFire(0.1, 1)
        end
    end
    
    local animationCannon3 = self.cannon3_statefulObject:getCurrentAnimation()
    if self.Timer >= self.TimeCannon3 and not self.cannon3Fired then
        animationCannon3:gotoFrame(1)
        animationCannon3:resume()
        self.cannon3Fired = true
    end
    if animationCannon3.position == 4 then
        self.onCannonFire(0.1, 1)
    end

    local animationCannon4 = self.cannon4_statefulObject:getCurrentAnimation()
    if self.Timer >= self.TimeCannon4 and not self.cannon4Fired then
        animationCannon4:gotoFrame(1)
        animationCannon4:resume()
        self.cannon4Fired = true
    end
    if animationCannon4.position == 4 then
        self.onCannonFire(0.1, 1)
    end

    self.cannon2_statefulObject:update(dt)
    self.cannon3_statefulObject:update(dt)
    self.cannon4_statefulObject:update(dt)

    self:handleGuy1Speak(dt)
    self:handleGuy2Speak(dt)

    if (self.guy2DialogCloud:isCloudFullyFaded()) then
        return true
    else 
        return false
    end

end

function SiegeTower:handleGuy1Speak(dt)
    if not self.startCountingDownGuy1PrepareToSpeak then return end
    if self.timeUntilGuy1Speak > 0 then
        self.timeUntilGuy1Speak = self.timeUntilGuy1Speak - dt
        if self.timeUntilGuy1Speak <= 0 then
            self.guy1StatefulObject:setState(2)
            self.timeUntilGuy1Speak = 0
            print("Guy 1 starts speaking")
            self.guy1DialogCloud:startDialogue()
        end
    end
    self.guy1DialogCloud:update(dt)
    if self.guy1DialogCloud:isCloudFullyShown() then
        if self.timeForGuy1ToSpeak > 0 then
            self.timeForGuy1ToSpeak = self.timeForGuy1ToSpeak - dt
            if self.timeForGuy1ToSpeak <= 0 then
                self.guy1DialogCloud:endDialogue()
                self.startCountingDownGuy2PrepareToSpeak = true
                print("Guy 1 finished speaking, start counting down for Guy 2 to speak")
            end
        end
    end
end

function SiegeTower:handleGuy2Speak(dt)
    if not self.startCountingDownGuy2PrepareToSpeak then return end
    if self.timeUntilGuy2Speak > 0 then
        self.timeUntilGuy2Speak = self.timeUntilGuy2Speak - dt
        if self.timeUntilGuy2Speak <= 0 then
            self.guy2StatefulObject:setState(2)
            self.timeUntilGuy2Speak = 0
            print("Guy 2 starts speaking")
            self.guy2DialogCloud:startDialogue()
        end
    end
    self.guy2DialogCloud:update(dt)
    if self.guy2DialogCloud:isCloudFullyShown() then
        if self.timeForGuy2ToSpeak > 0 then
            self.timeForGuy2ToSpeak = self.timeForGuy2ToSpeak - dt
            if self.timeForGuy2ToSpeak <= 0 then
                self.guy2DialogCloud:endDialogue()
            end
        end
    end
end

function SiegeTower:draw(scale, fontScale, offsetX, offsetY)

    local wheelWidth = self.wheel:getWidth()
    local wheelHeight = self.wheel:getHeight()

    self.backStatefulObject:draw(self.siege_tower_positionX, self.siege_tower_positionY)
    love.graphics.draw(self.ammo_sprite, self.siege_tower_positionX, self.siege_tower_positionY)
    self.guy1StatefulObject:draw(self.siege_tower_positionX, self.siege_tower_positionY)
    self.guy2StatefulObject:draw(self.siege_tower_positionX, self.siege_tower_positionY)
    love.graphics.draw(self.guy34Sprite, self.siege_tower_positionX, self.siege_tower_positionY)
    self.cannon2_statefulObject:draw(self.siege_tower_positionX + 40, self.siege_tower_positionY + -2)
    self.cannon3_statefulObject:draw(self.siege_tower_positionX + 44, self.siege_tower_positionY + 51)
    self.cannon4_statefulObject:draw(self.siege_tower_positionX + 41, self.siege_tower_positionY + 77)
    
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 20 + wheelWidth/2, self.siege_tower_positionY + 135 + 3 + wheelHeight/2, math.rad(30 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 60 + wheelWidth/2, self.siege_tower_positionY + 135 + 3 + wheelHeight/2, math.rad(45 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
    self.frontStatefulObject:draw(self.siege_tower_positionX, self.siege_tower_positionY)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 10 + wheelWidth/2, self.siege_tower_positionY + 135 + 5 + wheelHeight/2, math.rad(60 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 50 + wheelWidth/2, self.siege_tower_positionY + 135 + 5 + wheelHeight/2, math.rad(0 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)

    love.graphics.draw(self.straw, 100, self.siege_tower_positionY - 2)
    self.straw_statefulObject:draw(140, self.siege_tower_positionY - 2)

    self.guy1DialogCloud:draw(scale, fontScale, offsetX, offsetY)
    self.guy2DialogCloud:draw(scale, fontScale, offsetX, offsetY)

    -- self.world:draw()
end

return SiegeTower