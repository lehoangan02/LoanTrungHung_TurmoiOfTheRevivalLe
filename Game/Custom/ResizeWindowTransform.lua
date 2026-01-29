local ResizeWindowTransform = {}

function ResizeWindowTransform.getTransform(windowWidth, windowHeight, baseWidth, baseHeight)
    local scale = math.max(1, math.floor(
    math.min(windowHeight / BASE_H, windowWidth / BASE_W)))
    local centerX = windowWidth / 2
    local centerY = windowHeight / 2
    local gameWidth = BASE_W * scale
    local gameHeight = BASE_H * scale
    local offsetX = centerX - gameWidth / 2
    local offsetY = centerY - gameHeight / 2
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    return scale, offsetX, offsetY
end

return ResizeWindowTransform