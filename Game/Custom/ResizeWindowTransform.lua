local ResizeWindowTransform = {}

function ResizeWindowTransform.getTransform(windowWidth, windowHeight, baseWidth, baseHeight)
    local fontScale = math.max(1, math.floor(
    math.min(windowHeight / baseHeight, windowWidth / baseWidth)))
    local scale = math.min(windowHeight / (baseHeight or 240), windowWidth / (baseWidth or 240))
    local centerX = windowWidth / 2
    local centerY = windowHeight / 2
    local gameWidth = baseWidth * scale
    local gameHeight = baseHeight * scale
    local offsetX = centerX - gameWidth / 2
    local offsetY = centerY - gameHeight / 2
    local offsetXCameraMode = (windowWidth / 2) * (1-scale)
    local offsetYCameraMode = (windowHeight / 2) * (1-scale)
    -- love.graphics.translate(offsetX, offsetY)
    -- love.graphics.scale(scale, scale)

    return scale, fontScale, offsetX, offsetY, offsetXCameraMode, offsetYCameraMode
end

return ResizeWindowTransform