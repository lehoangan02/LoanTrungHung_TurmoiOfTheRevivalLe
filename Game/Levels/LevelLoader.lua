local currentLevel

local LevelLoader = {}

function LevelLoader:loadLevel(level)
    LevelEnum = require("Game.Levels.LevelEnum")
    if (level == LevelEnum.StartMenu) then
        local MenuLevel = require("Game.Levels.MenuLevel")
        MenuLevel:load()
        currentLevel = MenuLevel
    end
    if (level == LevelEnum.BallDrop) then
        local BallDropLevel = require("Game.Levels.BallDropLevel")
        BallDropLevel:load()
        currentLevel = BallDropLevel
    end
    return currentLevel
end

return LevelLoader