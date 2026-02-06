local Hinge = {}
Hinge.__index = Hinge



function Hinge.new(world, gameMap, layerName)
    local self = setmetatable({}, Hinge)
    self.gameMap = gameMap
    if (gameMap.layers[layerName]) then
        for _, obj in ipairs(gameMap.layers[layerName].objects) do
            if obj.properties.machine_id then
                local id = obj.properties.machine_id
                machines[id] = machines[id] or {parts = {}}
            end
        end
    end

    return self
end

function Hinge:update(dt)
end

function Hinge:draw()
    for id, machine in pairs(machines) do
        for _, part in ipairs(machine.parts) do
            self.gameMap:drawObject(part)
        end
    end
end

function Hinge:unload()
end


return Hinge