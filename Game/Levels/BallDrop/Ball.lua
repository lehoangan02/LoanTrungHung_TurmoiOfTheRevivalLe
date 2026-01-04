local Ball = {}
Ball.__index = Ball

local anim8 = require "Game/Libraries/anim8"

function Ball:new(world, x, y)
    local self = setmetatable({}, Ball)

    self.image = love.graphics.newImage("Resources/Images/Cannon_ball.png")
    self.image:setFilter("nearest", "nearest")

    self.explodeSheet = love.graphics.newImage("Resources/Images/explode_large.png")
    self.explodeGrid = anim8.newGrid(
        32, 32,
        self.explodeSheet:getWidth(),
        self.explodeSheet:getHeight()
    )
    self.explodeAnim = anim8.newAnimation(self.explodeGrid('1-4', 1), 0.2, 'pauseAtEnd')

    self.radius = 7
    self.rotation = 0
    self.exploded = false

    self.collider = world:newCircleCollider(x, y, self.radius)
    self.collider:setRestitution(0.6)

    return self
end

function Ball:update(dt, world)
    if self.exploded then
        self.explodeAnim:update(dt)
        return
    end

    self:rotate(world, dt)

    if self.collider:enter("Enemies") then
        self:explode()
    end
end

function Ball:rotate(world, dt)
    local velX, velY = self.collider:getLinearVelocity()

    local gx, gy = world:getGravity()
    local glen = math.sqrt(gx*gx + gy*gy)
    if glen == 0 then return end

    local gnx = gx / glen
    local gny = gy / glen

    local tx = -gny
    local ty = gnx

    local tangentialSpeed = -(velX * tx + velY * ty) * 3
    if tangentialSpeed > 120 then tangentialSpeed = 120 end
    if tangentialSpeed < -120 then tangentialSpeed = -120 end

    self.rotation = self.rotation + (tangentialSpeed / self.radius) * dt
end

function Ball:explode()
    if self.exploded then return end
    self.exploded = true
    self.explodeAnim:gotoFrame(1)
    self.explodeAnim:resume()
    self.collider:destroy()
end

function Ball:getPosition()
    if not self.collider then return nil end
    return self.collider:getPosition()
end

function Ball:draw()
    local x, y = self:getPosition()
    if not x then return end

    if not self.exploded then
        love.graphics.draw(self.image, x, y, self.rotation, 1, 1, 8, 8)
    elseif self.explodeAnim.status ~= "paused" then
        self.explodeAnim:draw(self.explodeSheet, x - 16, y - 16)
    end
end

return Ball
