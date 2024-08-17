--- @class Components
--- @field list ComponentList
local components = {
    list = {},
    types = {
        love_load = 'love:load',
        love_update = 'love:update',
        love_draw = 'love:draw',

        engine_apply_horizontal_movement = 'engine:apply_horizontal_movement',
        engine_apply_vertical_movement = 'engine:apply_vertical_movement',
        engine_custom_data = 'engine:custom_data',
    },
}
components.__index = components

--- Create a new Component Set
--- @return Components
function components.new()
    return setmetatable({ list = {} }, components)
end

--- Finish creating a Component Set
--- @return ComponentList
--- @nodiscard
function components:create()
    return Utility.copyTableNested(self.list, true)
end

--- Add an `load` Component from `love2D`
--- @param func fun(self: RegistryInstanceType)
--- @return self
function components:love_load(func)
    self.list[self.types.love_load] = func
    return self
end

--- Add an `update` Component from `love2D`
--- @param func fun(self: RegistryInstanceType, delta: number)
--- @return self
function components:love_update(func)
    self.list[self.types.love_update] = func
    return self
end

--- Add an `draw` Component from `love2D`
--- @param func fun(self: RegistryInstanceType)
--- @return self
function components:love_draw(func)
    self.list[self.types.love_draw] = func
    return self
end

--- Add an `apply_horizontal_movement` Component from `engine`
--- @param func fun(self: Entity): -1|1|false
--- @return self
function components:engine_apply_horizontal_movement(func)
    self.list[self.types.engine_apply_horizontal_movement] = func
    return self
end

--- Add an `apply_vertical_movement` Component from `engine`
--- @param func fun(self: Entity): -1|1|false
--- @return self
function components:engine_apply_vertical_movement(func)
    self.list[self.types.engine_apply_vertical_movement] = func
    return self
end

--- Add an `custom_data` Component from `engine`
--- @param data table
--- @return self
function components:engine_custom_data(data)
    self.list[self.types.engine_custom_data] = data
    return self
end

setmetatable(components, {
    --- Create a new Component Set
    --- @return Components
    __call = function (_)
        return components.new()
    end,
})

return components