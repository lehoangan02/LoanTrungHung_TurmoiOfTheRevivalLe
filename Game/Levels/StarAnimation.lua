local StarActivateAnimation = {}

function StarActivateAnimation.new()
    local instance = setmetatable({}, {__index = StarActivateAnimation})
    instance.collected = false
    instance.anim8 = require "Game/Libraries/anim8"
    instance.animationSpriteSheet = love.graphics.newImage("Resources/Images/star_explode.png")
    instance.grid = instance.anim8.newGrid(32, 32, instance.animationSpriteSheet:getWidth(), instance.animationSpriteSheet:getHeight())
    instance.jobList = {}
    return instance
end

function StarActivateAnimation:play(x, y)
    table.insert(self.jobList, {x = x, y = y, animation = self.anim8.newAnimation(self.grid('1-4', 1), 0.1, 'pauseAtEnd')})
    print("Playing star animation at:", x, y)
end

function StarActivateAnimation:update(dt)
    for i, job in ipairs(self.jobList) do
        job.animation:update(dt)
        if job.animation.position == 'end' then
            table.remove(self.jobList, i)
        end
    end    
end

function StarActivateAnimation:draw()
    for i, job in ipairs(self.jobList) do
        if job.animation.status ~= 'paused' then
            job.animation:draw(self.animationSpriteSheet, job.x, job.y, 0, 1, 1, 16, 16)
        end
    end
end

return StarActivateAnimation