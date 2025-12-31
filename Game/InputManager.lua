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

return InputManager