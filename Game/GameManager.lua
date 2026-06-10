local LevelEnum = require("Game.Levels.LevelEnum")
local levelLoader = require("Game.Levels.LevelLoader")
local inputManager = require("Game.Input.InputManager")
local Pause = require("Game.Pause")
local TransitionManager = require("Game.Transitions.TransitionManager")
local TransitionEnum = require("Game.Transitions.TransitionEnum")

local GameManager = {}
GameManager.__index = GameManager


function GameManager.new()
    local self = setmetatable({}, GameManager)
    return self
end

function GameManager:pause()
    GameManager.pauseScreen:toggle()
end

function GameManager:start()
    local w, h = love.graphics.getDimensions()
    GameManager.pauseScreen = Pause.new(w, h)
    inputManager:load(GameManager.pause)
    GameManager.currentLevel = levelLoader:loadLevel(LevelEnum.SoldierDropBall)
end
function GameManager:update(dt)
    -- Cap delta time to prevent physics explosions and animation skips during heavy synchronous loads
    if dt > 0.1 then dt = 0.1 end
    
    inputManager:update(dt)
    GameManager.pauseScreen:update(dt)
    if GameManager.pauseScreen.isPaused then
        return
    end
    
    if TransitionManager.isTransitioning then
        TransitionManager:update(dt)
        -- Keep updating the current level so it doesn't freeze awkwardly
        if GameManager.currentLevel then
            GameManager.currentLevel:update(dt)
        end
        return
    end

    local nextLevel = GameManager.currentLevel:update(dt)
    if (nextLevel ~= LevelEnum.Nothing) then
        GameManager:loadLevel(nextLevel, GameManager.currentLevel.transitionOut)
    end
end

function GameManager:loadLevel(levelEnum, transitionEnum)
    transitionEnum = transitionEnum or TransitionEnum.Fade
    
    local typeStr = "fade"
    if transitionEnum == TransitionEnum.SlideUp then
        typeStr = "slide_up"
    elseif transitionEnum == TransitionEnum.Grid then
        typeStr = "grid"
    end
    
    TransitionManager:start(typeStr, levelEnum, 0.7, function(lvl)
        if GameManager.currentLevel and GameManager.currentLevel.unload then
            GameManager.currentLevel:unload()
        end
        GameManager.currentLevel = levelLoader:loadLevel(lvl)
        
        -- Reset the timer so the massive synchronous load time isn't treated as animation time
        if love.timer then
            love.timer.step()
        end
    end)
end
function GameManager:quit()
end
function GameManager:draw(windowWidth, windowHeight)
    if GameManager.currentLevel then
        GameManager.currentLevel:draw(windowWidth, windowHeight)
    end
    
    if GameManager.pauseScreen.isPaused or GameManager.pauseScreen.animating then
        GameManager.pauseScreen:draw(windowWidth, windowHeight)
    end
    
    if TransitionManager.isTransitioning then
        TransitionManager:draw(windowWidth, windowHeight)
    end

    local scale = math.min(
        windowWidth / BASE_W,
        windowHeight / BASE_H
    )

    local gameWidth = BASE_W * scale
    local gameHeight = BASE_H * scale

    local offsetX = (windowWidth - gameWidth) / 2
    local offsetY = (windowHeight - gameHeight) / 2

    love.graphics.setColor(255/255, 200/255, 51/255, 1)
    
    if offsetX > 0 then
        -- Left border
        love.graphics.rectangle("fill", 0, 0, offsetX, windowHeight)
        -- Right border
        love.graphics.rectangle("fill", windowWidth - offsetX, 0, offsetX, windowHeight)
    end
    
    if offsetY > 0 then
        -- Top border
        love.graphics.rectangle("fill", 0, 0, windowWidth, offsetY)
        -- Bottom border
        love.graphics.rectangle("fill", 0, windowHeight - offsetY, windowWidth, offsetY)
    end

    -- Draw 4px (scaled) black outer border around the game window
    local borderThickness = 4 * scale
    love.graphics.setColor(0, 0, 0, 1)
    local prevLineWidth = love.graphics.getLineWidth()
    love.graphics.setLineWidth(borderThickness)
    -- Shift out by half thickness so it sits completely outside the 240x240 area
    love.graphics.rectangle("line", 
        offsetX - borderThickness / 2, 
        offsetY - borderThickness / 2, 
        gameWidth + borderThickness, 
        gameHeight + borderThickness
    )
    love.graphics.setLineWidth(prevLineWidth)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end



return GameManager