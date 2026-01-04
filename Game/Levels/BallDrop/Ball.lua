local Ball = {}
Ball.__index = Ball

function Ball.new(world, x, y)
    local instance = setmetatable({}, Ball)
    local anim8 = require "Game/Libraries/anim8"

    instance.ballImage = love.graphics.newImage("Resources/Images/Cannon_ball.png")
    instance.ballImage:setFilter("nearest", "nearest")
    
    instance.explodeSpriteSheet = love.graphics.newImage("Resources/Images/explode_large.png")
    instance.explodeGrid = anim8.newGrid(32, 32, instance.explodeSpriteSheet:getWidth(), instance.explodeSpriteSheet:getHeight())
    instance.explodeAnimation = anim8.newAnimation(instance.explodeGrid('1-4', 1), 0.2, 'pauseAtEnd')
    
    instance.exploded = false
    instance.ballRotation = 0
    instance.ballRadius = 7
    instance.ballX = x
    instance.ballY = y
    
    instance.ballCollider = world:newCircleCollider(instance.ballX, instance.ballY, instance.ballRadius)
    instance.ballCollider:setRestitution(0.6)
    
    return instance
end

function Ball:update(dt, worldRotation)
    if not self.exploded then
        self:rotateBall(dt, worldRotation)
        self.ballX, self.ballY = self.ballCollider:getPosition()
        
        if self.ballCollider:enter("Enemies") then
            print("Collided with enemies")
            self:explode()
        end
        if self.ballCollider:enter("Stars") then
            print("Collided with stars")
        end
    end
    if self.ballCollider:enter("Stars") then
            print("Collided with stars")
    end
    self.explodeAnimation:update(dt)
end

function Ball:explode()
    if not self.exploded then
        self.exploded = true
        self.explodeAnimation:gotoFrame(1)
        self.explodeAnimation:resume()
        self.ballCollider:destroy()
    end
end

function Ball:rotateBall(dt, world)
    local velX, velY = self.ballCollider:getLinearVelocity()
    local gx, gy = world:getGravity()
    local glen = math.sqrt(gx*gx + gy*gy)
    
    if glen > 0 then
        local gnx = gx / glen
        local gny = gy / glen
        local tx = -gny
        local ty = gnx
        local tangentialSpeed = -(velX * tx + velY * ty) * 3
        local rotateSpeedLimit = 120
        
        if tangentialSpeed > rotateSpeedLimit then
            tangentialSpeed = rotateSpeedLimit
        elseif tangentialSpeed < -rotateSpeedLimit then
            tangentialSpeed = -rotateSpeedLimit
        end

        self.ballRotation = self.ballRotation + (tangentialSpeed / self.ballRadius) * dt
    end
end

function Ball:draw()
    if not self.exploded then
        love.graphics.draw(self.ballImage, self.ballX, self.ballY, self.ballRotation, 1, 1, 8, 8)
    end
    if self.exploded and self.explodeAnimation.status ~= "paused" then
        self.explodeAnimation:draw(self.explodeSpriteSheet, self.ballX - 16, self.ballY - 16)
    end
end

return Ball