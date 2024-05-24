function table.copy(tbl)
    local copy = {}

    setmetatable(copy, debug.getmetatable(tbl))

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = table.copy(v)
        else
            copy[k] = v
        end
    end

    return copy
end

function table.merge(source, target)
    for key, value in pairs(source) do
        target[key] = value
    end

    return target
end

function table.deepMerge(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k] or false) == "table" then
            table.deepMerge(target[k], v)
        else
            target[k] = v
        end
    end
    return target
end

function table.tostring(tbl)
    local str = "{"

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            str = str .. k .. "=" .. table.tostring(v) .. ","
        else
            str = str .. k .. "=" .. v .. ","
        end
    end

    return str:sub(1, -2) .. "}"
end

function table.pack(...)
    return { n = select("#", ...), ... }
end

function table.unpack(tbl, i, j)
    return unpack(tbl, i or 1, j or tbl.n or #tbl)
end

function table.isEmpty(tbl)
    return next(tbl) == nil
end

function table.hasKey(tbl, key)
    return tbl[key] ~= nil
end

function table.contains(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end

    return false
end

function table.sanitise(tbl)
    local dest = {}

    for k, v in pairs(tbl) do
        local key = k
        local value = v
        local k_mt = getmetatable(k)
        local v_mt = getmetatable(v)

        if k_mt and k_mt.toTable then
            key = k.toTable(k)
        end

        if v_mt and v_mt.toTable then
            value = v.toTable(v)
        end

        dest[k] = v
    end

    return dest
end