local utils = require(".utils.utils")
local WebSocketHandler = {}
WebSocketHandler.__index = WebSocketHandler

function WebSocketHandler:new(args)
    local proto = {
        ip = args.ip or "localhost",
        port = args.port or 8114,
        ws = nil
    }
    local self = setmetatable(proto, WebSocketHandler)

    return self
end

function WebSocketHandler:getUrl()
    return "ws://" .. self.ip .. ":" .. self.port .. "/"
end

function WebSocketHandler:connect()
    local url = self:getUrl()

    self.ws = http.websocket(url)

    if self.ws then
        utils.printC("Connected to " .. url, colors.green)
    else
        utils.printC("Failed to connect to " .. url, colors.red)
    end
    return self.ws ~= nil
end

function WebSocketHandler:send(data)
    if self.ws then
        self.ws.send(utils.tableToJSON(data))
    else
        utils.printC("WebSocket is not connected", colors.red)
    end
end

function WebSocketHandler:receive()
    if self.ws then
        local message = self.ws.receive()

        if message then
            return utils.JSONtoTable(message)
        end
    else
        utils.printC("WebSocket is not connected", colors.red)
    end
    return nil
end

function WebSocketHandler:close()
    if self.ws then
        self.ws.close()
        utils.printC("Disconnected from " .. self:getUrl(), colors.green)
    else
        utils.printC("WebSocket is not connected", colors.red)
    end
end

return WebSocketHandler