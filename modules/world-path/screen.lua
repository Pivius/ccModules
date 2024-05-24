local screen = {}
local modem = peripheral.find("modem") or error("No modem attached", 0)
local monitor = peripheral.find("monitor") or error("No monitor attached", 0)

modem.open(86)


local NET_ENUMS = {
    INIT = 0,
    POST = 1,
    GET = 2,
}
local event, side, channel, replyChannel, message, distance

write("Select screen position> ")
local monitorPos = read()
monitor.setTextScale(0.5)
local aspectRatio = monitor.getSize()

monitor.clear()

