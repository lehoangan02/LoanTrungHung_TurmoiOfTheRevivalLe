local Level = require("Game.Levels.Level")
local LoadCannonLevel = setmetatable({}, {__index = Level})
LoadCannonLevel.__index = LoadCannonLevel

local bf = require("Game/Libraries/breezefield-master")

function LoadCannonLevel:load()
    LoadCannonLevel.worldGravity = 250
    LoadCannonLevel.world = bf.newWorld(0, LoadCannonLevel.worldGravity, true)

    LoadCannonLevel.cameraX = 120
    LoadCannonLevel.cameraY = 120

    local camera = require("Game.Libraries.camera")
    LoadCannonLevel.cam = camera()
    LoadCannonLevel.cam:lookAt(LoadCannonLevel.cameraX, LoadCannonLevel.cameraY)

    LoadCannonLevel.roomSprite = love.graphics.newImage("Resources/Images/LowerSiegeTower.png")
    LoadCannonLevel.roomSprite:setFilter("nearest", "nearest")

    LoadCannonLevel.cannonSprite = love.graphics.newImage("Resources/Images/LowerCannon.png")
    LoadCannonLevel.cannonSprite:setFilter("nearest", "nearest")

    LoadCannonLevel.soldier = require("Game.Levels.LoadCannon.LoadRoleSoldier")
    LoadCannonLevel.soldier:load(LoadCannonLevel.spawnCannonBall)

    LoadCannonLevel.isBallSpawned = false

    LoadCannonLevel.strawDampingCollider = LoadCannonLevel.world:newCollider("Rectangle", {95, 150, 30, 10})
    LoadCannonLevel.strawDampingCollider:setType("static")
end

function LoadCannonLevel:spawnCannonBall()
    if LoadCannonLevel.isBallSpawned then
        return
    end
    print("Spawning cannon ball")
    LoadCannonLevel.isBallSpawned = true
    local radius = 4
    LoadCannonLevel.cannonBallCollider = LoadCannonLevel.world:newCollider("Circle", {95, 0, radius})
    LoadCannonLevel.cannonBallCollider:setType("dynamic")
    LoadCannonLevel.cannonBallCollider:setRestitution(0.3)
end

function LoadCannonLevel:update(dt)
    local LevelEnum = require("Game.Levels.LevelEnum")
    LoadCannonLevel.soldier:update(dt)
    LoadCannonLevel.world:update(dt)
    return LevelEnum.Nothing
end

function LoadCannonLevel:draw(windowWidth, windowHeight)

    local scale = math.min(windowHeight / (BASE_H or 240), windowWidth / (BASE_W or 240))
    love.graphics.scale(scale, scale)
    love.graphics.translate((windowWidth / 2) * (1-scale) / scale, (windowHeight / 2) * (1-scale) / scale)

    LoadCannonLevel.cam:attach()
        
        love.graphics.draw(self.roomSprite, 0, 0)
        LoadCannonLevel.soldier:draw()
        love.graphics.draw(self.cannonSprite, 0, 0)
        LoadCannonLevel.world:draw()
        
    LoadCannonLevel.cam:detach()
end

function LoadCannonLevel:unload()
end

return LoadCannonLevel