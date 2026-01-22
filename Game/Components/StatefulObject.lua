local StatefulObject = {}
StatefulObject.__index = StatefulObject

function StatefulObject:new(initialState)
    local obj = setmetatable({}, self)
    obj.states = {}
    obj.current_state_index = nil
    return obj
end
function StatefulObject:addState(stateType, stateValue)
    local state = {
        type = stateType, 
        value = stateValue
    }
    table.insert(self.states, state)
end

function StatefulObject:setState(index)
    if index < 1 or index > #self.states then
        error("Invalid state index: " .. tostring(index))
    end
    self.current_state_index = index
end
