-- interface for levle
local Level = {}
Level.__index = Level

local TransitionEnum = require("Game.TransitionEnum")
Level.transitionOut = TransitionEnum.Fade

function Level:load()
   error("Level.load not implemented")
end

function Level:update(dt)
   error("Level.update not implemented")
end

function Level:draw(windowWidth, windowHeight)
   error("Level.draw not implemented")
end

function Level:unload()
   error("Level.unload not implemented")
end

return Level
