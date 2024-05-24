local FileWrapper = require("utils.file")
local Config = {}
Config.__index = Config

function Config:new(args)
    local proto = {
        path = args.path or "./config.json",
        init = args.init or {},
        launch = args.launch or {},
        cache = {}
    }
    local self = setmetatable(proto, Config)

    if not fs.exists(self.path) then
        FileWrapper:createFile(self.path)
        FileWrapper:editJSON(self.path, self.init)
    else
        FileWrapper:editJSON(self.path, self.launch)
    end
    
    self:load()
    
    return self
end

function Config:load()
    self.cache = FileWrapper:readJSON(self.path)
    return self.cache
end

function Config:edit(config)
    self.cache = FileWrapper:editJSON(self.path, config)
end

function Config:setVariable(args)
    self:edit(table.deepMerge(self.cache, args))

    return self.cache
end

function Config:getVariable(key)
    return self.cache[key]
end

return Config