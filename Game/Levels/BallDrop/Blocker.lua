local Blocker = {}

Blocker.__index = Blocker

function Blocker.new(world, gameMap, visualLayerName, colliderLayerName, machineID)
    local self = setmetatable({}, Blocker)
    self.gameMap = gameMap

    self.world = world 
    self.gameMap = gameMap
    
    self.visualLayerName = visualLayerName
    self.visualLayer = gameMap.layers[visualLayerName]
    
    if not self.visualLayer then
        print("Error: Visual layer '" .. visualLayerName .. "' not found.")
    end

    local colliderLayer = gameMap.layers[colliderLayerName]
    
    if not colliderLayer then 
        print("Error: Collider layer '" .. colliderLayerName .. "' not found.")
        return self 
    end
    
    if not colliderLayer.objects then 
        print("Error: Layer '" .. colliderLayerName .. "' has no objects (Is it a Tile Layer?).") 
        return self 
    end

    local obj = colliderLayer.objects[1]
    self.obj = obj
    local startX, startY = 0, 0
    if obj then
        startX = obj.x + obj.width / 2
        startY = obj.y + obj.height / 2

        self.blocker = world:newCollider("Rectangle", {
                startX, startY, obj.width - 2, obj.height - 2
            })

        self.blocker:setType("dynamic")
        self.blocker:setFixedRotation(true)
        self.blocker:setRestitution(0)
        self.blocker.fixture:setFriction(0)
        self.blocker.body:setSleepingAllowed(false)

        local anchor = love.physics.newBody(world._world, startX, startY, "static")

        local joint = love.physics.newPrismaticJoint(
            anchor,
            self.blocker.body,
            startX, startY,
            1, 0
        )
        self.joint = joint

        self.joint:setLowerLimit(-5000)
        self.joint:setUpperLimit(5000)
        self.joint:setLimitsEnabled(true)
        
        self.blockerStartPosition = {x = startX, y = startY}
    else
        print("Error: No object found inside '" .. colliderLayerName .. "'")
    end

    self.springImage = love.graphics.newImage("Resources/Images/Coil_Spring.png")
    self.numSpringCoils = 1
    local anchorX = obj.x + (5 * 16)
    local anchorY = startY

    self.anchorX = anchorX
    self.anchorY = anchorY

    local wireAnchorX = obj.x - (6 * 16) 
    local wireAnchorY = startY

    self.wireAnchorX = wireAnchorX
    self.wireAnchorY = wireAnchorY

    local wireAnchorBody = love.physics.newBody(world._world, wireAnchorX, wireAnchorY, "static")
    
    local blockerLeftEdgeX = startX - (obj.width / 2)
    self.wireMaxLength = blockerLeftEdgeX - wireAnchorX

    self.wireJoint = love.physics.newRopeJoint(
        wireAnchorBody, 
        self.blocker.body, 
        wireAnchorX, wireAnchorY,            -- Point A: Left wall
        blockerLeftEdgeX, startY,            -- Point B: Left edge of the blocker
        self.wireMaxLength                   -- Max length it is allowed to stretch
    )

    return self
end

function Blocker:update(dt)
    if self.blocker and self.visualLayer then
        local currentX, currentY = self.blocker:getPosition()
        local diffX = currentX - self.blockerStartPosition.x

        local stiffness = 10 
        local forceX = -stiffness * diffX
        self.blocker:applyForce(forceX, 0)

        self.visualLayer.x = diffX
        self.visualLayer.y = currentY - self.blockerStartPosition.y

        local rightEdgeX = currentX + (self.obj.width / 2)
        local springWidth = self.anchorX - rightEdgeX

        if self.springCollider then
            self.springCollider:destroy()
            self.springCollider = nil
        end

        if springWidth > 2 then 
            local centerX = rightEdgeX + (springWidth / 2)
            local springHeight = self.springImage:getHeight()

            self.springCollider = self.world:newCollider("Rectangle", {
                centerX, self.anchorY, springWidth, springHeight
            })
            self.springCollider:setType("static")
        end
    end
end

function Blocker:draw()
    if self.visualLayer then 
        self.gameMap:drawLayer(self.visualLayer) 
    end
    
    if self.blocker and self.springImage then
        local currentX, currentY = self.blocker:getPosition()

        local leftEdgeX = currentX - (self.obj.width / 2)
        local wireDistance = math.abs(leftEdgeX - self.wireAnchorX)
        
        local slack = math.max(0, self.wireMaxLength - wireDistance)
        
        local midX = (self.wireAnchorX + leftEdgeX) / 2
        local midY = self.wireAnchorY + (slack * 1.2)

        local curve = love.math.newBezierCurve(
            self.wireAnchorX, self.wireAnchorY, 
            midX, midY, 
            leftEdgeX, currentY
        )

        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.setLineWidth(3)
        love.graphics.line(curve:render())
        
        love.graphics.setLineWidth(1)
        local rightEdgeX = currentX + (self.obj.width / 2)
        local springDistance = math.abs(self.anchorX - rightEdgeX)
        local originalWidth = self.springImage:getWidth()
        local totalNaturalWidth = originalWidth * self.numSpringCoils
        local scaleX = springDistance / totalNaturalWidth
        
        local drawX = math.min(self.anchorX, rightEdgeX)
        local drawY = self.anchorY
        local originY = self.springImage:getHeight() / 2
        local scaledWidth = originalWidth * scaleX

        love.graphics.setColor(1, 1, 1, 0.5)

        for i = 0, self.numSpringCoils - 1 do
            love.graphics.draw(
                self.springImage, 
                drawX + (i * scaledWidth),
                drawY, 
                0,
                scaleX,
                1,
                0,
                originY
            )
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
end

return Blocker