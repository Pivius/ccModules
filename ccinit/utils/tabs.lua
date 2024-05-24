local make_package = dofile("rom/modules/main/cc/require.lua").make
local TabManager = {}
TabManager.__index = TabManager


local function createShellEnv(dir, extra)
    local env = table.merge(extra or {}, { shell = shell, multishell = multishell })

    env.require, env.package = make_package(env, dir)
    return env
end

function TabManager:new()
    local proto = {
        tabs = {}
    }
    local self = setmetatable(proto, TabManager)
    return self
end

function TabManager:checkTab(shellId)
    return multishell.getTab(shellId)
end

function TabManager:findTabByName(name)
    for shellId, tab in pairs(self.tabs) do
        if tab.title == name then
            return shellId
        end
    end
    return nil
end

function TabManager:startInTab(env, path, title)
    local shellEnv = createShellEnv("rom/programs", env)

    --local shellEnv = table.merge(env, shellEnv)
    local shellId = multishell.launch(shellEnv, path)

    multishell.setTitle(shellId, title)
    self.tabs[shellId] = {
        path = path,
        title = title
    }
    return shellId
end

function TabManager:closeTab(shellId)
    os.queueEvent("terminate_tab", shellId)
end

function TabManager:hasTab(path)
    return self.tabs[path] ~= nil
end

function TabManager:setupTerminateListener(terminateCallback, ...)
    parallel.waitForAny(function()
        while true do
            local event, shellId = os.pullEventRaw("terminate_tab")

            if event then
                terminateCallback()
                return
            end
        end
    end, ...)
end

return TabManager