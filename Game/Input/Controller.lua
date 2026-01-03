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
    
    self.leftX = self.joystick:getAxis(1) -- left stick X
    self.leftY = self.joystick:getAxis(2) -- left stick Y
    
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

function Controller:leftStickRotation()

end

return Controller
