local StatefulObject = {}
StatefulObject.__index = StatefulObject

function StatefulObject:new(initialState)
    local obj = setmetatable({}, self)
    obj.states = {}
    obj.current_state_index = nil
    return obj
end

function StatefulObject:addSprite(image)
    table.insert(self.states, {
        type = "sprite",
        image = image
    })
end

function StatefulObject:addAnimation(animation, spritesheet)
    table.insert(self.states, {
        type = "animation",
        animation = animation,
        spritesheet = spritesheet
    })
end

function StatefulObject:setState(index)
    if index < 1 or index > #self.states then
        error("Invalid state index: " .. tostring(index))
    end
    self.current_state_index = index
end

function StatefulObject:update(dt)
    if not self.current_state_index then
        error("Current state is not set.")
    end
    local currentState = self.states[self.current_state_index]
    if currentState.type == "animation" then
        currentState.animation:update(dt)
    end
end

function StatefulObject:draw(x, y)
    if not self.current_state_index then
        error("Current state is not set.")
    end
    local currentState = self.states[self.current_state_index]
    if currentState.type == "sprite" then
        love.graphics.draw(currentState.image, x, y)
    elseif currentState.type == "animation" then
        currentState.animation:draw(currentState.spritesheet, x, y)
    else
        error("Unknown state type: " .. tostring(currentState.type))
    end
end

function StatefulObject:getCurrentAnimation()
    if not self.current_state_index then
        error("Current state is not set.")
    end
    local currentState = self.states[self.current_state_index]
    if currentState.type == "animation" then
        return currentState.animation
    else
        return nil
    end
end

function StatefulObject:getCurrentSprite()
    if not self.current_state_index then
        error("Current state is not set.")
    end
    local currentState = self.states[self.current_state_index]
    if currentState.type == "sprite" then
        return currentState.image
    else
        return nil
    end
end

return StatefulObject