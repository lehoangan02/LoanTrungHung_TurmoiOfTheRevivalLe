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
    GameManager.currentLevel = levelLoader:loadLevel(LevelEnum.BallDrop)
end
function GameManager:update(dt)
    inputManager:update()
    local LevelEnum = require("Game.Levels.LevelEnum")
    if (GameManager.currentLevel:update(dt) ~= LevelEnum.Nothing) then
        GameManager.currentLevel:unload()
        GameManager.currentLevel = levelLoader:loadLevel(LevelEnum.StartMenu)
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
end


return GameManager