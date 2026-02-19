local Blocker = {}

Blocker.__index = Blocker

function Blocker.new(world, gameMap, visualLayerName, colliderLayerName, machineID)
    local self = setmetatable({}, Blocker)
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

    if obj then
        local startX = obj.x + obj.width / 2
        local startY = obj.y + obj.height / 2

        self.blocker = world:newCollider("Rectangle", {
                startX, startY, obj.width, obj.height - 1
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
    end
end

function Blocker:draw()
    if self.visualLayer then 
        self.gameMap:drawLayer(self.visualLayer) 
    end
end

return Blocker