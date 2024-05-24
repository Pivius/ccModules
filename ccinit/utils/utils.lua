local utils = {}

function utils.printC(text, color)
    local old_color = term.getTextColor()

    term.setTextColor(color)
    print(text)
    term.setTextColor(old_color)
end

function utils.tableToJSON(tbl)
    local dest = table.sanitise(tbl)

    return textutils.serializeJSON(dest) or "{}"
end

function utils.JSONtoTable(json)
    assert(type(json) == "string", "Expected string as argument")

    local tbl = textutils.unserializeJSON(json) or {}

    --Desanitation should happen here

    return tbl
end

function utils.printTable(tbl, delay)
    delay = delay or 0

    for k, v in pairs(tbl) do
        print(tostring(k) .. ": " .. tostring(v))

        if delay > 0 then
            sleep(delay)
        end
    end
end

return utils