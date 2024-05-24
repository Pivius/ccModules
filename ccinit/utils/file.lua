local utils = require(".utils.utils")
local FileWrapper = {}

function FileWrapper:deletePath(path)
    if fs.exists(path) then
        fs.delete(path)
        return true
    else
        return false
    end
end

function FileWrapper:createDir(path)
    if not fs.exists(path) then
        fs.makeDir(path)
    end
end

function FileWrapper:createFile(path, content)
    if fs.exists(path) then
        return utils.printC("File already exists", colors.red)
    end

    local file = fs.open(path, "w")

    if content then
        file.write(content)
    end

    file.close()
end

function FileWrapper:readFile(path)
    local file = fs.open(path, "r")
    local content = file.readAll()
    file.close()
    return content
end

function FileWrapper:editFile(path, content)
    local file = fs.open(path, "w")
    file.write(content)
    file.close()
end

function FileWrapper:readJSON(path)
    return utils.JSONtoTable(self:readFile(path)) or {}
end

function FileWrapper:editJSON(path, tbl)
    local fileContent = self:readJSON(path)

    for key, value in pairs(tbl) do
        fileContent[key] = value
    end

    self:editFile(path, utils.tableToJSON(fileContent))

    return fileContent
end

return FileWrapper