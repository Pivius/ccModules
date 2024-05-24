-- env: api, tabManager
-- Enables live syncing of files within ./modules directory without
-- the need to restart the computer

local utils = require(".utils.utils")
local fileWrapper = require(".utils.file")
local ws = api:listenSocket()

if not ws then
    utils.printC("Failed to connect to server", colors.red)
    return
end

utils.printC("Connecting to server...", colors.yellow)
utils.printC("Getting authorization, your computer ID is " .. os.getComputerID(), colors.yellow)

api:socketSend {
    type = "auth",
    computerId = os.getComputerID()
}

local message = api:socketReceive()

if message then
    if message.type == "auth" and message.status == "authorized" then
        utils.printC("Authorized", colors.green)
    elseif message.type == "auth" and message.status ~= "authorized" then
        utils.printC("Authorization was reject due to: " .. message.status, colors.red)
        return
    end
else
    utils.printC("Failed to receive authorization", colors.red)
    return
end

utils.printC("This only tracks changes in modules if you have them accessible", colors.green)

tabManager:setupTerminateListener(function()
    ws:close()
end,
function()
    while true do
        local message = api:socketReceive()

        if message.type == "sync" and fs.exists(message.path) then
            local path = message.path
            local content = message.content
            local action = message.action
            local module = message.module

            if module then
                if config:getVariable("modules")[module] then
                    local modulePath = "./modules/" .. module
    
                    if action == "add" or action == "change" then
                        fileWrapper:editFile(path, content)
                        utils.printC("Updated " .. path, colors.green)
                    elseif action == "addDir" then
                        fileWrapper:createDir(path)
                        utils.printC("Created directory " .. path, colors.green)
                    elseif action == "unlinkDir" or "unlink" then
                        fileWrapper:deletePath(path)
                        utils.printC("Deleted " .. path, colors.green)
                    end
                end

            end
        end
    end
end)
