local core = require(".modules.world-path.core")
local modem = peripheral.find("modem") or error("No modem attached", 0)

local NET_ENUMS = {
    INIT = 0,
    POST = 1,
    GET = 2,
}

write("Monitor width> ")
local width = tonumber(read())

write("Monitor height> ")
local height = tonumber(read())

modem.open(80)

modem.transmit(79, 80, {
    type = NET_ENUMS.INIT
})

local event, side, channel, replyChannel, message, distance

while true do
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")

    if channel == 80 then
        if message.type == NET_ENUMS.INIT then
            write("Select Position 1-" .. width * height "> ")
            
            modem.transmit(86, 87, {
                type = NET_ENUMS.POST,
                position = tonumber(read())
            })
        end
    end

    sleep(0.1)
end