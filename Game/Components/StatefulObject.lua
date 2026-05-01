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

function StatefulObject:cloneState(index)
    if index < 1 or index > #self.states then
        error("Invalid state index: " .. tostring(index))
    end
    local newState = newEmptyState()
    newState.x = self.states[index].x
    newState.y = self.states[index].y
    newState.interpolationInfo = self.states[index].interpolationInfo
    newState.type = self.states[index].type
    newState.duration = self.states[index].duration
    if newState.type == "sprite" then
        newState.image = self.states[index].image
    else
        newState.animation = self.states[index].animation
        newState.spritesheet = self.states[index].spritesheet
    end
    table.insert(self.states, newState)
    return #self.states
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

function StatefulObject:setInterpolation(interpolationStyle, direction, duration, index)
    if index < 1 or index > #self.states then
        error("Invalid state index: " .. tostring(index))
    end
    if not Algorithm:contains(InterpolationEnum.InterpolationTypeEnum, interpolationStyle) then error("[Stateful Object] Invalid interpolation style! (" .. interpolationStyle ..")") end
    if not Algorithm:contains(InterpolationEnum.InterpolationDirection, direction) then error("[Stateful Object] Invalid interpolation style!") end

    self.states[self.current_state_index].duration = duration

    if direction == InterpolationEnum.InterpolationDirection.InOut then
        self.states[index].interpolationInfo.outDirection = interpolationStyle
        self.states[index].interpolationInfo.inDirection = interpolationStyle
    elseif direction == InterpolationEnum.InterpolationDirection.In then
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
    return #self.states
end

function StatefulObject:addAnimation(animation, spritesheet)
    local state = newEmptyState()
    state.type = "animation"
    state.animation = animation
    state.spritesheet = spritesheet
    table.insert(self.states, state)
    return #self.states
end

function StatefulObject:setState(index)
    if index < 1 or index > #self.states then
        error("Invalid state index: " .. tostring(index))
    end

    local target = self.states[index]
    if not self.current_state_index then
        self.interpolatedX = target.x
        self.interpolatedY = target.y
        self.current_state_index = index
        print("Target pos: " .. tostring(self.interpolatedX) .. " " .. tostring(self.interpolatedY))
        print("HERE")
        return
    end

    if self.current_state_index == index then return end

    local source = self.states[self.current_state_index]
    self.current_state_index = index
    
    local duration = target.duration or 0
    local inStyle = target.interpolationInfo.inDirection or InterpolationEnum.InterpolationTypeEnum.Jump
    local outStyle = source.interpolationInfo.outDirection or InterpolationEnum.InterpolationTypeEnum.Jump

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
        -- print("Elapsed: " ..  tostring(transition.elapsed))
        -- print("Transition duration: " .. tostring(transition.duration))
        local t = math.min(transition.elapsed / transition.duration, 1)
        -- print("t: " .. tostring(t))
        
        if t >= 1 then 
            self.interpolatedX = transition.toX
            self.interpolatedY = transition.toY
            print("Cur pos: " .. tostring(self.interpolatedX) .. " " .. tostring(self.interpolatedY))
            self.transition = nil
        else
            local ease = ComposeEasingFunctions(t, transition.inStyle, transition.outStyle)
            self.interpolatedX = transition.fromX + (transition.toX - transition.fromX) * ease
            self.interpolatedY = transition.fromY + (transition.toY - transition.fromY) * ease
        end
    else
        self.interpolatedX = self.states[self.current_state_index].x
        self.interpolatedY = self.states[self.current_state_index].y
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
    local x = self.interpolatedX or 0
    local y = self.interpolatedY or 0
    -- print("[StatefulObject] Drawing at " .. tostring(x) .. " " .. tostring(y) .. "!")
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