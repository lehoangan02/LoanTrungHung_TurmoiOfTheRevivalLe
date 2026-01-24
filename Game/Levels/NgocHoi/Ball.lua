local Ball = {}
Ball.__index = Ball

function Ball.new(world, speed)
    local self = setmetatable({}, Ball)

    self.to_destroy = false

    self.world = world
    self.sprite = love.graphics.newImage("Resources/Images/Canon_bala.png")
    self.sprite:setFilter("nearest", "nearest")

    self.collider = nil
    self.active = false

    self.radius = 5
    self.speed = speed

    return self
end

function Ball:toss(x, y, angleDeg)
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
end

function Ball:deactivate()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end

    self.active = false
end

function Ball:update(dt)
    if not self.active then return end

    if self.to_destroy then
        self:deactivate()
        print("Ball destroyed")
        return
    end

    if not self.collider or self.collider:isDestroyed() then
        self:deactivate()
    end
end

function Ball:getPosition()
    if not self.active then return nil end
    return self.collider:getPosition()
end

function Ball:draw()
    if not self.active then return end

    local x, y = self.collider:getPosition()

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

return Ball
