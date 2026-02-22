local SwingLever = {}
SwingLever.__index = SwingLever

SwingLever.spikeImage = nil

function SwingLever.new(world, axleX, axleY, maxMotorTorque, damping, initAngle, minAngle, maxAngle, spikePlacement)
    local self = setmetatable({}, SwingLever)

    self.maxMotorTorque = maxMotorTorque or 30
    self.damping = damping or 6
    self.minAngle = minAngle
    self.maxAngle = maxAngle
    self.spikePlacement = spikePlacement or "none"

    if not SwingLever.spikeImage then
        SwingLever.spikeImage = love.graphics.newImage("Resources/Images/Spike.png")
    end

    local axleRadius = 5
    self.axle = world:newCollider("Circle", {axleX, axleY, axleRadius})
    self.axle:setType("static")

    self.leverWidth = 50
    self.leverHeight = 5
    local initialAngle = initAngle or 0
    
    local leverX = axleX + math.sin(initialAngle) * axleRadius
    local leverY = axleY - math.cos(initialAngle) * axleRadius
    self.lever = world:newCollider("Rectangle", {leverX, leverY, self.leverWidth, self.leverHeight})
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
    
    if self.minAngle and self.maxAngle then
        self.joint:setLowerLimit(self.minAngle)
        self.joint:setUpperLimit(self.maxAngle)
        self.joint:setLimitsEnabled(true)
    end

    if self.spikePlacement ~= "none" then
        local spikeSize = 8
        local localOffsetX = 0
        local localOffsetY = -(self.leverHeight / 2) - (spikeSize / 2)

        if self.spikePlacement == "left" then
            localOffsetX = -(self.leverWidth / 2) + (spikeSize / 2)
        elseif self.spikePlacement == "right" then
            localOffsetX = (self.leverWidth / 2) - (spikeSize / 2)
        end

        local spikeWorldX, spikeWorldY = self.lever.body:getWorldPoint(localOffsetX, localOffsetY)

        self.spike = world:newCollider("Rectangle", {spikeWorldX, spikeWorldY, spikeSize, spikeSize})
        self.spike.isEnemy = true
        self.spike:setType("dynamic")
        self.spike.body:setMass(0.5) 
        
        self.spike.body:setGravityScale(0) 
        
        self.spike.body:setAngle(initialAngle)
        
        self.spikeJoint = love.physics.newWeldJoint(
            self.lever.body, 
            self.spike.body, 
            spikeWorldX, spikeWorldY, 
            false
        )
    end

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

    if self.spike and SwingLever.spikeImage then
        local sx, sy = self.spike:getPosition()
        local sang = self.spike.body:getAngle()
        local imgW, imgH = SwingLever.spikeImage:getDimensions()

        love.graphics.draw(
            SwingLever.spikeImage, 
            sx, sy, 
            sang, 
            8 / imgW, 8 / imgH,
            imgW / 2, imgH / 2
        )
    end
end

return SwingLever