local core = {}

core.playerData = {}
core.worldData = {
    dimensions = {},
    players = {}
}
core.totalRuntime = 0
core.launchTime = os.time()
core.dataPath = "data/world.json"

local PLAYER_DATA = {
    id = -1,
    lastSeen = 0,
    position = Vector.new(),
    direction = Vector.new(),
    eyeHeight = 0,
    dimension = "overworld"
}

local DIMENSION_DATA = {
    paths = {}
}

function core.Initialize()
    core.playerData = {}
    core.worldData = {}
    core.totalRuntime = 0
    core.launchTime = os.time()
end

function core.Load()
    local file = fs.open(core.dataPath, "r")

    if file then
        core.worldData = textutils.unserialize(file.readAll())
        file.close()
    end
end

function core.Save()
    local file = fs.open(core.dataPath, "w")

    if file then
        file.write(textutils.serialize(core.worldData))
        file.close()
    end
end

function core.GetPlayerData(player)
    if not core.playerData[player] then
        core.playerData[player] = PLAYER_DATA
    end

    return core.playerData[player]
end

function core.SetPlayerData(player, data)
    local data = core.GetPlayerData(player)

    data.lastSeen = os.time()
    data.position:Set(data.x, data.y, data.z)
    data.direction:Set(data.yaw, data.pitch)
    data.eyeHeight = data.eyeHeight
    data.dimension = data.dimension

    core.playerData[player] = data
end

function core.updateWorldData(data)
    if not core.worldData.dimensions[data.dimension] then
        core.worldData.dimensions[data.dimension] = DIMENSION_DATA
    end

    if not core.worldData.players[data.player] then
        local id = #core.worldData.players + 1

        table.insert(core.worldData.players, {
            name = data.player,
            color = Color.new():Random()
        })

        core.SetPlayerData(data.player, data)
        core.playerData.id = id
    end

    local playerId = core.GetPlayerData(player).id

    if not core.worldData.dimensions[data.dimension].paths[playerId] then
        core.worldData.dimensions[data.dimension].paths[playerId] = {}
    end

    table.insert(core.worldData.dimensions[data.dimension].paths[playerId], Vector.new(data.x, data.y, data.z))
end