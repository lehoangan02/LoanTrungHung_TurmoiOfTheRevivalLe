local Level = require("Game.Levels.Level")
local BlastFortLevel = setmetatable({}, {__index = Level})
BlastFortLevel.__index = BlastFortLevel

local bf = require("Game/Libraries/breezefield-master")
local DEBUG = false

function BlastFortLevel:load()
    BlastFortLevel.worldGravity = 250
    BlastFortLevel.world = bf.newWorld(0, BlastFortLevel.worldGravity, true)

    BlastFortLevel.intactSprite = love.graphics.newImage("Resources/Images/CannonBlastFort.png")
    BlastFortLevel.intactSprite:setFilter("nearest", "nearest")

    BlastFortLevel.frontTowerSprite = love.graphics.newImage("Resources/Images/")
end

return BlastFortLevel
