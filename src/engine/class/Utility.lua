--- @class Utility
local utility = {}

--- Copy a `table` that is not nested, without a reference
--- @param tbl table
--- @param copy_mt? boolean
--- @return table
function utility.copyTable(tbl, copy_mt)
    local result = {}

    for key, value in pairs(tbl) do
        if type(key) == 'string' and key:sub(1, 2) ~= '__' then
            result[key] = value
        end
    end

    if copy_mt then
        local mt = getmetatable(tbl)
        if mt then
            setmetatable(result, mt)
        end
    end

    return result
end

--- Copy a `table` that is nested, without a reference
--- @param tbl table
--- @param copy_mt? boolean
--- @return table
function utility.copyTableNested(tbl, copy_mt)
    local result = {}

    for key, value in pairs(tbl) do
        if type(key) == 'string' and key:sub(1, 2) ~= '__' then
            if type(value) == 'table' then
                result[key] = utility.copyTableNested(value, copy_mt)
            else
                result[key] = value
            end
        end
    end

    if copy_mt then
        local mt = getmetatable(tbl)
        if mt then
            setmetatable(result, mt)
        end
    end

    return result
end

return utility