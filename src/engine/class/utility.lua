--- @class Utility
local util = {}

--- Copy a `table` that is not nested, without a reference
--- @param tbl table
--- @return table
function util.copyTable(tbl)
    local result = {}
    for key, value in pairs(tbl) do
        result[key] = value
    end
    return result
end

--- Copy a `table` that is nested, without a reference
--- @param tbl table
--- @param copy_mt? boolean
--- @return table
function util.copyTableNested(tbl, copy_mt)
    local result = {}

    for key, value in pairs(tbl) do
        if type(value) == 'table' then
            result[key] = util.copyTableNested(value, copy_mt)
        else
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

return util