local InputManager = {}

function InputManager:load()
    InputManager.wasPauseKeyPressed = false
    InputManager.pauseSignaled = false
    InputManager.KY040 = require("Game.Services.KY040")

end

function InputManager:update()
    local isCurrentlyPressed = love.keyboard.isDown("p")
    self.pauseSignaled = isCurrentlyPressed and not self.wasPauseKeyPressed
    self.wasPauseKeyPressed = isCurrentlyPressed
    InputManager.KY040:update()
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

function InputManager:isLeftRudderPressed()
    return love.keyboard.isDown("q")
end

function InputManager:isRightRudderPressed()
    return love.keyboard.isDown("e")
end

function InputManager:isEventKY040ButtonPressed()
    return KY040:isButtonPressed()
end

function InputManager:isEventKY040RightTurned()
    return KY040:isRightTurned()
end

function InputManager:isEventKY040LeftTurned()
    return KY040:isLeftTurned()
end

return InputManager