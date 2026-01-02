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
    BallDropLevel.ballRotationSpeed = 5
    BallDropLevel.ballX = 100
    BallDropLevel.ballY = 100
    local camera = require("Game.Libraries.camera")
    BallDropLevel.cam = camera()
    local wf = require("Game/Libraries/windfield")
    BallDropLevel.world = wf.newWorld(0, 0, false)

    BallDropLevel.walls = {}
    if BallDropLevel.gameMap.layers["StaticCollidable"] then
        for i, obj in pairs(BallDropLevel.gameMap.layers["StaticCollidable"].objects) do
            local wall = BallDropLevel.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(BallDropLevel.walls, wall)
        end
    end

    BallDropLevel.ballCollider = BallDropLevel.world:newCircleCollider(BallDropLevel.ballX, BallDropLevel.ballY, 7)
end
function BallDropLevel:update(dt)
    BallDropLevel.ballRotation = BallDropLevel.ballRotation + dt * BallDropLevel.ballRotationSpeed
    InputManager = require("Game.InputManager")

    local vx, vy = 0, 0
    if InputManager:isKeyRightPressed() then
        vx = vx + 100
    end
    if InputManager:isKeyLeftPressed() then
        vx = vx - 100
    end
    if InputManager:isKeyDownPressed() then
        vy = vy + 100
    end
    if InputManager:isKeyUpPressed() then
        vy = vy - 100
    end
    BallDropLevel.ballCollider:setLinearVelocity(vx, vy)
    BallDropLevel.world:update(dt)
    BallDropLevel.ballX, BallDropLevel.ballY = BallDropLevel.ballCollider:getPosition()
    BallDropLevel.cam:lookAt(BallDropLevel.ballX, BallDropLevel.ballY)
end
function BallDropLevel:draw(windowWidth, windowHeight)
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