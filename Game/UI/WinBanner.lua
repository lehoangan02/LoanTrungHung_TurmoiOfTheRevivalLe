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
    
    -- Multi-link Verlet Chain Physics
    self.numLinks = 10
    self.linkLength = 5
    self.chainAttachY = 15 -- Adjust this to move the chain up/down relative to the banner
    self.chainLeftAttachX = -30  -- X position of the left chain
    self.chainRightAttachX = 30 -- X position of the right chain
    
    -- X position offset for the SECOND pair of chains (relative to the center of the first button)
    self.chain2LeftAttachOffsetX = -30
    self.chain2RightAttachOffsetX = 30
    
    self.chainLeft = {}
    self.chainRight = {}
    
    for i = 1, self.numLinks do
        local cy = self.chainAttachY + i * self.linkLength
        table.insert(self.chainLeft, {x = self.chainLeftAttachX, y = cy, oldX = self.chainLeftAttachX, oldY = cy})
        table.insert(self.chainRight, {x = self.chainRightAttachX, y = cy, oldX = self.chainRightAttachX, oldY = cy})
    end
    
    -- Second level chains (for a second button)
    self.numLinks2 = math.floor(self.numLinks / 2)
    self.chainLeft2 = {}
    self.chainRight2 = {}
    
    for i = 1, self.numLinks2 do
        local cy = self.chainAttachY + 50 + i * self.linkLength
        table.insert(self.chainLeft2, {x = self.chainLeftAttachX, y = cy, oldX = self.chainLeftAttachX, oldY = cy})
        table.insert(self.chainRight2, {x = self.chainRightAttachX, y = cy, oldX = self.chainRightAttachX, oldY = cy})
    end
    
    return self
end

function WinBanner:setPosition(x, y)
    self.x = x
    self.y = y
end

function WinBanner:addChild(element, localX, localY)
    element:setPosition(localX or 0, localY or 0)
    table.insert(self.children, element)
end

