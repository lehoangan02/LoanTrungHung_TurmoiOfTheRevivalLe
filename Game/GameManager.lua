local LevelEnum = require("Game.Levels.LevelEnum")
local levelLoader = require("Game.Levels.LevelLoader")
local inputManager = require("Game.InputManager")

local GameManager = {}
GameManager.__index = GameManager


function GameManager.new()
    local self = setmetatable({}, GameManager)
    return self
end

function GameManager:start()
    GameManager.currentLevel = levelLoader:loadLevel(LevelEnum.StartMenu)
end
function GameManager:update(dt)
    inputManager:update()
end
function GameManager:pause()
end
function GameManager:resume()
end
function GameManager:quit()
end
function GameManager:draw()
    GameManager.currentLevel:draw()
end


return GameManager