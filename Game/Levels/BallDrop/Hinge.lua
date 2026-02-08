local TiledUtils = require "Game.Custom.TiledUtility"

local Hinge = {}
Hinge.__index = Hinge



function Hinge.new(world, gameMap, layerName)
    local self = setmetatable({}, Hinge)
    self.gameMap = gameMap
    self.machines = {}
    if (gameMap.layers[layerName]) then
        for _, obj in ipairs(gameMap.layers[layerName].objects) do
            if obj.properties.machine_id then
                local id = obj.properties.machine_id
                self.machines[id] = self.machines[id] or { parts = {} }
                table.insert(self.machines[id].parts, obj)
            end
            print(
                "Found hinge part:",
                obj.id,
                "for machine:",
                obj.properties.machine_id
            )
        end
    end

    print("Hinge machines found:", #self.machines)
    local sizePin = self:getMachineBounds(1)

    if self.machines[1] then
        for i, part in ipairs(self.machines[1].parts) do
            print(
                "Machine 1 part",
                i,
                "id:", part.id,
                "x:", part.x,
                "y:", part.y,
                "w:", part.width,
                "h:", part.height,
                "rot:", part.rotation
            )
        end
    end

    print(
        "Pin bounds:",
        sizePin and
        ("x:" .. sizePin.x .. ", y:" .. sizePin.y .. ", w:" .. sizePin.width .. ", h:" .. sizePin.height)
        or "nil"
    )

    local pinCollider
    if sizePin then
        pinCollider = world:newCollider("Rectangle", {sizePin.x + sizePin.width / 2, sizePin.y + sizePin.height / 2, sizePin.width, sizePin.height})
        pinCollider:setType("static")
    end

    local sizeLeaf = self:getMachineBounds(2)
    print(
        "Leaf bounds:",
        sizeLeaf and
        ("x:" .. sizeLeaf.x .. ", y:" .. sizeLeaf.y .. ", w:" .. sizeLeaf.width .. ", h:" .. sizeLeaf.height)
        or "nil"
    )

    if sizeLeaf then
        self.leafCollider = world:newCollider("Rectangle", {sizeLeaf.x + sizeLeaf.width / 2, sizeLeaf.y + sizeLeaf.height / 2, sizeLeaf.width, sizeLeaf.height})
        self.leafCollider:setType("dynamic")
        self.leafCollider:setRestitution(0.9)
    end
    
    if sizePin then
        self.hinge = love.physics.newRevoluteJoint(
            pinCollider:getBody(),
            self.leafCollider:getBody(),
            sizePin.x + sizePin.width,
            sizePin.y + sizePin.height / 2,
            false
        )
    end

    self.hinge:setMotorEnabled(true)
    self.hinge:setMaxMotorTorque(10000)
    self.springK = 140
    self.damping = 0.8

    return self
end

function Hinge:getMachineBounds(machineId)
    local machine = self.machines[machineId]
    if not machine or #machine.parts == 0 then
        return nil
    end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge

    for _, part in ipairs(machine.parts) do
        local x = part.x
        local y = part.y
        local w = part.width or 0
        local h = part.height or 0
        local angle = math.rad(part.rotation or 0)
        local cosA = math.cos(angle)
        local sinA = math.sin(angle)

        local corners = {
            {0, 0},
            {w, 0},
            {w, -h},
            {0, -h}
        }

        for _, c in ipairs(corners) do
            local lx, ly = c[1], c[2]
            local rx = lx * cosA - ly * sinA
            local ry = lx * sinA + ly * cosA
            local wx = x + rx
            local wy = y + ry
            minX = math.min(minX, wx)
            minY = math.min(minY, wy)
            maxX = math.max(maxX, wx)
            maxY = math.max(maxY, wy)
        end
    end

    return {
        x = minX,
        y = minY,
        width = maxX - minX,
        height = maxY - minY
    }
end

function Hinge:update(dt)
    local angle = self.hinge:getJointAngle()
    local angVel = self.hinge:getJointSpeed()

    self.hinge:setMotorSpeed(-self.springK * angle - self.damping * angVel)
end

function Hinge:draw()
    for id, machine in pairs(self.machines) do
        if id == 2 then goto continue end
        for _, part in ipairs(machine.parts) do
            TiledUtils.drawTileObject(self.gameMap, part, love.timer.getTime())
        end
    end
    ::continue::

    print("leafCollider exists:", self.leafCollider ~= nil)
    print("machines[2] exists:", self.machines[2] ~= nil)

    if self.leafCollider and self.machines[2] then
        local x, y = self.leafCollider:getPosition()
        local angle = self.leafCollider:getAngle()
        local sizeLeaf = self:getMachineBounds(2)
        
        local centerX = sizeLeaf.x + sizeLeaf.width / 2
        local centerY = sizeLeaf.y + sizeLeaf.height / 2
        
        for _, part in ipairs(self.machines[2].parts) do
            local offsetX = part.x - centerX
            local offsetY = part.y - centerY
            
            local cosA = math.cos(angle)
            local sinA = math.sin(angle)
            local rotatedX = offsetX * cosA - offsetY * sinA
            local rotatedY = offsetX * sinA + offsetY * cosA
            
            local origX, origY, origRot = part.x, part.y, part.rotation
            part.x = x + rotatedX
            part.y = y + rotatedY
            part.rotation = origRot + math.deg(angle)
            
            TiledUtils.drawTileObject(self.gameMap, part, love.timer.getTime())
            
            part.x, part.y, part.rotation = origX, origY, origRot
        end
    end
end

function Hinge:unload()
end


return Hinge