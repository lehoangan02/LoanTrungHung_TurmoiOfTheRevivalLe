local TransitionManager = {}

TransitionManager.isTransitioning = false
TransitionManager.state = "none" -- "out", "in"
TransitionManager.type = "grid" -- "slide_up", "fade", "grid"
TransitionManager.timer = 0
TransitionManager.duration = 1 -- duration for half transition (out or in)
TransitionManager.nextLevel = nil
TransitionManager.onOutComplete = nil

function TransitionManager:start(type, nextLevel, duration, onOutComplete)
    self.type = type or "grid"
    self.nextLevel = nextLevel
    self.duration = duration or 0.8
    self.onOutComplete = onOutComplete
    self.isTransitioning = true
    self.state = "out"
    self.timer = 0
end

local function easeOutCubic(t)
    t = t - 1
    return t * t * t + 1
end

function TransitionManager:update(dt)
    if not self.isTransitioning then return end
    
    self.timer = self.timer + dt
    if self.timer >= self.duration then
        if self.state == "out" then
            self.state = "in"
            self.timer = 0
            if self.onOutComplete then
                self.onOutComplete(self.nextLevel)
            end
        else
            self.isTransitioning = false
            self.state = "none"
        end
    end
end

function TransitionManager:draw(windowWidth, windowHeight)
    if not self.isTransitioning then return end
    
    local progress = self.timer / self.duration
    
    if self.type == "slide_up" then
        love.graphics.setColor(0, 0, 0, 1)
        local y = 0
        local p = easeOutCubic(progress)
        if self.state == "out" then
            y = windowHeight - (windowHeight * p)
        else
            y = -(windowHeight * p)
        end
        love.graphics.rectangle("fill", 0, y, windowWidth, windowHeight)
        love.graphics.setColor(1, 1, 1, 1)
        
    elseif self.type == "fade" then
        local alpha = 0
        if self.state == "out" then
            alpha = progress
        else
            alpha = 1 - progress
        end
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", 0, 0, windowWidth, windowHeight)
        love.graphics.setColor(1, 1, 1, 1)
        
    elseif self.type == "grid" then
        love.graphics.setColor(0, 0, 0, 1)
        local rows = 12
        local cols = 12
        local cellW = math.ceil(windowWidth / cols)
        local cellH = math.ceil(windowHeight / rows)
        
        local maxDelay = 0.6
        local cellDuration = 0.4
        local maxDist = (rows - 1) + (cols - 1)
        
        for r = 1, rows do
            for c = 1, cols do
                local dist = (r - 1) + (c - 1)
                local baseDelay = (dist / maxDist) * (maxDelay * 0.7)
                
                -- Odd coordinates fade sooner, even fade later
                local isOdd = (r % 2 ~= 0) and (c % 2 ~= 0)
                local isEven = (r % 2 == 0) and (c % 2 == 0)
                
                if isOdd then
                    baseDelay = baseDelay - 0.1
                elseif isEven then
                    baseDelay = baseDelay + 0.1
                end
                
                local delay = math.max(0, math.min(maxDelay, baseDelay))
                
                local cellProgress = 0
                if progress > delay then
                    cellProgress = (progress - delay) / cellDuration
                    cellProgress = math.min(1, cellProgress)
                end
                
                local size = 0
                if self.state == "out" then
                    size = easeOutCubic(cellProgress)
                else
                    size = 1 - easeOutCubic(cellProgress)
                end
                
                if size > 0 then
                    local w = cellW * size
                    local h = cellH * size
                    local cx = (c - 1) * cellW + cellW / 2
                    local cy = (r - 1) * cellH + cellH / 2
                    
                    -- add 1 pixel buffer to prevent subpixel seams
                    love.graphics.rectangle("fill", cx - w/2 - 0.5, cy - h/2 - 0.5, w + 1, h + 1)
                end
            end
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return TransitionManager
