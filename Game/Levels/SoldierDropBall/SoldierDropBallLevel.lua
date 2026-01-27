local Level = require "Game.Levels.Level"
local SoldierDropBallLevel = setmetatable({}, {__index = Level})
SoldierDropBallLevel.__index = SoldierDropBallLevel

local anim8 = require "Game/Libraries/anim8"

function SoldierDropBallLevel:shake(duration, magnitude)
    self.shakeDuration = duration
    self.shakeMagnitude = magnitude
    self.shakeTime = duration
end

function SoldierDropBallLevel:load()
    SoldierDropBallLevel.worldGravity = 250
    
    SoldierDropBallLevel.cameraX = 120
    SoldierDropBallLevel.cameraY = 120

    local camera = require("Game.Libraries.camera")
    SoldierDropBallLevel.cam = camera()
    SoldierDropBallLevel.cam:lookAt(SoldierDropBallLevel.cameraX, SoldierDropBallLevel.cameraY)

    SoldierDropBallLevel.roomSprite = love.graphics.newImage("Resources/Images/TopSiegeTower.png")
    SoldierDropBallLevel.roomSprite:setFilter("nearest", "nearest")
    
    SoldierDropBallLevel.cannonBarrelSprite = love.graphics.newImage("Resources/Images/BrokenCannonBarrel.png")
    SoldierDropBallLevel.cannonBarrelSprite:setFilter("nearest", "nearest")
    SoldierDropBallLevel.frontSupportSprite = love.graphics.newImage("Resources/Images/FrontSupport.png")
    SoldierDropBallLevel.frontSupportSprite:setFilter("nearest", "nearest")
    SoldierDropBallLevel.backSupportSprite = love.graphics.newImage("Resources/Images/BackSupport.png")
    SoldierDropBallLevel.backSupportSprite:setFilter("nearest", "nearest")
    SoldierDropBallLevel.frontCannonBallsSprite = love.graphics.newImage("Resources/Images/FrontCannonBalls.png")
    SoldierDropBallLevel.frontCannonBallsSprite:setFilter("nearest", "nearest")
    SoldierDropBallLevel.backCannonBallsSprite = love.graphics.newImage("Resources/Images/BackCannonBalls.png")
    SoldierDropBallLevel.backCannonBallsSprite:setFilter("nearest", "nearest")
    SoldierDropBallLevel.topCannonBallSprite = love.graphics.newImage("Resources/Images/TopCannonBall.png")
    SoldierDropBallLevel.topCannonBallSprite:setFilter("nearest", "nearest")

end

function SoldierDropBallLevel:update(dt)
    local LevelEnum = require("Game.Levels.LevelEnum")
    return LevelEnum.Nothing
end

function SoldierDropBallLevel:draw(windowWidth, windowHeight)

    local scale = math.min(windowHeight / (BASE_H or 240), windowWidth / (BASE_W or 240))
    love.graphics.scale(scale, scale)
    love.graphics.translate((windowWidth / 2) * (1-scale) / scale, (windowHeight / 2) * (1-scale) / scale)

    SoldierDropBallLevel.cam:attach()
        love.graphics.draw(self.roomSprite, 0, 0)
        love.graphics.draw(self.backSupportSprite, 0, 0)
        love.graphics.draw(self.cannonBarrelSprite, 0, 0)
        love.graphics.draw(self.frontSupportSprite, 0, 0)
        love.graphics.draw(self.backCannonBallsSprite, 0, 0)
        love.graphics.draw(self.frontCannonBallsSprite, 0, 0)
        love.graphics.draw(self.topCannonBallSprite, 0, 0)
    SoldierDropBallLevel.cam:detach()
end

return SoldierDropBallLevel