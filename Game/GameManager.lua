local LevelEnum = require("Game.Levels.LevelEnum")
local levelLoader = require("Game.Levels.LevelLoader")
local inputManager = require("Game.Input.InputManager")

local GameManager = {}
GameManager.__index = GameManager


function GameManager.new()
    local self = setmetatable({}, GameManager)
    return self
end

function GameManager:start()
    inputManager:load()
    GameManager.currentLevel = levelLoader:loadLevel(LevelEnum.SoldierDropBall)
end
function GameManager:update(dt)
    inputManager:update(dt)
    local LevelEnum = require("Game.Levels.LevelEnum")
    local nextLevel = GameManager.currentLevel:update(dt)
    if (nextLevel ~= LevelEnum.Nothing) then
        GameManager.currentLevel:unload()
        GameManager.currentLevel = levelLoader:loadLevel(nextLevel)
    end
end
function GameManager:pause()
end
function GameManager:resume()
end
function GameManager:quit()
end
function GameManager:draw(windowWidth, windowHeight)
    GameManager.currentLevel:draw(windowWidth, windowHeight)

    -- love.graphics.setCanvas()
    -- love.graphics.setScissor()
    -- love.graphics.origin()


    -- local scale = math.min(
    --     windowWidth / BASE_W,
    --     windowHeight / BASE_H
    -- )

    -- local gameWidth = BASE_W * scale
    -- local gameHeight = BASE_H * scale

    -- local offsetX = (windowWidth - gameWidth) / 2
    -- local offsetY = (windowHeight - gameHeight) / 2

    -- love.graphics.setColor(1, 0, 0, 1)
    -- love.graphics.setLineWidth(2)
    -- love.graphics.rectangle(
    --     "line",
    --     offsetX,
    --     offsetY,
    --     gameWidth,
    --     gameHeight
    -- )

    -- love.graphics.setColor(1, 1, 1, 1)
    -- love.graphics.setLineWidth(1)
end



return GameManager