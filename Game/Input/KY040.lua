local socket = require("socket")

local KY040 = {}

-- UDP setup
KY040.udp = socket.udp()
KY040.udp:settimeout(0)  -- non-blocking
KY040.udp:setsockname("127.0.0.1", 5005)

-- State of encoder/buttons
KY040.state = {}

-- Update state from incoming UDP events
function KY040:update()
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
function KY040:isEventPressed(eventName)
    return self.state[eventName] or false
end

return KY040
