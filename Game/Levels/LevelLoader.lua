local currentLevel

local LevelLoader = {}

function LevelLoader:loadLevel(level)
    LevelEnum = require("Game.Levels.LevelEnum")
    if (level == LevelEnum.StartMenu) then
        local MenuLevel = require("Game.Levels.MenuLevel")
        MenuLevel.load()
        currentLevel = MenuLevel
    end
    return currentLevel
end

return LevelLoader