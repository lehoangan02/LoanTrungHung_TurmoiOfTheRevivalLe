local Blocker = {}

Blocker.__index = Blocker

function Blocker.new(world, gameMap, visualLayerName, colliderLayerName, machineID)
    local self = setmetatable({}, Blocker)
    self.gameMap = gameMap
    self.world = world 
    self.machineID = machineID or 1
    
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
        self.blocker.fixture:setGroupIndex(-self.machineID)

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
        wireAnchorX, wireAnchorY,
        blockerLeftEdgeX, startY,
        self.wireMaxLength
    )

    self.springBody = love.physics.newBody(world._world, 0, 0, "static")

    self.isWireCut = false

    return self
end

function Blocker:cutWire(x, y)
    if self.isWireCut then return end
    self.isWireCut = true
    
    if self.wireJoint then
        self.wireJoint:destroy()
        self.wireJoint = nil
    end
    
    local currentX, currentY = self.blocker:getPosition()
    local leftEdgeX = currentX - (self.obj.width / 2)
    
    local function buildRope(x1, y1, x2, y2)
        local rope = {nodes = {}}
        local dist = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
        local numSegments = math.max(3, math.floor(dist / 5))
        rope.segLen = dist / numSegments
        
        for i = 0, numSegments do
            local t = i / numSegments
            local nx = x1 + (x2 - x1) * t
            local ny = y1 + (y2 - y1) * t
            table.insert(rope.nodes, {x = nx, y = ny, oldx = nx, oldy = ny})
        end
        return rope
    end
    
    self.rope1 = buildRope(self.wireAnchorX, self.wireAnchorY, x, y)
    self.rope2 = buildRope(leftEdgeX, currentY, x, y)
end

function Blocker:update(dt)
    if self.blocker and self.visualLayer then
        local currentX, currentY = self.blocker:getPosition()
        local diffX = currentX - self.blockerStartPosition.x
        local velX, _ = self.blocker:getLinearVelocity()

        local stiffness = 2.1
        local damping = 1
        local forceX = -stiffness * diffX - damping * velX
        self.blocker:applyForce(forceX, 0)

        self.visualLayer.x = diffX
        self.visualLayer.y = currentY - self.blockerStartPosition.y

        local rightEdgeX = currentX + (self.obj.width / 2)
        local springWidth = self.anchorX - rightEdgeX

        if self.springFixture then
            self.springFixture:destroy()
            self.springFixture = nil
        end

        if springWidth > 2 then 
            local centerX = rightEdgeX + (springWidth / 2)
            local springHeight = self.springImage:getHeight()

            local shape = love.physics.newRectangleShape(centerX, self.anchorY, springWidth, springHeight)
            self.springFixture = love.physics.newFixture(self.springBody, shape)
            self.springFixture:setGroupIndex(-self.machineID)
        end

        if self.isWireCut then
            -- Fetch the dynamic rotating gravity directly from the Box2D world
            local gx, gy = self.world._world:getGravity()
            
            -- We scale it up purely for the visual ropes because standard Box2D
            -- physics gravity often makes non-physical Verlet ropes look like they are floating underwater.
            local visualGravityScale = 4
            gx = gx * visualGravityScale
            gy = gy * visualGravityScale

            local dtSq = dt * dt
            
            local function updateRope(rope, anchorX, anchorY)
                for i = 1, #rope.nodes do
                    local p = rope.nodes[i]
                    local vx = (p.x - p.oldx) * 0.99
                    local vy = (p.y - p.oldy) * 0.99
                    p.oldx = p.x
                    p.oldy = p.y
                    -- Apply gravity scaled by both the X and Y axes
                    p.x = p.x + vx + gx * dtSq
                    p.y = p.y + vy + gy * dtSq
                end
                
                for iter = 1, 15 do
                    rope.nodes[1].x = anchorX
                    rope.nodes[1].y = anchorY
                    
                    for i = 1, #rope.nodes - 1 do
                        local p1 = rope.nodes[i]
                        local p2 = rope.nodes[i+1]
                        local dx = p2.x - p1.x
                        local dy = p2.y - p1.y
                        local dist = math.sqrt(dx * dx + dy * dy)
                        
                        if dist > 0 then
                            local diff = (dist - rope.segLen) / dist
                            local offsetX = dx * diff * 0.5
                            local offsetY = dy * diff * 0.5
                            
                            if i > 1 then
                                p1.x = p1.x + offsetX
                                p1.y = p1.y + offsetY
                            end
                            p2.x = p2.x - offsetX
                            p2.y = p2.y - offsetY
                        end
                    end
                end
            end

            updateRope(self.rope1, self.wireAnchorX, self.wireAnchorY)
            local leftEdgeX = currentX - (self.obj.width / 2)
            updateRope(self.rope2, leftEdgeX, currentY)
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

        love.graphics.setColor(0.2, 0.2, 0.2, 1)
        love.graphics.setLineWidth(3)

        if not self.isWireCut then
            local wireDistance = math.abs(leftEdgeX - self.wireAnchorX)
            local slack = math.max(0, self.wireMaxLength - wireDistance)
            
            local midX = (self.wireAnchorX + leftEdgeX) / 2
            local midY = self.wireAnchorY + (slack * 1.2)

            local curve = love.math.newBezierCurve(
                self.wireAnchorX, self.wireAnchorY, 
                midX, midY, 
                leftEdgeX, currentY
            )

            love.graphics.line(curve:render())
        else
            local function drawRope(rope)
                for i = 1, #rope.nodes - 1 do
                    love.graphics.line(rope.nodes[i].x, rope.nodes[i].y, rope.nodes[i+1].x, rope.nodes[i+1].y)
                end
            end
            drawRope(self.rope1)
            drawRope(self.rope2)
        end
        
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