local TrajectoryVisualization = {}
TrajectoryVisualization.__index = TrajectoryVisualization

local InputManager = require("Game.Input.InputManager")

local LAUNCH_ANGLE_MIN = math.rad(-80)
local LAUNCH_ANGLE_MAX = math.rad(-0)

function TrajectoryVisualization:new(originX, originY, launchSpeed, launchAngle, gravity)
    local instance = setmetatable({}, TrajectoryVisualization)
    instance.originX = originX
    instance.originY = originY
    instance.points = {}
    instance.launchAngle = launchAngle
    instance.launchSpeed = launchSpeed
    instance.gravity = gravity
    instance.vx, instance.vy = math.cos(launchAngle) * launchSpeed, math.sin(launchAngle) * launchSpeed

    for i = 1, 16 do
        local t = i * 0.12
        instance.points[#instance.points + 1] = {
            x = originX + instance.vx * t,
            y = originY + instance.vy * t + 0.5 * gravity * t * t,
        }
    end

    instance.previousCrankVal = InputManager:getCrankValue()
    return instance
end

function TrajectoryVisualization:update(dt)
    local crankVal = InputManager:getCrankValue()
    local diff = crankVal - self.previousCrankVal
    self.launchAngle = self.launchAngle + diff
    self.launchAngle = math.min(LAUNCH_ANGLE_MAX,
        math.max(LAUNCH_ANGLE_MIN, self.launchAngle)
    )
    -- print(self.launchAngle)
    self.vx, self.vy = math.cos(self.launchAngle) * self.launchSpeed, math.sin(self.launchAngle) * self.launchSpeed
    self.points = {}
    for i = 0, 16 do
        local t = i * 0.12
        self.points[#self.points + 1] = {
            x = self.originX + self.vx * t,
            y = self.originY + self.vy * t + 0.5 * self.gravity * t * t,
        }
    end
end

function TrajectoryVisualization:draw(windowWidth, windowHeight)
    love.graphics.push()
    local r, g, b, a = love.graphics.getColor()
    local prevColor = { r=r, g=g, b=b, a=a}
    love.graphics.setColor(0, 0, 0, 0.8)
    for i = 1, #self.points do
        local point = self.points[i]
        love.graphics.circle("fill", point.x, point.y, 2)
    end
    love.graphics.setColor(prevColor.r, prevColor.g, prevColor.b, prevColor.a)
    love.graphics.pop()
end

return TrajectoryVisualization