local StatefulObjectEnum = require("Game.Components.StatefulObjectEnum")
local Algorithm = require("Game.Custom.Algorithm")

local StatefulObject = {}
StatefulObject.__index = StatefulObject

function StatefulObject:new()
    local obj = setmetatable({}, self)
    obj.states = {}
    obj.current_state_index = nil
    return obj
end

function StatefulObject:setPosition(x, y, index) 
    if index < 1 or index > #self.states then
        error("Invalid state index: " .. tostring(index))
    end
    local state = self.states[index]
    state.x = x
    state.y = y
end

-- INCOMPLETE
function StatefulObject:_fillMissingInterpolationData()
    for _, state in ipairs(self.states) do
        if not state.interpolation then
            
        end
    end
end

-- INCOMPLETE
function StatefulObject:_isInterpolationValid()
    for _, state in ipairs(self.states) do
        if state.interpolation then
            for i, state in ipairs(self.states) do
                if i > 1 and i < #self.states then
                    if not state.interpolationInfo.inDirection then
                        error("Interpolation of direction " ..  "in " .. "was not set at state index: " .. tostring(i))
                    end

                    if not state.interpolationInfo.outDirection then
                        error("Interpolation of direction " ..  "out " .. "was not set at state index: " .. tostring(i))
                    end
                elseif i == 1 then
                    if not state.interpolationInfo.outDirection then
                        error("Interpolation of direction " ..  "out " .. "was not set at state index: " .. tostring(i))
                    end
                elseif i == #self.states then
                    if not state.interpolationInfo.inDirection then
                        error("Interpolation of direction " ..  "in " .. "was not set at state index: " .. tostring(i))
                    end
                end
            end
        end
    end
end

-- INCOMPLETE
function StatefulObject:setInterpolation(interpolationStyle, direction, index)
    if index < 1 or index > #self.states then
        error("Invalid state index: " .. tostring(index))
    end
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

function StatefulObject:draw()
    local currentState = self.states[self.current_state_index]
    local x = currentState.x or 0
    local y = currentState.y or 0
    self:draw(x, y)
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