local DialogCloud = {}
DialogCloud.__index = DialogCloud

local FontLoader = require("Game.Fonts.FontLoader")

function DialogCloud.new(text, x, y, width, height)
    local instance = setmetatable({}, DialogCloud)

    instance.text = text
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height

    instance.font = FontLoader:loadFont("Geo", 16)

    instance.sproutSpritesheet = love.graphics.newImage("Resources/Images/.png")

    return instance
end

function DialogCloud:update(dt)
end

function DialogCloud:draw()
end

return DialogCloud