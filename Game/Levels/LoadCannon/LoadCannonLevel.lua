local Level = require("Game.Levels.Level")
local LoadCannonLevel = setmetatable({}, {__index = Level})
LoadCannonLevel.__index = LoadCannonLevel

function LoadCannonLevel:load()
    LoadCannonLevel.worldGravity = 250

    LoadCannonLevel.cameraX = 120
    LoadCannonLevel.cameraY = 120

    local camera = require("Game.Libraries.camera")
    LoadCannonLevel.cam = camera()
    LoadCannonLevel.cam:lookAt(LoadCannonLevel.cameraX, LoadCannonLevel.cameraY)

    LoadCannonLevel.roomSprite = love.graphics.newImage("Resources/Images/LowerSiegeTower.png")
    LoadCannonLevel.roomSprite:setFilter("nearest", "nearest")

    LoadCannonLevel.cannonSprite = love.graphics.newImage("Resources/Images/LowerCannon.png")
    LoadCannonLevel.cannonSprite:setFilter("nearest", "nearest")
end

function LoadCannonLevel:update(dt)
    local LevelEnum = require("Game.Levels.LevelEnum")
    return LevelEnum.Nothing
end

function LoadCannonLevel:draw(windowWidth, windowHeight)

    local scale = math.min(windowHeight / (BASE_H or 240), windowWidth / (BASE_W or 240))
    love.graphics.scale(scale, scale)
    love.graphics.translate((windowWidth / 2) * (1-scale) / scale, (windowHeight / 2) * (1-scale) / scale)

    LoadCannonLevel.cam:attach()
        love.graphics.draw(self.roomSprite, 0, 0)
        love.graphics.draw(self.cannonSprite, 0, 0)
    LoadCannonLevel.cam:detach()
end

function LoadCannonLevel:unload()
end

return LoadCannonLevel