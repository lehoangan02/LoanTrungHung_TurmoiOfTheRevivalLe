local LoadScreen = {}
local instance = nil
local ResizeWindowTransform = require("Game.Custom.ResizeWindowTransform")
local FontLoader = require("Game.Fonts.FontLoader")

function LoadScreen.new(imagePath)
    if instance then
        return instance
    end

    if not imagePath then
        imagePath = "Resources/Images/White_tiger_Hang_Trong.jpg"
    end

    local self = setmetatable({}, {__index = LoadScreen})
    self.backgroundImage = love.graphics.newImage(imagePath)
    self.backgroundImage:setFilter("nearest", "nearest")
    
    self.tasks = {}
    self.currentTaskIndex = 1
    self.isComplete = false
    self.results = {}
    self.coroutine = nil
    self.progress = 0
    self.maxProgress = 0
    self.isDismissed = false
    
    instance = self
    return self
end

function LoadScreen:getInstance()
    if not instance then
        instance = LoadScreen.new()
    end
    return instance
end

function LoadScreen:addTask(taskFunction, progressWeight)
    progressWeight = progressWeight or 1
    table.insert(self.tasks, {
        func = taskFunction,
        weight = progressWeight
    })
    self.maxProgress = self.maxProgress + progressWeight
end

-- Modified LoadScreen:start() method
function LoadScreen:start()
    self.progress = 0
    self.currentTaskIndex = 1
    self.isComplete = false
    self.isDismissed = false
    self.results = {}
    
    self.coroutine = coroutine.create(function()
        local function asyncWait(duration)
            local t = 0
            while t < duration do
                local dt = coroutine.yield("waiting_async")
                t = t + (dt or 0)
            end
        end

        for i, task in ipairs(self.tasks) do
            self.currentTaskIndex = i
            local success, result = pcall(task.func, asyncWait)
            self.results[i] = {success = success, result = result}
            coroutine.yield(task.weight)
        end
    end)
end

function LoadScreen:update(dt)
    if self.isDismissed then
        return
    end
    if self.isComplete then
        return
    end

    if self.coroutine and coroutine.status(self.coroutine) ~= "dead" then
        local ok, result = coroutine.resume(self.coroutine, dt)
        if ok then
            if type(result) == "number" then
                -- Task finished, result is the progress weight
                self.progress = self.progress + result
            elseif result == "waiting_async" then
                -- Task is waiting asynchronously, do nothing
            end
        else
            print("Error in LoadScreen coroutine:", result)
        end
    else
        local TransitionManager = require("Game.Transitions.TransitionManager")
        
        -- The computer loads the level so fast that it finishes before the 
        -- TransitionManager even finishes its 0.7s fade-in! We must wait 
        -- for the entry fade-in to complete before we trigger the fade-out!
        if TransitionManager.isTransitioning then
            return
        end
        
        self.isComplete = true
        
        -- Trigger the mini-wipe transition to dismiss the load screen smoothly
        TransitionManager:start(TransitionManager.type, nil, 0.6, function()
            self.isDismissed = true
        end)
    end
end

function LoadScreen:draw()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    
    -- Draw background image
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.backgroundImage, 0, 0, 0, 
        width / self.backgroundImage:getWidth(),
        height / self.backgroundImage:getHeight())
    
    -- Darken overlay
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, width, height)

    -- Use base-resolution space for bar geometry so it scales nicely
    local scale, fontScale, offsetX, offsetY = ResizeWindowTransform.getTransform(width, height, BASE_W, BASE_H)
    local baseW, baseH = BASE_W, BASE_H

    local barWidth = 160
    local barHeight = 8
    local barBaseX = (baseW - barWidth) / 2
    local barBaseY = baseH / 2

    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", barBaseX, barBaseY, barWidth, barHeight)

    love.graphics.setColor(0.2, 0.8, 0.2)
    local fillWidth = 0
    if self.maxProgress > 0 then
        fillWidth = (self.progress / self.maxProgress) * barWidth
    end
    love.graphics.rectangle("fill", barBaseX, barBaseY, fillWidth, barHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", barBaseX, barBaseY, barWidth, barHeight)

    love.graphics.pop()

    -- Now draw text in window coordinates using fontScale for crisp scaling
    local fontLoader = FontLoader:getInstance()
    local previousFont = love.graphics.getFont()
    local baseFontSize = 12
    local fontSize = math.max(1, math.floor(baseFontSize * fontScale))
    local font = fontLoader:loadFont("Geo", fontSize)
    love.graphics.setFont(font)

    local percentage = 0
    if self.maxProgress > 0 then
        percentage = math.floor((self.progress / self.maxProgress) * 100)
    end

    -- Convert base Y positions into window space so layout stays aligned
    local loadingBaseY = barBaseY - 20
    local percentBaseY = barBaseY + 20
    local taskBaseY = barBaseY + 40

    local loadingY = offsetY + loadingBaseY * scale
    local percentY = offsetY + percentBaseY * scale
    local taskY = offsetY + taskBaseY * scale

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Loading...", 0, loadingY, width, "center")
    love.graphics.printf(percentage .. "%", 0, percentY, width, "center")

    if self.currentTaskIndex <= #self.tasks then
        love.graphics.printf(
            "Task " .. self.currentTaskIndex .. " of " .. #self.tasks,
            0, taskY, width, "center"
        )
    end

    love.graphics.setFont(previousFont)
end

function LoadScreen:getResult(index)
    return self.results[index]
end

function LoadScreen:isDone()
    return self.isDismissed
end

function LoadScreen:reset()
    self.tasks = {}
    self.currentTaskIndex = 1
    self.isComplete = false
    self.results = {}
    self.coroutine = nil
    self.progress = 0
    self.maxProgress = 0
    self.isDismissed = false
end

return LoadScreen

