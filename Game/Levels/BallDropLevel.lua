local Level = require "Game.Levels.Level"
local BallDropLevel = setmetatable({}, {__index = Level})
BallDropLevel.__index = BallDropLevel

function BallDropLevel:load()
    local sti = require "Game/Libraries/sti"
    BallDropLevel.gameMap = sti("Game/Maps/testMap.lua")
    local musicManager = require("Game.Music.MusicManager")
    local MusicEnum = require("Game.Music.MusicEnum")
    -- musicManager:playBackgroundMusic(MusicEnum.Test)
    BallDropLevel.ballImage = love.graphics.newImage("Resources/Images/Cannon_ball.png")
    BallDropLevel.ballImage:setFilter("nearest", "nearest")
    BallDropLevel.ballRotation = 0
    BallDropLevel.ballRotationSpeed = 5
    BallDropLevel.ballX = 100
    BallDropLevel.ballY = 100
    local camera = require("Game.Libraries.camera")
    BallDropLevel.cam = camera()
end
function BallDropLevel:update(dt)
    BallDropLevel.ballRotation = BallDropLevel.ballRotation + dt * BallDropLevel.ballRotationSpeed
    InputManager = require("Game.InputManager")
    if InputManager:isKeyRightPressed() then
        BallDropLevel.ballX = BallDropLevel.ballX + 100 * dt
    end
    if InputManager:isKeyLeftPressed() then
        BallDropLevel.ballX = BallDropLevel.ballX - 100 * dt
    end
    if InputManager:isKeyDownPressed() then
        BallDropLevel.ballY = BallDropLevel.ballY + 100 * dt
    end
    if InputManager:isKeyUpPressed() then
        BallDropLevel.ballY = BallDropLevel.ballY - 100 * dt
    end
    BallDropLevel.cam:lookAt(BallDropLevel.ballX, BallDropLevel.ballY)
end
function BallDropLevel:draw(windowWidth, windowHeight)
    local scaleX = windowHeight / BASE_H
    local scaleY = windowWidth / BASE_W
    local centerX = windowWidth / 2
    local centerY = windowHeight / 2
    local scale = math.min(scaleX, scaleY)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-windowWidth / 2 + centerX / scale, -windowHeight / 2 + centerY / scale)
    BallDropLevel.cam:attach()
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Background"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["Wall"])
        BallDropLevel.gameMap:drawLayer(BallDropLevel.gameMap.layers["NonCollidable"])
        -- BallDropLevel.gameMap:draw()
        love.graphics.draw(BallDropLevel.ballImage, BallDropLevel.ballX, BallDropLevel.ballY, BallDropLevel.ballRotation, 1, 1, 8, 8)
    BallDropLevel.cam:detach()
end
function BallDropLevel:unload()
end

return BallDropLevel