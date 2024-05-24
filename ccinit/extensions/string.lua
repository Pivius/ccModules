function string.split(input, separator)
    if separator == "" then
        return { input }
    end

    local dest = {}
    local pos = 1

    for i = 1, #input do
        local start, stop = string.find(input, separator, pos)

        if start then
            table.insert(dest, string.sub(input, pos, start - 1))
            pos = stop + 1
        else
            table.insert(dest, string.sub(input, pos))
            break
        end
    end

    return dest
end

function string.join(input, separator)
    return table.concat(input, separator)
end

