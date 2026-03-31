local currentLevel

local LevelLoader = {}

function LevelLoader:loadLevel(level)
    LevelEnum = require("Game.Levels.LevelEnum")
    if (level == LevelEnum.StartMenu) then
        local MenuLevel = require("Game.Levels.Menu.MenuLevel")
        MenuLevel:load()
        currentLevel = MenuLevel
    elseif (level == LevelEnum.BallDrop) then
        local BallDropLevel = require("Game.Levels.BallDrop.BallDropLevel")
        BallDropLevel:load()
        currentLevel = BallDropLevel
    elseif (level == LevelEnum.NgocHoi) then
        local NgocHoi = require("Game.Levels.NgocHoi.NgocHoi")
        NgocHoi:load()
        currentLevel = NgocHoi
    elseif (level == LevelEnum.SoldierDropBall) then
        local SoldierDropBallLevel = require("Game.Levels.SoldierDropBall.SoldierDropBallLevel")
        SoldierDropBallLevel:load()
        currentLevel = SoldierDropBallLevel
    elseif (level == LevelEnum.PlayGround) then
        local PlayGround = require("Game.Levels.Playground.Playground")
        PlayGround:load()
        currentLevel = PlayGround
    elseif (level == LevelEnum.SolderLoadCannon) then
        local LoadCannonLevel = require("Game.Levels.LoadCannon.LoadCannonLevel")
        LoadCannonLevel:load()
        currentLevel = LoadCannonLevel
    elseif (level == LevelEnum.TowerBlastFort) then
        local TowerBlastFortLevel = require("Game.Levels.BlastFort.BlastFortLevel")
        TowerBlastFortLevel:load()
        currentLevel = TowerBlastFortLevel
    else
        error("Unknown level: " .. tostring(level))
    end
    return currentLevel
end

return LevelLoader