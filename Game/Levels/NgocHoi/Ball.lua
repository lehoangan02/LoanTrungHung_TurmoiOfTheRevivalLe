local Ball = {}
Ball.__index = Ball

local anim8 = require "Game/Libraries/anim8"

function Ball.new(world, speed, onExplode)
    local self = setmetatable({}, Ball)
    
    self.onExplode = onExplode

    self.to_destroy = false

    self.world = world
    self.sprite = love.graphics.newImage("Resources/Images/Canon_bala.png")
    self.sprite:setFilter("nearest", "nearest")

    self.explodeSpriteSheet = love.graphics.newImage("Resources/Images/explode_large.png")
    self.explodeSpriteSheet:setFilter("nearest", "nearest")
    self.explodeGrid = anim8.newGrid(32, 32, self.explodeSpriteSheet:getWidth(), self.explodeSpriteSheet:getHeight())
    self.explodeAnimation = anim8.newAnimation(self.explodeGrid('1-4', 1), 0.1, 'pauseAtEnd')
    self.explodeAnimation:pause()

    self.collider = nil
    self.active = false

    self.radius = 5
    self.speed = speed

    return self
end

function Ball:toss(x, y, angleDeg)
    if self.exploded then return end
    self:deactivate()

    self.collider = self.world:newCollider("Circle", { x, y, self.radius })
    self.collider:setType("dynamic")
    self.collider:setRestitution(0.1)
    self.collider:setFriction(0)
    self.collider:setLinearDamping(0)
    self.collider:setBullet(true)
    self.collider.isBall = true
    self.collider.parent = self

    local angle = math.rad(angleDeg)
    local vx = self.speed * math.cos(angle)
    local vy = -self.speed * math.sin(angle)

    self.collider:setLinearVelocity(vx, vy)
    self.active = true
    self.exploded = false
end

function Ball:deactivate()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end

    self.active = false
end

function Ball:explode()
    if self.exploded then return end
    self.explodeAnimation:gotoFrame(1)
    self.explodeAnimation:resume()
    self.lastX, self.lastY = self.collider:getPosition()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
    self.exploded = true
    self.onExplode(0.2, 3)
end

function Ball:update(dt)
    if not self.active then return end

    if self.to_explode then
        self:explode()
        -- print("Ball destroyed")
    end

    self.explodeAnimation:update(dt)
end

function Ball:getPosition()
    if not self.active then return nil end
    return self.collider:getPosition()
end

function Ball:draw()
    if not self.active then return end

    local x, y
    if not self.exploded then
        x, y = self.collider:getPosition()
    else
        x, y = self.lastX, self.lastY
    end
    if not self.exploded then
        love.graphics.draw(
            self.sprite,
            x,
            y,
            0,
            1,
            1,
            self.radius,
            self.radius
        )
    end
    if self.explodeAnimation.status ~= "paused" then
        self.explodeAnimation:draw(self.explodeSpriteSheet, x - 16, y - 16)
    end
end

return Ball
