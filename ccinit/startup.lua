local HOST = "localhost"
local HTTP_PORT = 8113
local WS_PORT = 8114
local MESSAGE = "download"
local files = {
    "ccinit"
}

local function generateQueryString(files)
    local query = ""
    for i, file in ipairs(files) do
        query = query .. "paths=" .. file
        if i < #files then
            query = query .. "&"
        end
    end
    return query
end

local request = http.get("http://" .. HOST .. ":" .. HTTP_PORT .. "/" .. MESSAGE .. "?" .. generateQueryString(files))

print("Requesting main files...")

local function writeToFile(path, content)
    local file = fs.open(path, "w")
    file.write(content)
    file.close()
end

if request then
    local response = request.readAll()

    response = textutils.unserializeJSON(response)
    
    for path, content in pairs(response) do
        writeToFile(path, content)
    end

    request.close()

    term.clear()
    term.setCursorPos(1, 1)
    shell.run("manager", HOST, HTTP_PORT, WS_PORT)
else
    print("Failed to connect to server")
end