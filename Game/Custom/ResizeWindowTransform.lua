local ResizeWindowTransform = {}

function ResizeWindowTransform.getTransform(windowWidth, windowHeight, baseWidth, baseHeight)
    local fontScale = math.max(1, math.floor(
    math.min(windowHeight / BASE_H, windowWidth / BASE_W)))
    local scale = math.min(windowHeight / (BASE_H or 240), windowWidth / (BASE_W or 240))
    local centerX = windowWidth / 2
    local centerY = windowHeight / 2
    local gameWidth = BASE_W * scale
    local gameHeight = BASE_H * scale
    local offsetX = centerX - gameWidth / 2
    local offsetY = centerY - gameHeight / 2
    local offsetXCameraMode = (windowWidth / 2) * (1-scale)
    local offsetYCameraMode = (windowHeight / 2) * (1-scale)
    -- love.graphics.translate(offsetX, offsetY)
    -- love.graphics.scale(scale, scale)

    return scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode
end

return ResizeWindowTransform