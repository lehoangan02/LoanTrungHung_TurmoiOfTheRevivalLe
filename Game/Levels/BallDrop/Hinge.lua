local Hinge = {}
Hinge.__index = Hinge

machines = {}

function Hinge.new(world, gameMap, layerName)
    if (gameMap.layers[layerName]) then
        for _, obj in ipairs(gameMap.layers[layerName].objects) do
            if obj.properties.machine_id then
                local id = obj.properties.machine_id
                machines[id] = machines[id] or {parts = {}}
            end
        end
    end
end


return Hinge