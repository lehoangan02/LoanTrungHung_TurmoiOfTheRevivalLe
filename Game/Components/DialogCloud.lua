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
    instance.bottomBarRightX = x + width - 3
    instance.bottomBarAnimationSpeed = math.abs(instance.bottomBarRightX - instance.bottomBarLeftX) / instance.animationTime
    instance.bottomBarCurrentX = instance.bottomBarLeftX
    instance.bottomBarY = y + height - 1

    instance.mainSquareRightX = x + width + 1
    instance.mainSquareXAnimationSpeed = math.abs(instance.mainSquareRightX - instance.leftBarX) / instance.animationTime
    instance.mainSquareCurrentX = instance.bottomBarLeftX


    instance.topLeftCornerSpriteSheet = love.graphics.newImage("Resources/Images/CloudTopLeftCorner.png")
    instance.topLeftCornerSpriteSheet:setFilter("nearest", "nearest")
    instance.topLeftCornerGrid = anim8.newGrid(3, 3, instance.topLeftCornerSpriteSheet:getWidth(), instance.topLeftCornerSpriteSheet:getHeight())
    instance.topLeftCornerAnimation = anim8.newAnimation(instance.topLeftCornerGrid('1-3', 1), 0.1, 'pauseAtEnd')
    instance.topLeftCornerAnimation:gotoFrame(1)
    instance.topLeftCornerAnimation:pause()
    instance.drawTopLeft = false

    instance.bottomRightCornerSpriteSheet = love.graphics.newImage("Resources/Images/CloudBottomRightCorner.png")
    instance.bottomRightCornerSpriteSheet:setFilter("nearest", "nearest")
    instance.bottomRightCornerGrid = anim8.newGrid(3, 3, instance.bottomRightCornerSpriteSheet:getWidth(), instance.bottomRightCornerSpriteSheet:getHeight())
    instance.bottomRightCornerAnimation = anim8.newAnimation(instance.bottomRightCornerGrid('1-3', 1), 0.1, 'pauseAtEnd')
    instance.bottomRightCornerAnimation:gotoFrame(1)
    instance.bottomRightCornerAnimation:pause()
    instance.drawBottomRight = false

    instance.drawTopBar = false
    instance.drawRightBar = false

    instance.topRightCorner = love.graphics.newImage("Resources/Images/CloudTopRightCorner.png")
    instance.topRightCorner:setFilter("nearest", "nearest")
    instance.drawTopRight = false

    return instance
end

function DialogCloud:update(dt)
    if not self.started then
        return
    end
    self.sproutAnimation:update(dt)
    self.topLeftCornerAnimation:update(dt)
    self.bottomRightCornerAnimation:update(dt)
    if self.leftBarCurrentY > self.leftBarTopY and self.sproutAnimation.status == "paused" then
        self.leftBarCurrentY = self.leftBarCurrentY - self.leftBarAnimationSpeed * dt
        if self.leftBarCurrentY < self.leftBarTopY then
            self.leftBarCurrentY = self.leftBarTopY
            self.drawTopLeft = true
            self.topLeftCornerAnimation:gotoFrame(1)
            self.topLeftCornerAnimation:resume()
        end
    end
    if self.bottomBarCurrentX < self.bottomBarRightX and self.sproutAnimation.status == "paused" then
        self.bottomBarCurrentX = self.bottomBarCurrentX + self.bottomBarAnimationSpeed * dt
        if self.bottomBarCurrentX > self.bottomBarRightX then
            self.bottomBarCurrentX = self.bottomBarRightX
            self.drawBottomRight = true
            self.bottomRightCornerAnimation:gotoFrame(1)
            self.bottomRightCornerAnimation:resume()
        end
    end
    if self.mainSquareCurrentX < self.mainSquareRightX and self.sproutAnimation.status == "paused" then
        self.mainSquareCurrentX = self.mainSquareCurrentX + self.mainSquareXAnimationSpeed * dt
        if self.mainSquareCurrentX > self.mainSquareRightX then
            self.mainSquareCurrentX = self.mainSquareRightX
        end
    end

    if self.topLeftCornerAnimation.status == "paused"
    and self.topLeftCornerAnimation.position == #self.topLeftCornerAnimation.frames
    then
        self.drawTopBar = true
    end

    if self.bottomRightCornerAnimation.status == "paused"
    and self.bottomRightCornerAnimation.position == #self.bottomRightCornerAnimation.frames
    then
        self.drawRightBar = true
    end

    if self.drawTopBar and self.drawRightBar then
        self.drawTopRight = true
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
    --draw top left corner
    if self.drawTopLeft then
        self.topLeftCornerAnimation:draw(self.topLeftCornerSpriteSheet, self.x, self.y)
    end
    --draw bottom right corner
    if self.drawBottomRight then
        self.bottomRightCornerAnimation:draw(self.bottomRightCornerSpriteSheet, self.x + self.width - 3, self.y + self.height - 3)
    end
    if self.drawTopBar then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.line(self.x + 3, self.y + 0.5, self.x + self.width - 3, self.y + 0.5)
    end
    if self.drawRightBar then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.line(self.x + self.width - 0.5, self.y + 3, self.x + self.width - 0.5, self.y + self.height - 3)
    end
    if self.drawTopRight then
        love.graphics.draw(self.topRightCorner, self.x + self.width - 3, self.y)
        love.graphics.setColor(0, 0, 1.0, 0.5)
        -- love.graphics.rectangle("fill", self.x + 2, self.y + 1, self.width - 4, 1)
        -- love.graphics.rectangle("fill", self.x + self.width - 2, self.y + 2, 1, self.height - 4)
        love.graphics.points(self.x + self.width - 1, self.y + 1)
    end
    
    love.graphics.setColor(1, 1, 1, 1)

    --set blue
    love.graphics.setColor(0, 0, 1.0, 0.5)
    love.graphics.rectangle("fill", self.x + 1, self.leftBarCurrentY, self.mainSquareCurrentX - self.bottomBarLeftX, self.leftBarBottomY - self.leftBarCurrentY)
    love.graphics.rectangle("fill", self.x + 1, self.leftBarCurrentY - 1, self.mainSquareCurrentX - self.bottomBarLeftX - 1, 1)
    love.graphics.rectangle("fill", self.x + 1 + (self.mainSquareCurrentX - self.bottomBarLeftX), self.leftBarCurrentY + 1, 1, self.leftBarBottomY - self.leftBarCurrentY - 1)
    love.graphics.setColor(1, 1, 1, 1)

end

function DialogCloud:startDialogue()
    self.started = true
    self.sproutAnimation:gotoFrame(1)
    self.sproutAnimation:resume()
end

return DialogCloud