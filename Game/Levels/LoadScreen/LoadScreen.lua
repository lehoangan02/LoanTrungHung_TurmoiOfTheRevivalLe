local LoadScreen = {}
local instance = nil

function LoadScreen.new(imagePath)
    if instance then
        return instance
    end

    if not imagePath then
        imagePath = "Resources/Images/White_tiger_Hang_Trong.jpg"
    end

    local self = setmetatable({}, {__index = LoadScreen})
    self.backgroundImage = love.graphics.newImage(imagePath)
    
    self.tasks = {}
    self.currentTaskIndex = 1
    self.isComplete = false
    self.results = {}
    self.coroutine = nil
    self.progress = 0
    self.maxProgress = 0
    
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
    self.results = {}
    
    self.coroutine = coroutine.create(function()
        for i, task in ipairs(self.tasks) do
            self.currentTaskIndex = i
            local success, result = pcall(task.func)
            self.results[i] = {success = success, result = result}
            coroutine.yield(task.weight)
        end
    end)
end

function LoadScreen:update(dt)
    if self.isComplete then
        return
    end
    if self.coroutine and coroutine.status(self.coroutine) ~= "dead" then
        local ok, progress = coroutine.resume(self.coroutine)
        if ok and progress then
            self.progress = self.progress + progress
        end
        
        if not ok then
            print("Error in LoadScreen coroutine:", progress)
        end
    else
        self.isComplete = true
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
    
    -- Loading text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Loading...", 0, height / 2 - 20, width, "center")
    
    -- Progress bar
    local barWidth = 200
    local barHeight = 10
    local x = (width - barWidth) / 2
    local y = height / 2
    
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)
    
    love.graphics.setColor(0.2, 0.8, 0.2)
    local fillWidth = (self.progress / self.maxProgress) * barWidth
    love.graphics.rectangle("fill", x, y, fillWidth, barHeight)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, barWidth, barHeight)
    
    -- Percentage
    local percentage = math.floor((self.progress / self.maxProgress) * 100)
    love.graphics.printf(percentage .. "%", 0, y + 40, width, "center")
    
    -- Current task
    if self.currentTaskIndex <= #self.tasks then
        love.graphics.printf(
            "Task " .. self.currentTaskIndex .. " of " .. #self.tasks,
            0, y + 70, width, "center"
        )
    end
end

function LoadScreen:getResult(index)
    return self.results[index]
end

function LoadScreen:isDone()
    return self.isComplete
end

function LoadScreen:reset()
    self.tasks = {}
    self.currentTaskIndex = 1
    self.isComplete = false
    self.results = {}
    self.coroutine = nil
    self.progress = 0
    self.maxProgress = 0
end

return LoadScreen

