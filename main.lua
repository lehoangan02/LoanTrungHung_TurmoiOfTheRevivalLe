local Main = {}

BASE_W = 240
BASE_H = 240

function love.load()
    love.window.setTitle("Turmoi of The Revival Le")
    love.window.setMode(BASE_W, BASE_H, { resizable = true })
    
    GameManager = require("Game.GameManager")

    GameManager.windowWidth = BASE_W
    GameManager.windowHeight = BASE_H

    
    Main.gameManager = GameManager.new()
    Main.gameManager:start()
end

function love.resize(w, h)
    GameManager.windowWidth = w
    GameManager.windowHeight = h
end

function love.update(dt)
    Main.gameManager:update(dt)
end

function love.draw()
    love.graphics.push()
    Main.gameManager:draw(GameManager.windowWidth, GameManager.windowHeight)
    love.graphics.pop()
end
