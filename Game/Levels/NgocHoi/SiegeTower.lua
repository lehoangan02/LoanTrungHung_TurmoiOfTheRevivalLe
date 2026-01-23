local SiegeTower = {}
SiegeTower.__index = SiegeTower

local StatefulObject = require("Game.Components.StatefulObject")

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
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 20 + wheelWidth/2, self.siege_tower_positionY + 135 + 3 + wheelHeight/2, math.rad(30 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 60 + wheelWidth/2, self.siege_tower_positionY + 135 + 3 + wheelHeight/2, math.rad(45 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
    self.frontStatefulObject:draw(self.siege_tower_positionX, self.siege_tower_positionY)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 10 + wheelWidth/2, self.siege_tower_positionY + 135 + 5 + wheelHeight/2, math.rad(60 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)
    love.graphics.draw(self.wheel, self.siege_tower_positionX + 50 + wheelWidth/2, self.siege_tower_positionY + 135 + 5 + wheelHeight/2, math.rad(0 + self.wheelRotation), 1, 1, wheelWidth / 2, wheelHeight / 2)

    love.graphics.draw(self.straw, 100, self.siege_tower_positionY - 2)
    love.graphics.draw(self.straw, 140, self.siege_tower_positionY - 2)
end