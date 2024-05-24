local WebSocketHandler = require(".api.websocket")
local utils = require(".utils.utils")
local APIHandler = {}
APIHandler.__index = APIHandler

function APIHandler:new(args)
    local proto = {
        ip = args.ip or "localhost",
        httpPort = args.httpPort or 8113,
        wsPort = args.wsPort or 8114,
        isComputerListening = args.isComputerListening or false,
        webSocket = WebSocketHandler:new {
            ip = args.ip,
            port = args.wsPort
        }
    }

    local self = setmetatable(proto, APIHandler)
    return self
end

function APIHandler:getHttpUrl()
    return "http://" .. self.ip .. ":" .. self.httpPort
end

function APIHandler:getSocketUrl()
    return "ws://" .. self.ip .. ":" .. self.wsPort .. "/"
end

function APIHandler:tableToQueryString(table)
    local query = ""

    for key, value in pairs(table) do
        if type(value) == "table" then
            for k, v in pairs(value) do
                query = query .. key .. "=" .. v .. "&"
            end
        else
            query = query .. key .. "=" .. value .. "&"
        end
    end

    return query:sub(1, -2) -- Remove trailing &
end

function APIHandler:sendRequest(method, endpoint, data)
    local url = self:getHttpUrl() .. "/" .. endpoint
    local response = http.request(url, data, {["Content-Type"] = "application/json", ["Method"] = method})

    if response then
        return response
    else
        utils.printC("Failed to send " .. method .. " request to " .. url, colors.red)
        return nil
    end
end

function APIHandler:sendGet(endpoint, query)
    local url = self:getHttpUrl() .. "/" .. endpoint .. (query and ("?" .. self:tableToQueryString(query)) or "")
    local response = http.get(url)

    if response then
        return response
    else
        utils.printC("Failed to send GET request to " .. url, colors.red)
        return nil
    end
end

function APIHandler:sendPost(endpoint, data)
    local url = self:getHttpUrl() .. "/" .. endpoint
    local response = http.post(url, utils.tableToJSON(data), {["Content-Type"] = "application/json"})
    if response then
        return response
    else
        utils.printC("Failed to send POST request to " .. url, colors.red)
        return nil
    end
end

function APIHandler:listenSocket()
    if not self.isComputerListening then
        local url = self:getSocketUrl()
        
        if self.webSocket:connect() then
            utils.printC("Listening on " .. url, colors.green)
            return self.webSocket
        else
            utils.printC("Failed to listen on " .. url, colors.red)
            return nil
        end
    end

    utils.printC("Computer is already listening", colors.red)
    return nil
end

function APIHandler:socketReceive()
    return self.webSocket:receive()
end

function APIHandler:socketSend(data)
    self.webSocket:send(data)
end

function APIHandler:closeSocket()
    self.webSocket:close()
    utils.printC("Stopped listening on " .. self:getSocketUrl(), colors.green)
end

return APIHandler