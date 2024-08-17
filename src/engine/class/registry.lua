--- @class Registry
--- @field list table<RegistryType, table<string, RegistryInstanceType>>
local registry = {
    list = {}
}

--- Register a new entry in the `registry`
--- @param instance RegistryInstanceType
--- @return RegistryInstanceType instance
function registry:register(instance)
    assert(instance.id, '[REGISTRY]: Cannot register an instance as the `id` was missing!')

    if not self.list[instance._type] then
        self.list[instance._type] = {}
    end

    self.list[instance._type][instance.id:toString()] = instance
    return instance
end

--- Remove a registered entry from the `registry` list
--- @param instance RegistryInstanceType
function registry:unregister(instance)
    assert(self.list[instance._type], '[REGISTRY]: Cannot unregister from a registry type (' .. instance._type .. ') that was not used already!')

    for key, value in pairs(self.list[instance._type]) do
        if value == instance then
            self.list[instance._type][key] = nil
        end
    end
end

--- Get a registered entry from the `registry` list by `identifier`
--- @param id Identifer|string
--- @param key? RegistryType
--- @return RegistryInstanceType? instance, RegistryType? key
function registry:getByID(id, key)
    if key then
        for _, v in pairs(self.list[key]) do
            if v.id:equals(id) then
                return v, key
            end
        end
    else
        for k, list in pairs(self.list) do
            for _, v in pairs(list) do
                if v.id:equals(id) then
                    return v, k
                end
            end
        end
    end
end

--- @param tbl table
--- @param func fun(instance: RegistryInstanceType): break: true?
--- @return boolean returned_early
local function runFunc(tbl, func)
    for _, value in pairs(tbl) do
        if func(value) then
            return true
        end
    end
    return false
end

--- Apply a function for each registered entry
--- @param key? RegistryType|(RegistryType)[]
--- @param func fun(instance: RegistryInstanceType): break: true?
function registry:forEach(key, func)
    if key then
        if type(key) == 'table' then
            for _, k in ipairs(key) do
                runFunc(self.list[k], func)
            end
        else
            runFunc(self.list[key], func)
        end
    else
        for _, list in pairs(self.list) do
            runFunc(list, func)
        end
    end
end

--- @param func function
--- @param instance RegistryInstanceType
--- @param delta? number
local function runComponentFunc(func, instance, delta)
    if func and type(func) == 'function' then
        if delta then
            func(instance, delta)
        else
            func(instance)
        end
    end
end

-- function registry:load()
--     self:forEach(nil, function (instance)
--         --- @diagnostic disable-next-line: param-type-mismatch
--         if instance.load then instance:load() end
--         runComponentFunc(instance:getComponents(Components.types.love_load), instance)
--     end)
-- end

function registry:update(delta)
    self:forEach(nil, function (instance)
        --- @diagnostic disable-next-line: param-type-mismatch
        if instance.update then instance:update(delta) end
        runComponentFunc(instance:getComponents(Components.types.love_update), instance, delta)
    end)
end

function registry:draw()
    self:forEach(nil, function (instance)
        --- @diagnostic disable-next-line: param-type-mismatch
        if instance.draw then instance:draw() end
        runComponentFunc(instance:getComponents(Components.types.love_draw), instance)
    end)
end

return registry