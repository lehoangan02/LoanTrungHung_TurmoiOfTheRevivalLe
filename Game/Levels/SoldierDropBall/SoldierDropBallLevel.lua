local Level = require "Game.Levels.Level"
local SoldierDropBallLevel = setmetatable({}, {__index = Level})
SoldierDropBallLevel.__index = SoldierDropBallLevel

local LoadScreen = require("Game.Levels.LoadScreen.LoadScreen")

function SoldierDropBallLevel:shake(duration, magnitude)
    self.shakeDuration = duration
    self.shakeMagnitude = magnitude
    self.shakeTime = duration
end

function SoldierDropBallLevel:load()

    SoldierDropBallLevel.loadScreen = LoadScreen.new("Resources/Images/Hoangho_gt.jpg")

    SoldierDropBallLevel.loadScreen:reset()

    SoldierDropBallLevel.loadScreen:addTask(function()
        print("Dummy task 1 - waiting...")
        love.timer.sleep(0.1)
        print("Dummy task 1 - done!")
    end, 20)

    SoldierDropBallLevel.loadScreen:addTask(function()
        print("Dummy task 2 - waiting...")
        love.timer.sleep(0.15)
        print("Dummy task 2 - done!")
    end, 25)

    SoldierDropBallLevel.loadScreen:addTask(function()
        print("Dummy task 3 - waiting...")
        love.timer.sleep(0.2)
        print("Dummy task 3 - done!")
    end, 30)

    SoldierDropBallLevel.loadScreen:addTask(function()
        print("Dummy task 4 - loading actual level...")
        love.timer.sleep(0.2)
        print("Dummy task 4 - done!")
    end, 25)

    SoldierDropBallLevel.loadScreen:start()

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

    SoldierDropBallLevel.soldier = require("Game.Levels.SoldierDropBall.DropRoleSoldier")
    SoldierDropBallLevel.soldier:load()

end

function SoldierDropBallLevel:update(dt)
    if not SoldierDropBallLevel.loadScreen:isDone() then
        SoldierDropBallLevel.loadScreen:update(dt)
        return -1
    end
    local LevelEnum = require("Game.Levels.LevelEnum")
    return SoldierDropBallLevel.soldier:update(dt)
end

function SoldierDropBallLevel:draw(windowWidth, windowHeight)
    if not SoldierDropBallLevel.loadScreen:isDone() then
        SoldierDropBallLevel.loadScreen:draw()
        return
    end

    local scale = math.min(windowHeight / (BASE_H or 240), windowWidth / (BASE_W or 240))
    love.graphics.scale(scale, scale)
    love.graphics.translate((windowWidth / 2) * (1-scale) / scale, (windowHeight / 2) * (1-scale) / scale)

    SoldierDropBallLevel.cam:attach()
        love.graphics.draw(self.roomSprite, 0, 0)
        love.graphics.draw(self.backSupportSprite, 0, 0)
        SoldierDropBallLevel.soldier:draw()
        love.graphics.draw(self.cannonBarrelSprite, 0, 0)
        love.graphics.draw(self.frontSupportSprite, 0, 0)
        love.graphics.draw(self.frontCannonBallsSprite, 0, 0)
    SoldierDropBallLevel.cam:detach()
end

function SoldierDropBallLevel:unload()
end

return SoldierDropBallLevel