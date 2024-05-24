require("extensions.table")
require("extensions.string")
local Vector = require("extensions.vector")
local Angle = require("extensions.angle")
local Color = require("extensions.color")
local tArgs = {...}
local ip = tArgs[1] or "localhost"
local httpPort = tArgs[2] or 8113
local wsPort = tArgs[3] or 8114

local utils = require("utils.utils")
local config = require("configuration"):new {
    path = "./config.json",
    init = {
        liveSync = false,
        modules = {},
    },
    launch = {
        liveSync = false,
    }
}
local api = require("api.client"):new {
    ip = ip,
    httpPort = httpPort,
    wsPort = wsPort
}
local tabManager = require("utils.tabs"):new()
local fileWrapper = require("utils.file")
local termCommands = {
    reboot = function()
        os.reboot()
    end,
    modules = function(request)
        local modules = api:sendGet("modules")

        if not modules then
            utils.printC("Failed to connect to server", colors.red)
            return
        end

        modules = utils.JSONtoTable(modules.readAll())
        utils.printC("Modules:", colors.yellow)

        for _, module in ipairs(modules) do
            utils.printC("  " .. module, colors.yellow)
        end
    end,
    deleteAll = function()
        configMgr.deleteAll()
        utils.printC("Deleted all files", colors.green)
    end,
    readConfig = function()
        utils.printC(fs.open("./config.json", "r").readAll(), colors.yellow)
    end,
    sync = function()
        local live_sync = config:setVariable{
            liveSync = not config:getVariable("liveSync")
        }.liveSync
        local tab = tabManager:findTabByName("Sync")

        utils.printC("Live syncing " .. (live_sync and "enabled" or "disabled"), colors.green)

        if tab then
            tabManager:closeTab(tab)
        end

        if live_sync then
            if fs.exists("./sync.lua") then
                
                local shellId = tabManager:startInTab({
                    api = api, 
                    tabManager = tabManager, 
                    config = config
                }, "./sync.lua", "Sync")
                shell.switchTab(shellId)
            else
                utils.printC("Sync file not found", colors.red)
            end
        end
    end,
    download = function(...)
        local response = api:sendGet("download", { paths = {...} })
    
        if response then
            response = utils.JSONtoTable(response.readAll())
            for path, content in pairs(response) do
                local module_name = path:match("modules/(.*)")
                module_name = module_name:match("(.*)/")

                fileWrapper:editFile(path, content)
                config:setVariable{
                    modules = {
                        [module_name] = true
                    }
                }
            end

            if #response > 0 then
                utils.printC("Downloaded files", colors.green)
            else
                utils.printC("Couldnt find module", colors.red)
            end
        else
            utils.printC("Failed to connect to server", colors.red)
        end
    end,
    ls = function(path)
        local files = fs.list(path or "./")
        utils.printC("Files:", colors.yellow)
        for _, file in ipairs(files) do
            utils.printC("  " .. file, colors.yellow)
        end
    end,
    edit = function(path)
        if fs.exists(path) then
            shell.run("edit", path)
        else
            utils.printC("File does not exist", colors.red)
        end
    end,
    help = function()
        printUsage()
    end,
    start = function(module)
        local modules = config:getVariable("modules")

        if table.hasKey(modules, module) then
            local shellId = tabManager:startInTab({
                api = api, 
                tabManager = tabManager, 
                config = config,
                Vector = Vector,
                Angle = Angle,
                Color = Color
            }, "./modules/" .. module .. "/main.lua", module)

            shell.switchTab(shellId)
        else
            utils.printC("Module not found", colors.red)
        end
    end,
    stop = function(module)
        local tab = tabManager:findTabByName(module)

        if tab then
            tabManager:closeTab(tab)
        else
            utils.printC("Module not running", colors.red)
        end
    
    end
}

local messageDescription = {
    reboot = "Reboots the computer",
    modules = "List all modules",
    sync = "Toggle live syncing of modules",
    readConfig = "Read the config file",
    deleteAll = "Delete all files",
    edit = "Edit a file",
    ls = "List files in directory",
    help = "Print this message",
    start = "Start module"
}

function printUsage()
    utils.printC("Commands:", colors.yellow)

    for command, desc in pairs(messageDescription) do
        utils.printC("  " .. command .. " - " .. desc, colors.yellow)
    end
end

if true then
    local modules = config:getVariable("modules")

    if #modules ~= 0 then
        local response = api:sendGet("download", { paths = modules })
    
        if response then
            response = utils.JSONtoTable(response.readAll())

            for path, content in pairs(response) do
                fileWrapper.editFile(path, content)
            end
    
            request.close()
        else
            utils.printC("Failed to connect to server", colors.red)
        end
    end
end

printUsage()

while true do
    write(">")
    local input = read()

    if input then
        local args = string.split(input, " ")
        local command = table.remove(args, 1)
        local ranCommand = false
        
        for cmd, func in pairs(termCommands) do
            if command == cmd then
                
                func(unpack(args))
                ranCommand = true
            end
        end

        if not ranCommand then
            utils.printC("Invalid message", colors.red)
        end
    else
        printUsage()
    end

    sleep(0.1)
end