local Controller = {}
Controller.__index = Controller

function Controller.new()
    local joystick = love.joystick.getJoysticks()[1] -- Get the first connected joystick
    local self = setmetatable({}, Controller)
    self.joystick = joystick
    self.leftX = 0
    self.leftY = 0
    self.prevLeftX = 0
    self.prevLeftY = 0
    self.rightX = 0
    self.rightY = 0
    self.prevRightX = 0
    self.prevRightY = 0
    self.buttons = {}
    return self
end

function Controller:update()
    if not self.joystick then return end
    
    self.prevLeftX = self.leftX
    self.prevLeftY = self.leftY
    self.leftX = self.joystick:getAxis(1) -- left stick X
    self.leftY = self.joystick:getAxis(2) -- left stick Y
    
    self.prevRightX = self.rightX
    self.prevRightY = self.rightY
    self.rightX = self.joystick:getAxis(3) -- right stick X
    self.rightY = self.joystick:getAxis(4) -- right stick Y

    for i = 1, self.joystick:getButtonCount() do
        self.buttons[i] = self.joystick:isDown(i)
    end
end

function Controller:getLeftStick()
    return self.leftX, self.leftY
end

function Controller:getRightStick()
    return self.rightX, self.rightY
end

function Controller:isButtonDown(buttonIndex)
    return self.buttons[buttonIndex] or false
end

local lengthThreshold = 0.6
function Controller:leftStickRotation()
    local prevVectorLength = math.sqrt(self.prevLeftX * self.prevLeftX + self.prevLeftY * self.prevLeftY)
    local currentVectorLength = math.sqrt(self.leftX * self.leftX + self.leftY * self.leftY)
    if (prevVectorLength < lengthThreshold) or (currentVectorLength < lengthThreshold) then
        return 0
    end
    return math.atan2(self.prevLeftX * self.leftY - self.prevLeftY * self.leftX,
                     self.prevLeftX * self.leftX + self.prevLeftY * self.leftY) 
end

function Controller:rightStickRotation()
    local prevVectorLength = math.sqrt(self.prevRightX * self.prevRightX + self.prevRightY * self.prevRightY)
    local currentVectorLength = math.sqrt(self.rightX * self.rightX + self.rightY * self.rightY)
    if (prevVectorLength < lengthThreshold) or (currentVectorLength < lengthThreshold) then
        return 0
    end
    return math.atan2(self.prevRightX * self.rightY - self.prevRightY * self.rightX,
                     self.prevRightX * self.rightX + self.prevRightY * self.rightY) 
end

function Controller:leftTriggerValue()
    if not self.joystick then return 0 end
    return self.joystick:getAxis(5) -- left trigger
end

function Controller:rightTriggerValue()
    if not self.joystick then return 0 end
    return self.joystick:getAxis(6) -- right trigger
end

return Controller
