--- @class Registry
--- @field list table<RegistryType, table<string, RegistryInstanceType> >
local registry = {
    list = {}
}

--- Register a new entry in the `registry`
--- @param instance RegistryInstanceType
--- @return RegistryInstanceType instance
function registry:register(instance)
    assert(instance.id, '[REGISTRY]: Cannot register an instance as the `id` was missing!')

    if not self.list[instance.type] then
        self.list[instance.type] = {}
    end

    self.list[instance.type][instance.id:toString()] = instance
    return instance
end

--- Remove a registered entry from the `registry` list
--- @param instance RegistryInstanceType
function registry:unregister(instance)
    assert(self.list[instance.type], '[REGISTRY]: Cannot unregister from a registry type (' .. instance.type .. ') that was not used already!')

    for key, value in pairs(self.list[instance.type]) do
        if value == instance then
            self.list[instance.type][key] = nil
        end
    end
end

--- Apply a function for each registered entry
--- @param key RegistryType|(RegistryType)[]|nil
--- @param func fun(instance: RegistryInstanceType): break: true?
function registry:forEach(key, func)
    if key then
        if type(key) == 'table' then
            for _, k in ipairs(key) do
                for _, value in pairs(self.list[k]) do
                    if func(value) then
                        break
                    end
                end
            end
        else
            for _, value in pairs(self.list[key]) do
                if func(value) then
                    break
                end
            end
        end
    else
        for _, list in pairs(self.list) do
            for _, value in pairs(list) do
                if func(value) then
                    break
                end
            end
        end
    end
end

-- function registry:load()
--     self:forEach(nil, function (instance)
--         --- @diagnostic disable-next-line: param-type-mismatch
--         if instance.load then instance:load() end
--         local load = instance:getComponent(Components.types.love_load)
--         if load and type(load) == 'function' then
--             load(instance)
--         end
--     end)
-- end

function registry:update(delta)
    self:forEach(nil, function (instance)
        --- @diagnostic disable-next-line: param-type-mismatch
        if instance.update then instance:update(delta) end
        local update = instance:getComponent(Components.types.love_update)
        if update and type(update) == 'function' then
            update(instance, delta)
        end
    end)
end

function registry:draw()
    self:forEach(nil, function (instance)
        --- @diagnostic disable-next-line: param-type-mismatch
        if instance.draw then instance:draw() end
        local draw = instance:getComponent(Components.types.love_draw)
        if draw and type(draw) == 'function' then
            draw(instance)
        end
    end)
end

return registry