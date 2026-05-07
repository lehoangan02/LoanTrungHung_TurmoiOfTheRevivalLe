local WinBanner = {}
WinBanner.__index = WinBanner

local FontLoader = require("Game.Fonts.FontLoader")

function WinBanner.new(imagePath, text, x, y)
    local self = setmetatable({}, WinBanner)
    self.image = love.graphics.newImage(imagePath)
    self.image:setFilter("nearest", "nearest")
    self.text = text
    
    self.x = x or BASE_W / 2
    self.y = y or BASE_H / 2
    
    self.active = false
    self.timer = 0
    self.duration = 0.5 -- How long the pop animation lasts
    self.fontSize = 28
    self.textOffsetY = -5
    
    return self
end

function WinBanner:trigger()
    self.active = true
    self.timer = 0 -- Reset timer to replay the animation
end

-- The magic function for the "pop and settle" smooth effect
local function easeOutBack(t)
    local s = 1.70158
    t = t - 1
    return (t * t * ((s + 1) * t + s) + 1)
end

function WinBanner:update(dt)
    if self.active and self.timer < self.duration then
        self.timer = self.timer + dt
        if self.timer > self.duration then
            self.timer = self.duration
        end
    end
end

function WinBanner:draw(scale, fontScale, offsetX, offsetY)
    if not self.active then return end
    
    -- Calculate how far along the animation is (0 to 1)
    local progress = self.timer / self.duration
    -- Apply the spring easing to the progress to get our scale
    local animScale = easeOutBack(progress)
    
    local imgW = self.image:getWidth()
    local imgH = self.image:getHeight()
    
    -- We temporarily cancel the global scale to draw the text crisply
    love.graphics.push()
    love.graphics.scale(1/scale, 1/scale)
    
    -- 1. Draw Image
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.translate(self.x, self.y)
    love.graphics.scale(animScale, animScale)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image, -imgW/2, -imgH/2)
    love.graphics.pop()
    
    -- 2. Draw Text
    love.graphics.push()
    local previousFont = love.graphics.getFont()
    local textScale = scale
    
    self.font = FontLoader:loadFont("Geo", self.fontSize * fontScale)
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 1) -- Black text color
    
    local textW = self.font:getWidth(self.text)
    
    -- Calculate precise vertical center using font metrics instead of just line height
    local baseline = self.font:getBaseline()
    local ascent = self.font:getAscent()
    local descent = self.font:getDescent()
    
    -- The visual center of the text is exactly halfway between the top (ascent) and bottom (descent)
    local textVisualCenterY = baseline - (ascent - descent) / 2
    
    -- Translate to the correct physical location (including our -2 logical offset), then apply the bounce scale
    love.graphics.translate(self.x * textScale, (self.y + self.textOffsetY) * textScale)
    love.graphics.scale(animScale, animScale)
    
    love.graphics.print(self.text, math.floor(-textW/2), math.floor(-textVisualCenterY))
    
    love.graphics.setFont(previousFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
    
    love.graphics.pop()
end

return WinBanner
