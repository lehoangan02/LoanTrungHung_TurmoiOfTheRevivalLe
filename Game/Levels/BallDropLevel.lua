local Level = require "Game.Levels.Level"
local BallDropLevel = setmetatable({}, {__index = Level})
BallDropLevel.__index = BallDropLevel

function BallDropLevel:load()
    local sti = require "Game/Libraries/sti"
    BallDropLevel.gameMap = sti("Game/Maps/testMap.lua")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    musicManager:playBackgroundMusic(MusicEnum.Sakura_Cherry_Blossom)
    BallDropLevel.ballImage = love.graphics.newImage("Resources/Images/Cannon_ball.png")
    BallDropLevel.ballImage:setFilter("nearest", "nearest")
    BallDropLevel.ballRotation = 0
    BallDropLevel.ballRadius = 7
    BallDropLevel.ballMoveSpeed = 100
    BallDropLevel.worldRotateSpeed = 2
    BallDropLevel.ballX = 100
    BallDropLevel.ballY = 100
    local camera = require("Game.Libraries.camera")
    BallDropLevel.cam = camera()
    local wf = require("Game/Libraries/windfield")
    BallDropLevel.worldGravity = 300
    BallDropLevel.world = wf.newWorld(0, BallDropLevel.worldGravity, false)
    BallDropLevel.worldRotation = 0
    BallDropLevel.walls = {}
    if BallDropLevel.gameMap.layers["StaticCollidable"] then
        for i, obj in pairs(BallDropLevel.gameMap.layers["StaticCollidable"].objects) do
            local wall = BallDropLevel.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(BallDropLevel.walls, wall)
        end
    end

    BallDropLevel.ballCollider = BallDropLevel.world:newCircleCollider(BallDropLevel.ballX, BallDropLevel.ballY, BallDropLevel.ballRadius)
    BallDropLevel.ballCollider:setRestitution(0.4)
end
function BallDropLevel:update(dt)
    local velX, velY = BallDropLevel.ballCollider:getLinearVelocity()

    local gx, gy = BallDropLevel.world:getGravity()
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

        BallDropLevel.ballRotation =
            BallDropLevel.ballRotation + (tangentialSpeed / BallDropLevel.ballRadius) * dt
    
    end


    InputManager = require("Game.Input.InputManager")
    if InputManager:isRightRudderPressed()  or InputManager:isEventKY040RightTurned() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation + dt * BallDropLevel.worldRotateSpeed
        BallDropLevel.cam:rotate(dt * BallDropLevel.worldRotateSpeed)
    end
    if InputManager:isLeftRudderPressed() or InputManager:isEventKY040LeftTurned() then
        BallDropLevel.worldRotation = BallDropLevel.worldRotation - dt * BallDropLevel.worldRotateSpeed
        BallDropLevel.cam:rotate(-dt * BallDropLevel.worldRotateSpeed)
    end
    local gx, gy
    gx = BallDropLevel.worldGravity * math.sin(BallDropLevel.worldRotation)
    gy = BallDropLevel.worldGravity * math.cos(BallDropLevel.worldRotation)
    BallDropLevel.world:setGravity(gx, gy)
    BallDropLevel.world:update(dt)
    BallDropLevel.ballX, BallDropLevel.ballY = BallDropLevel.ballCollider:getPosition()
    BallDropLevel.cam:lookAt(120, BallDropLevel.ballY)
end
function BallDropLevel:draw(windowWidth, windowHeight)
    love.graphics.clear(176/255, 174/255, 167/255, 1)
    local scaleX = windowHeight / BASE_H
    local scaleY = windowWidth / BASE_W
    local centerX = windowWidth / 2
    local centerY = windowHeight / 2
    local scale = math.min(scaleX, scaleY)
    love.graphics.scale(scale, scale)
    love.graphics.translate(centerX * (1-scale) / scale, centerY * (1-scale) / scale)
    BallDropLevel.cam:attach()
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Background"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Wall"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["NonCollidable"])
        BallDropLevel.world:draw()
        love.graphics.draw(BallDropLevel.ballImage, BallDropLevel.ballX, BallDropLevel.ballY, BallDropLevel.ballRotation, 1, 1, 8, 8)
    BallDropLevel.cam:detach()
end
function BallDropLevel:unload()
end

return BallDropLevel