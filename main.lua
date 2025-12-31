local Main = {}

local BASE_W = 240
local BASE_H = 240

function love.load()
    love.window.setTitle("Turmoi of The Revival Le")
    love.window.setMode(BASE_W, BASE_H, { resizable = true })

    Main.scale = 1
    Main.offsetX = 0
    Main.offsetY = 0

    GameManager = require("Game.GameManager")
    Main.gameManager = GameManager.new()
    Main.gameManager:start()
end

function love.resize(w, h)
    Main.scale = math.min(w / BASE_W, h / BASE_H)
    Main.offsetX = (w - BASE_W * Main.scale) * 0.5
    Main.offsetY = (h - BASE_H * Main.scale) * 0.5
end

function love.update(dt)
    Main.gameManager:update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(Main.offsetX, Main.offsetY)
    love.graphics.scale(Main.scale, Main.scale)
    Main.gameManager:draw()
    love.graphics.pop()
end