function WinBanner:trigger()
    self.active = true
    self.timer = 0 -- Reset timer to replay the animation
    
    -- Jolt the chains horizontally to simulate a physical reaction to the pop
    for i = 2, self.numLinks do
        self.chainLeft[i].oldX = self.chainLeft[i].x - i * 4
        self.chainRight[i].oldX = self.chainRight[i].x - i * 5
    end
    for i = 2, self.numLinks2 do
        self.chainLeft2[i].oldX = self.chainLeft2[i].x - i * 4
        self.chainRight2[i].oldX = self.chainRight2[i].x - i * 5
    end
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
    
    -- Verlet physics integration
    local gravity = 1000
    
    local function updateVerletChain(chain, attachX, attachY)
        -- Gravity and inertia
        for i = 2, #chain do
            local p = chain[i]
            local vx = (p.x - p.oldX) * 0.95 -- Friction
            local vy = (p.y - p.oldY) * 0.95
            
            p.oldX = p.x
            p.oldY = p.y
            
            p.x = p.x + vx
            p.y = p.y + vy + gravity * dt * dt
        end
        
        -- Distance Constraints
        for iter = 1, 15 do
            chain[1].x = attachX
            chain[1].y = attachY
            
            for i = 1, #chain - 1 do
                local p1 = chain[i]
                local p2 = chain[i+1]
                local dx = p2.x - p1.x
                local dy = p2.y - p1.y
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist > 0 then
                    local diff = self.linkLength - dist
                    local percent = diff / dist / 2
                    local offsetX = dx * percent
                    local offsetY = dy * percent
                    
                    if i == 1 then
                        p2.x = p2.x + offsetX * 2
                        p2.y = p2.y + offsetY * 2
                    else
                        p1.x = p1.x - offsetX
                        p1.y = p1.y - offsetY
                        p2.x = p2.x + offsetX
                        p2.y = p2.y + offsetY
                    end
                end
            end
        end
    end
    
    updateVerletChain(self.chainLeft, self.chainLeftAttachX, self.chainAttachY)
    updateVerletChain(self.chainRight, self.chainRightAttachX, self.chainAttachY)
    
    -- Dynamically link the attached child (like a button) to the bottom of the chains so it swings!
    if #self.children > 0 then
        local child1 = self.children[1]
        local lastLeft1 = self.chainLeft[#self.chainLeft]
        local lastRight1 = self.chainRight[#self.chainRight]
        
        local cx1 = (lastLeft1.x + lastRight1.x) / 2
        local cy1 = (lastLeft1.y + lastRight1.y) / 2
        
        -- Hang the first button exactly in the middle of the two chain ends
        if child1.width then
            child1:setPosition(cx1 - child1.width / 2, cy1)
        end
        
        -- Cascade to a second button if it exists
        if #self.children > 1 then
            local child2 = self.children[2]
            
            -- Anchor second chains using the configurable offset from the center of the first button
            local attachXLeft2 = cx1 + self.chain2LeftAttachOffsetX
            local attachXRight2 = cx1 + self.chain2RightAttachOffsetX
            local attachY2 = cy1 + (child1.height or 30)
            
            updateVerletChain(self.chainLeft2, attachXLeft2, attachY2)
            updateVerletChain(self.chainRight2, attachXRight2, attachY2)
            
            local lastLeft2 = self.chainLeft2[#self.chainLeft2]
            local lastRight2 = self.chainRight2[#self.chainRight2]
            
            local cx2 = (lastLeft2.x + lastRight2.x) / 2
            local cy2 = (lastLeft2.y + lastRight2.y) / 2
            
            if child2.width then
                child2:setPosition(cx2 - child2.width / 2, cy2)
            end
        end
    end
    
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

function WinBanner:draw(scale, fontScale, offsetX, offsetY)
    if not self.active then return end
    
    fontScale = fontScale or scale
    local progress = self.timer / self.duration
    local animScale = easeOutBack(progress)
    
    local imgW = self.width
    local imgH = self.height
    
    love.graphics.push()
    love.graphics.scale(1/scale, 1/scale)
    
    -- 1. Draw Image, Chains, and Children
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.translate(self.x, self.y + self.verticalOffset)
    love.graphics.scale(animScale, animScale)
    
    -- Draw chains
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    local function drawVerletChain(chain)
        for i = 1, #chain - 1 do
            local p1 = chain[i]
            local p2 = chain[i+1]
            local dx = p2.x - p1.x
            local dy = p2.y - p1.y
            local angle = math.atan2(dy, dx)
            
            love.graphics.push()
            love.graphics.translate(p1.x, p1.y)
            love.graphics.rotate(angle - math.pi/2)
            love.graphics.rectangle("line", -1.5, 0, 3, self.linkLength)
            love.graphics.pop()
        end
        local last = chain[#chain]
        love.graphics.rectangle("fill", last.x - 0.5, last.y, 1, 2)
    end
    
    drawVerletChain(self.chainLeft)
    drawVerletChain(self.chainRight)
    
    if #self.children > 1 then
        drawVerletChain(self.chainLeft2)
        drawVerletChain(self.chainRight2)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.image, -imgW/2, -imgH/2)
    
    love.graphics.pop()
    
    -- Draw children from an unscaled coordinate space so UI elements can load crisp fonts!
    -- Note: Playground already translates by global offsetX/Y, so we don't add them here!
    for _, child in ipairs(self.children) do
        local combinedScale = scale * animScale
        local childOffsetX = self.x * scale
        local childOffsetY = (self.y + self.verticalOffset) * scale
        child:draw(combinedScale, childOffsetX, childOffsetY)
    end
    
    -- 2. Draw Text
    love.graphics.push()
    local previousFont = love.graphics.getFont()
    local textScale = scale
    
    self.font = FontLoader:loadFont("Geo", self.fontSize * fontScale)
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 1)
    
    local textW = self.font:getWidth(self.text)
    local baseline = self.font:getBaseline()
    local ascent = self.font:getAscent()
    local descent = self.font:getDescent()
    local textVisualCenterY = baseline - (ascent - descent) / 2
    
    love.graphics.translate(self.x * textScale, (self.y + self.verticalOffset + self.textOffsetY) * textScale)
    love.graphics.scale(animScale, animScale)
    
    love.graphics.print(self.text, math.floor(-textW/2), math.floor(-textVisualCenterY))
    
    love.graphics.setFont(previousFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
    
    love.graphics.pop()
end

return WinBanner
