local UIElement = require("Game.UI.UIElement")
local FontLoader = require("Game.Fonts.FontLoader")

local WinBanner = setmetatable({}, {__index = UIElement})
WinBanner.__index = WinBanner

function WinBanner.new(imagePath, text, x, y)
    local self = setmetatable(UIElement:new(x or BASE_W / 2, y or BASE_H / 2, 0, 0), WinBanner)
    
    self.image = love.graphics.newImage(imagePath)
    self.image:setFilter("nearest", "nearest")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    
    self.text = text
    
    self.active = false
    self.timer = 0
    self.duration = 0.5 -- How long the pop animation lasts
    self.fontSize = 28
    self.textOffsetY = -5
    
    -- Global offset that moves the entire banner, text, and children up or down
    self.verticalOffset = -40
    
    -- List of UI Elements held by this banner (like buttons or layouts)
    self.children = {}
    
    return self
end

function WinBanner:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Adds a UIElement (e.g. TextButton) to the banner.
-- localX and localY are relative to the center of the banner.
function WinBanner:addChild(element, localX, localY)
    element:setPosition(localX or 0, localY or 0)
    table.insert(self.children, element)
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
    if not self.active then return end

    if self.timer < self.duration then
        self.timer = self.timer + dt
        if self.timer > self.duration then
            self.timer = self.duration
        end
    end
    
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

function WinBanner:draw(scale, fontScale, offsetX, offsetY)
    if not self.active then return end
    
    -- In case it is called from a layout without fontScale
    fontScale = fontScale or scale
    
    -- Calculate how far along the animation is (0 to 1)
    local progress = self.timer / self.duration
    -- Apply the spring easing to the progress to get our scale
    local animScale = easeOutBack(progress)
    
    local imgW = self.width
    local imgH = self.height
    
    -- We temporarily cancel the global scale to draw things crisp
    love.graphics.push()
    love.graphics.scale(1/scale, 1/scale)
    
    -- 1. Draw Image and Children
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.translate(self.x, self.y + self.verticalOffset)
    love.graphics.scale(animScale, animScale)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image, -imgW/2, -imgH/2)
    
    -- Draw children (relative to center, bouncing together with the banner)
    -- We pass animScale as 1 because we are already scaled
    for _, child in ipairs(self.children) do
        child:draw(1, 0, 0)
    end
    
    love.graphics.pop()
    
    -- 2. Draw Text (crisply without nested scaling artifacts)
    love.graphics.push()
    local previousFont = love.graphics.getFont()
    local textScale = scale
    
    self.font = FontLoader:loadFont("Geo", self.fontSize * fontScale)
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 1) -- Black text color
    
    local textW = self.font:getWidth(self.text)
    
    -- Calculate precise vertical center using font metrics
    local baseline = self.font:getBaseline()
    local ascent = self.font:getAscent()
    local descent = self.font:getDescent()
    local textVisualCenterY = baseline - (ascent - descent) / 2
    
    -- Translate to physical location (including logical offsets), then apply bounce scale
    love.graphics.translate(self.x * textScale, (self.y + self.verticalOffset + self.textOffsetY) * textScale)
    love.graphics.scale(animScale, animScale)
    
    love.graphics.print(self.text, math.floor(-textW/2), math.floor(-textVisualCenterY))
    
    love.graphics.setFont(previousFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
    
    love.graphics.pop()
end

return WinBanner
