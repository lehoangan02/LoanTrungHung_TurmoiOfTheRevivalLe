local DialogCloud = {}
DialogCloud.__index = DialogCloud

local FontLoader = require("Game.Fonts.FontLoader")

local anim8 = require("Game.Libraries.anim8")

function DialogCloud.new(text, x, y, width, height)
    local instance = setmetatable({}, DialogCloud)

    instance.text = text
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height

    instance.animationTime = 1.0
    instance.started = false

    instance.font = FontLoader:loadFont("Geo", 16)

    instance.sproutSpritesheet = love.graphics.newImage("Resources/Images/DialogCloudSprout.png")
    instance.sproutSpritesheet:setFilter("nearest", "nearest")
    instance.sproutGrid = anim8.newGrid(5, 4, instance.sproutSpritesheet:getWidth(), instance.sproutSpritesheet:getHeight())
    instance.sproutAnimation = anim8.newAnimation(instance.sproutGrid('1-4', 1), 0.2, 'pauseAtEnd')
    instance.sproutAnimation:gotoFrame(1)
    instance.sproutAnimation:pause()
    instance.sproutX = instance.x
    instance.sproutY = instance.y + instance.height - 1

    instance.leftBarX = x
    instance.leftBarTopY = y + 3 
    instance.leftBarBottomY = y + height - 1
    instance.leftBarAnimationSpeed = math.abs(instance.leftBarTopY - instance.leftBarBottomY) / instance.animationTime
    instance.leftBarCurrentY = instance.leftBarBottomY

    instance.bottomBarLeftX = x + 5
    instance.bottomBarRightX = x + width
    instance.bottomBarAnimationSpeed = math.abs(instance.bottomBarRightX - instance.bottomBarLeftX) / instance.animationTime
    instance.bottomBarCurrentX = instance.bottomBarLeftX
    instance.bottomBarY = y + height - 1

    instance.topLeftCornerSpriteSheet = love.graphics.newImage("Resources/Images/CloudTopLeftCorner.png")
    instance.topLeftCornerSpriteSheet:setFilter("nearest", "nearest")
    instance.topLeftCornerGrid = anim8.newGrid(3, 3, instance.topLeftCornerSpriteSheet:getWidth(), instance.topLeftCornerSpriteSheet:getHeight())
    instance.topLeftCornerAnimation = anim8.newAnimation(instance.topLeftCornerGrid('1-3', 1), 0.2, 'pauseAtEnd')
    instance.topLeftCornerAnimation:gotoFrame(1)
    instance.topLeftCornerAnimation:pause()
    instance.drawTopLeft = false


    return instance
end

function DialogCloud:update(dt)
    if not self.started then
        return
    end
    self.sproutAnimation:update(dt)
    if self.leftBarCurrentY > self.leftBarTopY and self.sproutAnimation.status == "paused" then
        self.leftBarCurrentY = self.leftBarCurrentY - self.leftBarAnimationSpeed * dt
        if self.leftBarCurrentY < self.leftBarTopY then
            self.leftBarCurrentY = self.leftBarTopY
            self.drawTopLeft = true
        end
    end
    if self.bottomBarCurrentX < self.bottomBarRightX and self.sproutAnimation.status == "paused" then
        self.bottomBarCurrentX = self.bottomBarCurrentX + self.bottomBarAnimationSpeed * dt
        if self.bottomBarCurrentX > self.bottomBarRightX then
            self.bottomBarCurrentX = self.bottomBarRightX
        end
    end
end

function DialogCloud:draw()
    --draw sprout
    self.sproutAnimation:draw(self.sproutSpritesheet, self.sproutX, self.sproutY)
    --draw left bar
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.setLineStyle("rough")
    love.graphics.line(self.leftBarX + 0.5, self.leftBarBottomY, self.leftBarX + 0.5, math.floor(self.leftBarCurrentY))
    --draw bottom bar
    love.graphics.line(self.bottomBarLeftX, self.bottomBarY + 0.5, math.floor(self.bottomBarCurrentX), self.bottomBarY + 0.5)

    love.graphics.setColor(1, 1, 1, 1)

    --set blue
    love.graphics.setColor(0, 0, 1.0, 0.5)
    -- draw a pixel at (self.x, self.y)
    -- love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1, 1)

end

function DialogCloud:startDialogue()
    self.started = true
    self.sproutAnimation:gotoFrame(1)
    self.sproutAnimation:resume()
end

return DialogCloud