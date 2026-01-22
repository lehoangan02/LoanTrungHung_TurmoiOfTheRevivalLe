local SiegeTower = {}
SiegeTower.__index = SiegeTower

local StatefulObject = require("Game.Components.StatefulObject")

function SiegeTower.new(world, x, y)
    local self = setmetatable({}, SiegeTower)

    self.world = world
    self.sprite1 = love.graphics.newImage("Resources/Images/siege_tower.png")
    self.sprite1:setFilter("nearest", "nearest")

    self.collider = self.world:newCollider("Rectangle", { x + self.sprite1:getWidth() / 2, y + self.sprite1:getHeight() / 2, self.sprite1:getWidth(), self.sprite1:getHeight() })
    self.collider:setType("static")

    self.frontStatefulObject = StatefulObject:new()
    self.frontSprite1 = love.graphics.newImage("Resources/Images/siege_tower_front1.png")
    self.frontStatefulObject:addState("sprite", self.frontSprite1)
    self.frontSprite2 = love.graphics.newImage("Resources/Images/siege_tower_front2.png")
    self.frontStatefulObject:addState("sprite", self.frontSprite2)
    self.frontStatefulObject:setState(1)

    self.backStatefulObject = StatefulObject:new()
    self.backSprite1 = love.graphics.newImage("Resources/Images/siege_tower_back1.png")
    self.backStatefulObject:addState("sprite", self.backSprite1)
    self.backSprite2 = love.graphics.newImage("Resources/Images/siege_tower_back2.png")
    self.backStatefulObject:addState("sprite", self.backSprite2)
    self.backStatefulObject:setState(1)

    self.guy1StatefulObject = StatefulObject:new()
    self.guy1Sprite1 = love.graphics.newImage("Resources/Images/siege_tower_guy1_1.png")
    self.guy1StatefulObject:addState("sprite", self.guy1Sprite1)
    self.guy1Sprite2 = love.graphics.newImage("Resources/Images/siege_tower_guy1_2.png")
    self.guy1StatefulObject:addState("sprite", self.guy1Sprite2)
    self.guy1StatefulObject:setState(1)

    self.guy2StatefulObject = StatefulObject:new()
    self.guy2Sprite1 = love.graphics.newImage("Resources/Images/siege_tower_guy2_1.png")
    self.guy2StatefulObject:addState("sprite", self.guy2Sprite1)
    self.guy2Sprite2 = love.graphics.newImage("Resources/Images/siege_tower_guy2_2.png")
    self.guy2StatefulObject:addState("sprite", self.guy2Sprite2)
    self.guy2StatefulObject:setState(1)

    self.guy34Sprite = love.graphics.newImage("Resources/Images/siege_tower_guy34.png")

    return self
end