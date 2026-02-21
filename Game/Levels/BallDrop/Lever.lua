local SwingLever = {}
SwingLever.__index = SwingLever

function SwingLever.new(world, axleX, axleY, maxMotorTorque, damping, initAngle)
    local self = setmetatable({}, SwingLever)

    self.maxMotorTorque = maxMotorTorque or 30
    self.damping = damping or 6

    local axleRadius = 5
    self.axle = world:newCollider("Circle", {axleX, axleY, axleRadius})
    self.axle:setType("static")

    local leverWidth = 50
    local leverHeight = 5
    local initialAngle = initAngle or 0
    

    local leverX = axleX + math.sin(initialAngle) * axleRadius
    local leverY = axleY - math.cos(initialAngle) * axleRadius
    self.lever = world:newCollider("Rectangle", {leverX, leverY, leverWidth, leverHeight})
    self.lever:setType("dynamic")
    self.lever.body:setMass(5)
    self.lever.body:setGravityScale(0)
    self.lever.body:setAngle(initialAngle)
    self.lever.body:setAngularVelocity(0)

    self.joint = love.physics.newRevoluteJoint(
        self.axle.body, 
        self.lever.body, 
        axleX, axleY,
        false
    )

    self.joint:setMotorEnabled(true)
    self.joint:setMaxMotorTorque(self.maxMotorTorque)
    

    return self
end

function SwingLever:update(dt)
    if self.joint then
        local angVel = self.joint:getJointSpeed()
        self.joint:setMotorSpeed(-self.damping * angVel)
    end
end

function SwingLever:draw()
    love.graphics.setColor(0.7, 0.7, 0.7)
    local shape = self.lever.fixture:getShape()
    local points = {self.lever.body:getWorldPoints(shape:getPoints())}
    love.graphics.polygon("fill", points)

    love.graphics.setColor(0.3, 0.3, 0.3)
    local ax, ay = self.axle:getPosition()
    local radius = self.axle.fixture:getShape():getRadius()
    love.graphics.circle("fill", ax, ay, radius)

    love.graphics.setColor(1, 1, 1, 1)
end

return SwingLever