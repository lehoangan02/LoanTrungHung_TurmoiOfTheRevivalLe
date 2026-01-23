local SiegeTower = {}
SiegeTower.__index = SiegeTower

local StatefulObject = require("Game.Components.StatefulObject")
local anim8 = require("Libraries.anim8.anim8")

function SiegeTower:new(world, x, y)
    local self = setmetatable({}, SiegeTower)

    self.siege_tower_positionX = x
    self.siege_tower_positionY = y

    self.world = world
    self.sprite1 = love.graphics.newImage("Resources/Images/siege_tower.png")
    self.sprite1:setFilter("nearest", "nearest")

    self.collider = self.world:newCollider("Rectangle", { x + self.sprite1:getWidth() / 2, y + self.sprite1:getHeight() / 2, self.sprite1:getWidth(), self.sprite1:getHeight() })
    self.collider:setType("static")

    self.frontStatefulObject = StatefulObject:new()
    self.frontSprite1 = love.graphics.newImage("Resources/Images/siege_tower_front1.png")
    self.frontStatefulObject:addSprite(self.frontSprite1)
    self.frontSprite2 = love.graphics.newImage("Resources/Images/siege_tower_front2.png")
    self.frontStatefulObject:addSprite(self.frontSprite2)
    self.frontStatefulObject:setState(1)

    self.backStatefulObject = StatefulObject:new()
    self.backSprite1 = love.graphics.newImage("Resources/Images/siege_tower_back1.png")
    self.backStatefulObject:addSprite(self.backSprite1)
    self.backSprite2 = love.graphics.newImage("Resources/Images/siege_tower_back2.png")
    self.backStatefulObject:addSprite(self.backSprite2)
    self.backStatefulObject:setState(1)

    self.guy1StatefulObject = StatefulObject:new()
    self.guy1Sprite1 = love.graphics.newImage("Resources/Images/siege_tower_guy1_1.png")
    self.guy1StatefulObject:addSSprite(self.guy1Sprite1)
    self.guy1Sprite2 = love.graphics.newImage("Resources/Images/siege_tower_guy1_2.png")
    self.guy1StatefulObject:addSSprite(self.guy1Sprite2)
    self.guy1StatefulObject:setState(1)

    self.guy2StatefulObject = StatefulObject:new()
    self.guy2Sprite1 = love.graphics.newImage("Resources/Images/siege_tower_guy2_1.png")
    self.guy2StatefulObject:addSSprite(self.guy2Sprite1)
    self.guy2Sprite2 = love.graphics.newImage("Resources/Images/siege_tower_guy2_2.png")
    self.guy2StatefulObject:addSSprite(self.guy2Sprite2)
    self.guy2StatefulObject:setState(1)

    self.guy34Sprite = love.graphics.newImage("Resources/Images/siege_tower_guy34.png")

    self.wheel = love.graphics.newImage("Resources/Images/wheel.png")
    self.wheel:setFilter("nearest", "nearest")
    self.wheelRotation = 0

    self.cannon2_spritesheet = love.graphics.newImage("Resources/Images/LightCannon2.png")
    self.cannon2_spritesheet:setFilter("nearest", "nearest")
    self.cannon2_grid = anim8.newGrid(70, 40, self.cannon2_spritesheet:getWidth(), self.cannon2_spritesheet:getHeight())
    self.cannon2_animation = anim8.newAnimation(self.cannon2_grid('1-6', 1), 0.15, 'pauseAtEnd')
    self.cannon2_statefulObject = StatefulObject:new()
    self.cannon2_statefulObject:addAnimation(self.cannon2_animation, self.cannon2_spritesheet)
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

    return self
end

function SiegeTower:update(dt)
    local rotationSpeed = 120
    self.wheelRotation = self.wheelRotation + rotationSpeed * dt

end

function SiegeTower:draw()
    local wheelWidth = self.wheel:getWidth()
    local wheelHeight = self.wheel:getHeight()

    self.backStatefulObject:draw(self.siege_tower_positionX, self.siege_tower_positionY)
    self.cannon2_statefulObject:draw(self.siege_tower_positionX + 40, self.siege_tower_positionY + -2)
    self.cannon3_statefulObject:draw(self.siege_tower_positionX + 44, self.siege_tower_positionY + 51)
    self.cannon4_statefulObject:draw(self.siege_tower_positionX + 41, self.siege_tower_positionY + 77)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 20 + wheelWidth/2, self.siege_tower_positionY + 135 + 3 + wheelHeight/2, math.rad(30 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 60 + wheelWidth/2, self.siege_tower_positionY + 135 + 3 + wheelHeight/2, math.rad(45 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
    self.frontStatefulObject:draw(self.siege_tower_positionX, self.siege_tower_positionY)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 10 + wheelWidth/2, self.siege_tower_positionY + 135 + 5 + wheelHeight/2, math.rad(60 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 50 + wheelWidth/2, self.siege_tower_positionY + 135 + 5 + wheelHeight/2, math.rad(0 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)

    love.graphics.draw(self.straw, 100, self.siege_tower_positionY - 2)
    love.graphics.draw(self.straw, 140, self.siege_tower_positionY - 2)
end