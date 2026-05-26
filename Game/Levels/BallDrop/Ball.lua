local Ball = {}
Ball.__index = Ball

function Ball.new(world, x, y)
    local instance = setmetatable({}, Ball)
    local anim8 = require "Game/Libraries/anim8"

    instance.ballImage = love.graphics.newImage("Resources/Images/Cannon_ball.png")
    instance.width = instance.ballImage:getWidth()
    instance.height = instance.ballImage:getHeight()
    instance.ballImage:setFilter("nearest", "nearest")
    
    instance.explodeSpriteSheet = love.graphics.newImage("Resources/Images/explode_large.png")
    instance.explodeSpriteSheet:setFilter("nearest", "nearest")
    instance.explodeGrid = anim8.newGrid(32, 32, instance.explodeSpriteSheet:getWidth(), instance.explodeSpriteSheet:getHeight())
    instance.explodeAnimation = anim8.newAnimation(instance.explodeGrid('1-4', 1), 0.2, 'pauseAtEnd')
    
    instance.exploded = false
    instance.ballRotation = 0
    instance.ballRadius = 7
    instance.ballX = x
    instance.ballY = y
    
    instance.ballCollider = world:newCollider("Circle", {instance.ballX, instance.ballY, instance.ballRadius})
    instance.ballCollider:setRestitution(0.6)
    print("Ball mass: ", instance.ballCollider:getMass())
    instance.ballCollider:setLinearVelocity(0, 100)
    
    instance.ballCollider.ball = instance
    
    local BallDropLevel = require("Game.Levels.BallDrop.BallDropLevel")
    instance.ballCollider.fixture:setCategory(BallDropLevel.CATEGORY_BALL)
    
    function instance.ballCollider:enter(other, collision)
        if other.isEnemy then
            print("Collided with enemies")
            self.ball:explode()
        elseif other.isStar then
            print("Collided with stars")

            local starX, starY = other:getPosition()
            local BallDropLevel = require("Game.Levels.BallDrop.BallDropLevel")
            BallDropLevel.starActivateAnimation:play(starX, starY)
            
            local cx, cy = BallDropLevel.cam:cameraCoords(starX, starY)
            local GameManager = require("Game.GameManager")
            local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")
            local scale, _, _, _, offsetXCameraMode, offsetYCameraMode = ResizeWindowTransform.getTransform(GameManager.windowWidth, GameManager.windowHeight, BASE_W, BASE_H)
            local screenX = offsetXCameraMode + cx * scale
            local screenY = offsetYCameraMode + cy * scale
            
            local anim8 = require "Game/Libraries/anim8"
            local grid = anim8.newGrid(16, 16, BallDropLevel.starTrailImage:getWidth(), BallDropLevel.starTrailImage:getHeight())
            local anim = anim8.newAnimation(grid('1-6', 1), 0.1)
            
            table.insert(BallDropLevel.starTrails, {
                startX = screenX,
                startY = screenY,
                currentX = screenX,
                currentY = screenY,
                progress = 0,
                traces = {},
                anim = anim
            })
            
            if BallDropLevel.gameMap.layers["Stars"] then
                for idx, tObj in pairs(BallDropLevel.gameMap.layers["Stars"].objects) do
                    if tObj == other.tiledObject then
                        table.remove(BallDropLevel.gameMap.layers["Stars"].objects, idx)
                        break
                    end
                end
            end
            other:destroy()
            BallDropLevel.starsCollected = (BallDropLevel.starsCollected or 0) + 1
        end
    end
    
    return instance
end

function Ball:update(dt, worldRotation)
    if not self.exploded then
        self:rotateBall(dt, worldRotation)
        self.ballX, self.ballY = self.ballCollider:getPosition()
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
        love.graphics.draw(self.ballImage, self.ballX, self.ballY, self.ballRotation, 1, 1, self.width / 2, self.height / 2)
    end
    if self.exploded and self.explodeAnimation.status ~= "paused" then
        self.explodeAnimation:draw(self.explodeSpriteSheet, self.ballX - self.width, self.ballY - self.height)
    end
end

return Ball