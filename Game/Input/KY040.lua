local socket = require("socket")

local KY040Bridge = {}

-- UDP setup
KY040Bridge.udp = socket.udp()
KY040Bridge.udp:settimeout(0)  -- non-blocking
KY040Bridge.udp:setsockname("127.0.0.1", 5005)

-- State of encoder/buttons
KY040Bridge.state = {}

-- Update state from incoming UDP events
function KY040Bridge:update()
    -- Reset all state keys each frame
    for k,_ in pairs(self.state) do
        self.state[k] = false
    end

    while true do
        local data, err = self.udp:receive()
        if not data then break end

        -- Dynamically set the event to true
        self.state[data] = true
    end
end

-- Check if a specific event is pressed
function KY040Bridge:isEventPressed(eventName)
    return self.state[eventName] or false
end

return KY040Bridge
