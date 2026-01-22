local SiegeTower = {}
SiegeTower.__index = SiegeTower

function SiegeTower.new(world, x, y)
    local self = setmetatable({}, SiegeTower)

    self.world = world
    self.sprite1 = love.graphics.newImage("Resources/Images/siege_tower.png")
    self.sprite1:setFilter("nearest", "nearest")

    self.collider = self.world:newCollider("Rectangle", { x + self.sprite1:getWidth() / 2, y + self.sprite1:getHeight() / 2, self.sprite1:getWidth(), self.sprite1:getHeight() })
    self.collider:setType("static")

    return self
end