local InterpolationEnum = require("Game.Custom.InterpolationEnum")
local Algorithm = require("Game.Custom.Algorithm")

local StatefulObject = {}
StatefulObject.__index = StatefulObject

local function newEmptyState()
    return {
        x = 0, y = 0,
        duration = 0,
        interpolation = false,
        interpolationInfo = { inDirection = nil, outDirection = nil }
    }
end

function StatefulObject:new()
    local obj = setmetatable({}, self)
    obj.states = {}
    obj.current_state_index = nil
    obj.interpolatedX = 0
    obj.interpolatedY = 0
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

function StatefulObject:_isInterpolationValid()
    for i, state in ipairs(self.states) do
        if state.interpolation then
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
        else
            error("No interpolation info")
        end

        if not state.x or not state.y then
            error("No position set for state: ", i)
        end
    end
end

function StatefulObject:setInterpolation(interpolationStyle, direction, index)
    if index < 1 or index > #self.states then
        error("Invalid state index: " .. tostring(index))
    end
    if not Algorithm:contains(InterpolationEnum.StatefulObjectInterpolationTypeEnum, interpolationStyle) then error("[Stateful Object] Invalid interpolation style!") end
    if not Algorithm:contains(InterpolationEnum.StatefulObjectInterpolationDirection, direction) then error("[Stateful Object] Invalid interpolation style!") end

    if direction == InterpolationEnum.StatefulObjectInterpolationDirection.InOut then
        self.states[index].interpolationInfo.outDirection = interpolationStyle
        self.states[index].interpolationInfo.inDirection = interpolationStyle
    elseif direction == InterpolationEnum.StatefulObjectInterpolationDirection.In then
        self.states[index].interpolationInfo.inDirection = interpolationStyle
    else
        self.states[index].interpolationInfo.outDirection = interpolationStyle
    end
end

function StatefulObject:addSprite(image)
    local state = newEmptyState()
    state.type = "sprite"
    state.image = image
    table.insert(self.states, state)
end

function StatefulObject:addAnimation(animation, spritesheet)
    local state = newEmptyState()
    state.type = "animation"
    state.animation = animation
    state.spritesheet = spritesheet
    table.insert(self.states, state)
end

function StatefulObject:setState(index)
    if index < 1 or index > #self.states then
        error("Invalid state index: " .. tostring(index))
    end
    self.current_state_index = index

    if self.current_state_index == index then return end

    local source = self.states[self.current_state_index]
    local target = self.states[index]

    local duration = target.duration or 0
    local inStyle = target.interpolationInfo.inDirection or InterpolationEnum.InterpolationTypeEnum.Jump
    local outStyle = target.interpolationInfo.outDirection or InterpolationEnum.InterpolationTypeEnum.Jump

    self.transition = {
        fromX = self.interpolatedX,
        fromY = self.interpolatedY,
        toX = target.x,
        toY = target.y,
        duration = duration,
        elapsed = 0,
        inStyle = inStyle,
        outStyle = outStyle,
    }
end

function StatefulObject:update(dt)
    if not self.current_state_index then
        error("Current state is not set.")
    end
    local currentState = self.states[self.current_state_index]
    if currentState.type == "animation" then
        currentState.animation:update(dt)
    end

    if self:isTransitioning() then
        local transition = self.transition
        transition.elapsed = transition.elapsed + dt
        local t = math.min(transition.elapsed / transition.duration, 1)
        
        if t >= 1 then 
            self.interpolatedX = transition.toX
            self.interpolatedY = transition.toY
            self.transition = nil
        else
            local ease = ComposeEasingFunctions(t, currentState.interpolationInfo.inStyle, transition.target.interpolationInfo.outStyle)
            currentState.interpolatedX = transition.fromX + (transition.toX - transition.fromX) * ease 
            currentState.interpolatedX = transition.fromX + (transition.toX - transition.fromX) * ease
        end
    else
        self.interpolatedX = self.x
        self.interpolatedY = self.y
    end
end

function StatefulObject:isTransitioning()
    if self.transition then return true
    else return false
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

function StatefulObject:drawAutonomously()
    local currentState = self.states[self.current_state_index]
    local x = currentState.interpolatedX or 0
    local y = currentState.interpolatedY or 0
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