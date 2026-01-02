local InputManager = {}

InputManager.wasPauseKeyPressed = false
InputManager.pauseSignaled = false

function InputManager:update()
    local isCurrentlyPressed = love.keyboard.isDown("p")
    self.pauseSignaled = isCurrentlyPressed and not self.wasPauseKeyPressed
    self.wasPauseKeyPressed = isCurrentlyPressed
end

function InputManager:isEventPauseKeyPressed()
    return self.pauseSignaled
end

function InputManager:isKeyRightPressed()
    return love.keyboard.isDown("right") or love.keyboard.isDown("d")
end

function InputManager:isKeyLeftPressed()
    return love.keyboard.isDown("left") or love.keyboard.isDown("a")
end

function InputManager:isKeyUpPressed()
    return love.keyboard.isDown("up") or love.keyboard.isDown("w")
end

function InputManager:isKeyDownPressed()
    return love.keyboard.isDown("down") or love.keyboard.isDown("s")
end

return InputManager