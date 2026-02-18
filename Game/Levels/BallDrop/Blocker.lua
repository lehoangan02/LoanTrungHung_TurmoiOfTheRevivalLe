local Blocker = {}

Blocker.__index = Blocker
function Blocker.new(world, gameMap, layerName, machineID)
    local self = setmetatable({}, Blocker)
    self.gameMap = gameMap
    local layer = gameMap.layers[layerName]
    if not layer then return self end
    if not layer.objects then return self end
    local obj = layer.objects[1]

    if obj then
        local startX = obj.x + obj.width / 2
        local startY = obj.y + obj.height / 2

        self.blocker = world:newCollider("Rectangle", {
                startX, startY, obj.width, obj.height
            })

        self.blocker:setType("dynamic")
        self.blocker:setFixedRotation(true)
        self.blocker:setRestitution(0)

        local anchor = love.physics.newBody(world.world, startX, startY, "static")

        local joint = love.physics.newPrismaticJoint(
            anchor,
            self.blocker.body,
            startX, startY,
            1, 0
        )
        
        self.blockerStartPosition = {x = startX, y = startY}
    end
    return self
end

function Blocker:update(dt)
    if self.blocker then
        local currentX, currentY = self.blocker:getPosition()

        local diffX = currentX - self.blockerStartPosition.x
        local diffY = currentY - self.blockerStartPosition.y

        self.gameMap.layers["Blocker"].x = diffX
        self.gameMap.layers["Blocker"].y = diffY
    end
end

function Blocker:draw()
    if self.gameMap.layers["Blocker"] then self.gameMap:drawLayer(self.gameMap.layers["Blocker"]) end
end

return Blocker