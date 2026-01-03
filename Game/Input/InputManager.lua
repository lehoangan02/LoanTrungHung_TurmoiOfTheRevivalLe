local InputManager = {}

function InputManager:load()
    InputManager.wasPauseKeyPressed = false
    InputManager.pauseSignaled = false
    InputManager.wasFKeyPressed = false
    InputManager.fSignaled = false
    InputManager.KY040 = require("Game.Input.KY040")
    local controller = require("Game.Input.Controller")
    InputManager.Controller = controller:new()
end

function InputManager:update()
    local isCurrentlyPressed = love.keyboard.isDown("p")
    self.pauseSignaled = isCurrentlyPressed and not self.wasPauseKeyPressed
    local isFCurrentlyPressed = love.keyboard.isDown("f")
    self.fSignaled = isFCurrentlyPressed and not self.wasFKeyPressed
    self.wasFKeyPressed = isFCurrentlyPressed
    self.wasPauseKeyPressed = isCurrentlyPressed
    InputManager.KY040:update()
    InputManager.Controller:update()
end

function InputManager:isEventFKeyPressed()
    return self.fSignaled
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
    return InputManager.KY040:isEventPressed("ENCODER_BUTTON")
end

function InputManager:isEventKY040RightTurned()
    return InputManager.KY040:isEventPressed("ENCODER_RIGHT")
end

function InputManager:isEventKY040LeftTurned()
    return InputManager.KY040:isEventPressed("ENCODER_LEFT")
end

return InputManager