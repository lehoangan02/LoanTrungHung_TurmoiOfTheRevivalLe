local InputManager = {}

local wasPauseKeyPressed = false
local pauseSignaled = false
local wasFKeyPressed = false
local fSignaled = false
local wasUpKeyPressed = false
local upSignaled = false
local wasDownKeyPressed = false
local downSignaled = false
local wasLeftKeyPressed = false
local leftSignaled = false
local wasRightKeyPressed = false
local rightSignaled = false



local KY040 = require("Game.Input.KY040")
local Controller = require("Game.Input.Controller")
local controller = Controller:new()
local handCrankMultiplier = 3
local joystickMultiplier = 4
local triggerMultiplier = 0.8


function InputManager:load()
    
end

function InputManager:update()
    local isCurrentlyPressed = love.keyboard.isDown("p")
    pauseSignaled = isCurrentlyPressed and not wasPauseKeyPressed
    wasPauseKeyPressed = isCurrentlyPressed
    local isFCurrentlyPressed = love.keyboard.isDown("f")
    fSignaled = isFCurrentlyPressed and not wasFKeyPressed
    wasFKeyPressed = isFCurrentlyPressed
    local isUpCurrentlyPressed = love.keyboard.isDown("up") or love.keyboard.isDown("w")
    upSignaled = isUpCurrentlyPressed and not wasUpKeyPressed
    wasUpKeyPressed = isUpCurrentlyPressed
    local isDownCurrentlyPressed = love.keyboard.isDown("down") or love.keyboard.isDown("s")
    downSignaled = isDownCurrentlyPressed and not wasDownKeyPressed
    wasDownKeyPressed = isDownCurrentlyPressed
    local isLeftCurrentlyPressed = love.keyboard.isDown("left") or love.keyboard.isDown("a")
    leftSignaled = isLeftCurrentlyPressed and not wasLeftKeyPressed
    wasLeftKeyPressed = isLeftCurrentlyPressed
    local isRightCurrentlyPressed = love.keyboard.isDown("right") or love.keyboard.isDown("d")
    rightSignaled = isRightCurrentlyPressed and not wasRightKeyPressed
    wasRightKeyPressed = isRightCurrentlyPressed

    KY040:update()
    controller:update()
end

function InputManager:isEventFKeyPressed()
    return fSignaled
end

function InputManager:isEventPauseKeyPressed()
    return pauseSignaled
end

function InputManager:isEventUpKeyPressed()
    return upSignaled
end

function InputManager:isEventDownKeyPressed()
    return downSignaled
end

function InputManager:isEventLeftKeyPressed()
    return leftSignaled
end

function InputManager:isEventRightKeyPressed()
    return rightSignaled
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
    return love.keyboard.isDown("j")
end
    
function InputManager:isRightRudderPressed()
    return love.keyboard.isDown("k")
end

function InputManager:isEventKY040ButtonPressed()
    return KY040:isEventPressed("ENCODER_BUTTON")
end

function InputManager:isEventKY040RightTurned()
    return KY040:isEventPressed("ENCODER_RIGHT")
end

function InputManager:isEventKY040LeftTurned()
    return KY040:isEventPressed("ENCODER_LEFT")
end

function InputManager:getLeftStickRotation()
    return controller:leftStickRotation()
end

function InputManager:getRightStickRotation()
    return controller:rightStickRotation()
end

function InputManager:getLeftTriggerValue()
    return controller:leftTriggerValue()
end

function InputManager:getRightTriggerValue()
    return controller:rightTriggerValue()
end

function InputManager:getHandCrankMultiplier()
    return handCrankMultiplier
end

function InputManager:getJoystickMultiplier()
    return joystickMultiplier
end

function InputManager:getTriggerMultiplier()
    return triggerMultiplier
end

return InputManager