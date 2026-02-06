local Main = {}

BASE_W = 240
BASE_H = 240

function love.load()
    love.window.setTitle("Turmoi of The Revival Le")
    love.window.setMode(BASE_W, BASE_H, { resizable = true })
    
    GameManager = require("Game.GameManager")

    GameManager.windowWidth = BASE_W
    GameManager.windowHeight = BASE_H

    
    Main.gameManager = GameManager.new()
    Main.gameManager:start()
end

function love.resize(w, h)
    GameManager.windowWidth = w
    GameManager.windowHeight = h
end

function love.update(dt)
    Main.gameManager:update(dt)
end

function love.draw()
    love.graphics.push()
    Main.gameManager:draw(GameManager.windowWidth, GameManager.windowHeight)
    love.graphics.pop()
end

-- function love.load()
--     love.physics.setMeter(64)

--     gravityStrength = 5 * 64
--     world = love.physics.newWorld(0, gravityStrength, true)

--     left = love.physics.newBody(world, 300, 300, "kinematic")
--     leftShape = love.physics.newRectangleShape(20, 120)
--     love.physics.newFixture(left, leftShape)

--     right = love.physics.newBody(world, 360, 300, "dynamic")
--     rightShape = love.physics.newRectangleShape(120, 20)
--     love.physics.newFixture(right, rightShape, 2)

--     hinge = love.physics.newRevoluteJoint(
--         left,
--         right,
--         320,
--         300,
--         false
--     )

--     hinge:setMotorEnabled(true)
--     hinge:setMaxMotorTorque(20000)

--     springK = 30
--     damping = 4
-- end

-- function love.update(dt)
--     local speed = 300
--     local x, y = left:getPosition()

--     if love.keyboard.isDown("w") then y = y - speed * dt end
--     if love.keyboard.isDown("s") then y = y + speed * dt end

--     left:setPosition(x, y)

--     local angle = hinge:getJointAngle()
--     local angVel = hinge:getJointSpeed()

--     hinge:setMotorSpeed(-springK * angle - damping * angVel)

--     world:update(dt)
-- end

-- function love.keypressed(key)
--     if key == "1" then
--         world:setGravity(0, gravityStrength)
--     end

--     if key == "2" then
--         world:setGravity(0, -gravityStrength)
--     end

--     if key == "r" then
--         left:setTransform(300, 300, 0)
--         right:setTransform(360, 300, 0)
--         right:setLinearVelocity(0, 0)
--         right:setAngularVelocity(0)
--     end
-- end

-- function love.draw()
--     drawBody(left, leftShape)
--     drawBody(right, rightShape)

--     love.graphics.setColor(1, 0, 0)
--     love.graphics.circle("fill", 320, 300, 4)
--     love.graphics.setColor(1, 1, 1)

--     love.graphics.print(
--         "W / S : move left bar\n1 : gravity down\n2 : gravity up\nSpring hinge (strong)",
--         10,
--         10
--     )
-- end

-- function drawBody(body, shape)
--     love.graphics.polygon(
--         "line",
--         body:getWorldPoints(shape:getPoints())
--     )
-- end
