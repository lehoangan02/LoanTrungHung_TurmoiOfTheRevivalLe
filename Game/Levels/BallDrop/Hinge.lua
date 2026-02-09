local Hinge = {}
Hinge.__index = Hinge

local bit = require("bit")

function Hinge.new(world, gameMap, layerName, pinID, leafID, maxMotorTorque, springK, damping)
    local self = setmetatable({}, Hinge)
    self.gameMap = gameMap
    self.pinID = pinID
    self.leafID = leafID
    self.machines = {}
    
    if (gameMap.layers[layerName]) then
        for _, obj in ipairs(gameMap.layers[layerName].objects) do
            if obj.properties.machine_id then
                local id = obj.properties.machine_id
                if id == pinID or id == leafID then
                    self.machines[id] = self.machines[id] or { parts = {} }
                    table.insert(self.machines[id].parts, obj)
                end
            end
        end
    end

    local pinBounds = self:getMachineBounds(pinID)
    if pinBounds then
        local centerX = pinBounds.x + pinBounds.width / 2
        local centerY = pinBounds.y + pinBounds.height / 2
        
        self.pinCollider = world:newCollider("Rectangle", {centerX, centerY, pinBounds.width, pinBounds.height})
        self.pinCollider:setType("static")
        
        self.pinCanvas = self:bakeMachineToCanvas(pinID, pinBounds)
        self.pinWidth = pinBounds.width
        self.pinHeight = pinBounds.height
    end

    local leafBounds = self:getMachineBounds(leafID)
    if leafBounds then
        local centerX = leafBounds.x + leafBounds.width / 2
        local centerY = leafBounds.y + leafBounds.height / 2
        
        self.leafCollider = world:newCollider("Rectangle", {centerX, centerY, leafBounds.width, leafBounds.height})
        self.leafCollider:setType("dynamic")
        self.leafCollider:setRestitution(0.9)

        self.leafCanvas = self:bakeMachineToCanvas(leafID, leafBounds)
        self.leafWidth = leafBounds.width
        self.leafHeight = leafBounds.height
    end
    
    if pinBounds and leafBounds then
        local anchorX
        local pinCenter = pinBounds.x + pinBounds.width / 2
        local leafCenter = leafBounds.x + leafBounds.width / 2

        if leafCenter < pinCenter then
            anchorX = pinBounds.x 
        else
            anchorX = pinBounds.x + pinBounds.width
        end

        self.hinge = love.physics.newRevoluteJoint(
            self.pinCollider:getBody(),
            self.leafCollider:getBody(),
            anchorX,
            pinBounds.y + pinBounds.height / 2,
            false
        )
        self.hinge:setMotorEnabled(true)
        self.hinge:setMaxMotorTorque(maxMotorTorque)
        self.springK = springK
        self.damping = damping
    end

    return self
end

function Hinge:bakeMachineToCanvas(machineID, bounds)
    if not self.machines[machineID] then return nil end
    
    local w = math.ceil(bounds.width)
    local h = math.ceil(bounds.height)
    local canvas = love.graphics.newCanvas(w, h)
    
    canvas:setFilter("nearest", "nearest")
    
    love.graphics.push()
    love.graphics.origin()
    
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0,0,0,0)
    love.graphics.setColor(1,1,1,1)

    love.graphics.translate(-bounds.x, -bounds.y)

    for _, part in ipairs(self.machines[machineID].parts) do
        local gid = part.gid
        
        local cleanGid = bit.band(gid, 0x1FFFFFFF)

        local tile = self.gameMap.tiles[cleanGid]

        if tile then
            local image = tile.image
            if not image and tile.tileset then
                local tileset = self.gameMap.tilesets[tile.tileset]
                if tileset then
                    image = tileset.image
                end
            end

            if image then
                local r = math.rad(part.rotation or 0)
                
                local ox = 0
                local oy = tile.height
                
                love.graphics.draw(image, tile.quad, part.x, part.y, r, 1, 1, ox, oy)
            else
                print("Warning: Hinge part " .. part.id .. " has no texture.")
            end
        end
    end

    love.graphics.setCanvas()
    love.graphics.pop()
    
    return canvas
end

function Hinge:getMachineBounds(machineId)
    local machine = self.machines[machineId]
    if not machine or #machine.parts == 0 then return nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge

    for _, part in ipairs(machine.parts) do
        local x, y = part.x, part.y
        local w = part.width or 0
        local h = part.height or 0
        local angle = math.rad(part.rotation or 0)
        local c = math.cos(angle)
        local s = math.sin(angle)

        local corners = {
            {0, 0},
            {w, 0},
            {w, -h},
            {0, -h}
        }

        for _, corn in ipairs(corners) do
            local rx = corn[1] * c - corn[2] * s
            local ry = corn[1] * s + corn[2] * c
            local wx = x + rx
            local wy = y + ry

            minX = math.min(minX, wx)
            minY = math.min(minY, wy)
            maxX = math.max(maxX, wx)
            maxY = math.max(maxY, wy)
        end
    end

    return {
        x = minX, y = minY,
        width = maxX - minX, height = maxY - minY
    }
end

function Hinge:update(dt)
    if self.hinge then
        local angle = self.hinge:getJointAngle()
        local angVel = self.hinge:getJointSpeed()
        self.hinge:setMotorSpeed(-self.springK * angle - self.damping * angVel)
    end
end

function Hinge:draw()
    love.graphics.setColor(1, 1, 1, 1)

    if self.pinCanvas and self.pinCollider then
        local x, y = self.pinCollider:getPosition()
        local r = self.pinCollider:getAngle()
        love.graphics.draw(self.pinCanvas, x, y, r, 1, 1, self.pinWidth/2, self.pinHeight/2)
    end

    if self.leafCanvas and self.leafCollider then
        local x, y = self.leafCollider:getPosition()
        local r = self.leafCollider:getAngle()
        love.graphics.draw(self.leafCanvas, x, y, r, 1, 1, self.leafWidth/2, self.leafHeight/2)
    end
end

function Hinge:unload()
    if self.pinCanvas then self.pinCanvas:release() end
    if self.leafCanvas then self.leafCanvas:release() end
end

return Hinge