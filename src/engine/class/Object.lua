--- @class Object.class
--- @field protected _parent nil
local object_class = {}
object_class.__index = object_class
object_class._parent = nil

--- @class Object.setters
--- @field protected _parent nil
--- @field public id Identifer
local object_unfinished = {}
object_unfinished.__index = object_unfinished
object_unfinished._parent = nil

--- @class Object
--- @field protected _parent nil
--- @field public _type? 'object'
--- @field public _deleted boolean
--- @field public id Identifer
---
--- @field public renderType ObjectRenderType
---
--- @field public pos Vector2
--- @field public size Vector2
--- @field public collision? Vector2
---
--- @field public flags? ObjectFlags
--- @field protected components? ComponentList
---
--- @field public load? fun(self: self)
--- @field public update? fun(self: self, delta: number)
--- @field public draw? fun(self: self)
local object = {}
object.__index = object
object._parent = 'object'
object._type = 'object'

local format = 'Object[%s] | Pos: %s'

--- Create a new instance of `Object`
--- @param id Identifer
--- @return Object.setters object_unfinished
function object_class.new(id)
    return setmetatable({ id = id, flags = {} }, object_unfinished)
end

--- Get methods used for setting up an `Object`
--- @return Object.setters
function object_class.getSettersClass()
    return object_unfinished
end

--- Get methods used by `Object` instances
--- @return Object
function object_class.getInstanceClass()
    return object
end

--- @param renderType ObjectRenderType
--- @return self object_unfinished
function object_unfinished:setRenderType(renderType)
    self.renderType = renderType
    return self
end

--- @param x_or_vec? number|Vector2
--- @param y? number
--- @return self object_unfinished
function object_unfinished:setPos(x_or_vec, y)
    if type(x_or_vec) == "number" then
        self.pos = Vectors.vec2(x_or_vec, y)
    else
        --- @cast x_or_vec Vector2
        self.pos = x_or_vec
    end
    return self
end

--- @param x_or_vec? number|Vector2
--- @param y? number
--- @return self object_unfinished
function object_unfinished:setSize(x_or_vec, y)
    if type(x_or_vec) == "number" then
        self.size = Vectors.vec2(x_or_vec, y)
    else
        --- @cast x_or_vec Vector2
        self.size = x_or_vec
    end
    return self
end

--- Set and enable/disable instances Collision<br>
--- If `x_or_vec` is `nil`, `object.size` is used as an argument
--- @param x_or_vec? number|Vector2
--- @param y? number
--- @return self object_unfinished
function object_unfinished:setCollision(x_or_vec, y)
    if not x_or_vec and self.size then
        self.collision = self.size:copy()
    elseif type(x_or_vec) == "number" then
        self.collision = Vectors.vec2(x_or_vec, y)
    else
        --- @cast x_or_vec Vector2
        self.collision = x_or_vec
    end

    if self.collision and self.collision.x == 0 and self.collision.y == 0 then
        self.collision = nil
    end

    return self
end

--- @param flags ObjectFlags|ObjectFlag
--- @param state? boolean
--- @return self object_unfinished
function object_unfinished:setFlags(flags, state)
    if type(flags) == 'table' then
        self.flags = flags
    elseif type(flags) == 'string' then
        if not self.flags then
            self.flags = {}
        end
        self.flags[flags] = state
    end

    return self
end

--- @param components? ComponentList
--- @return self object_unfinished
function object_unfinished:setComponents(components)
    self.components = components
    return self
end

--- Finishes creation of `Object` instance
--- @param self Object.setters
--- @return Object
function object_unfinished:create()
    assert(self.renderType and self.pos and self.size, string.format(
        '[OBJECT]: Cannot create a new instance of "Object" (%s) as it is missing properties!\n%s (%s), %s (%s), %s (%s)',
        self.id:toString(),
        'renderType', self.renderType,
        'pos', self.pos,
        'size', self.size
    ))

    --- @diagnostic disable-next-line: cast-type-mismatch
    --- @cast self Object
    self._deleted = false
    Registry:register(setmetatable(self, object))
    return self
end

--- Remove this instance of `Object`
--- @return nil
function object:delete()
    Registry:unregister(self)
    self._deleted = true
    return nil
end

--- @return boolean
--- @nodiscard
function object:exists()
    return not self._deleted
end

--- @return string
function object:toString()
    return string.format(format, self.id:toString(), self.pos:toString())
end

--- @param renderType ObjectRenderType
--- @return self object
function object:setRenderType(renderType)
    return object_unfinished.setRenderType(self, renderType)
end

--- @param x_or_vec? number|Vector2
--- @param y? number
--- @return self object
function object:setPos(x_or_vec, y)
    return object_unfinished.setPos(self, x_or_vec, y)
end

--- @param x_or_vec? number|Vector2
--- @param y? number
--- @return self object
function object:setSize(x_or_vec, y)
    return object_unfinished.setSize(self, x_or_vec, y)
end

--- Set and enable/disable instances Collision
--- If `x_or_vec` is `nil`, `object.size` is used as an argument
--- @param x_or_vec? number|Vector2
--- @param y? number
--- @return self object
function object:setCollision(x_or_vec, y)
    return object_unfinished.setCollision(self, x_or_vec, y)
end

--- @param flags ObjectFlags|ObjectFlag
--- @param state? boolean
--- @return self object
function object:setFlags(flags, state)
    return object_unfinished.setFlags(self, flags, state)
end

--- @param components? ComponentList
--- @return self object
function object:setComponents(components)
    return object_unfinished.setComponents(self, components)
end

-- --- Get instances Flags
-- --- @return ObjectFlags|boolean|nil
-- --- @nodiscard
-- function object:getFlags()
--     if self.flags then
--         return flag and self.flags[flag] or self.flags
--     end
-- end

--- Get instances Components
--- @param id? ComponentID If specified, only gets that component
--- @return ComponentList|any|nil
--- @nodiscard
function object:getComponents(id)
    if self.components then
        return id and self.components[id] or self.components
    end
end

--- Get instances Custom Data Component by `key`
--- @param key? string
--- @return any?
--- @nodiscard
function object:getCustomData(key)
    local component_custom_data = Components.types.engine_custom_data

    if not self.components then
        return
    end

    local custom_data = self.components[component_custom_data]
    return key and custom_data[key] or custom_data
end

--- Gets this instance Translation Key
--- @return string
function object:getTranslationKey()
    return self.id:getOrCreateTranslationKey(self._type)
end

--- Gets a point where the `Object` instance origin is
--- @param offset_or_x? number|Vector2 Adds this offset to the result value
--- @param y? number Adds this offset to the result value
--- @return Vector2
function object:getOriginPoint(offset_or_x, y)
    if not offset_or_x then
        return self.pos
    end

    if offset_or_x == 'table' then
        return self.pos + offset_or_x
    end

    return self.pos:copy():add(offset_or_x, y)
end

--- Gets a center point of the `Object` instance
--- @return Vector2
function object:getCenteredOriginPoint()
    return self:getOriginPoint(self.pos + self.size / 2)
end

--- Gets a center point of the `Object` instance via collision instead of size
--- @return Vector2?
function object:getCenteredCollisionPoint()
    if self.collision then
        return self:getOriginPoint(self.pos + self.collision / 2)
    end
end

--- Check if this `Object` instance is colliding with another ``Object` instance
--- @param target Object
--- @param offset? Vector2
--- @return boolean
function object:isCollidingWith(target, offset)
    if self.flags.ignore_collisions then
        return false
    end

    offset = offset or {x = 0, y = 0}
    local x = self.pos.x + offset.x
    local y = self.pos.y + offset.y

    local a_min_x = x
    local a_max_x = x + self.collision.x
    local a_min_y = y
    local a_max_y = y + self.collision.y

    local b_min_x = target.pos.x
    local b_max_x = target.pos.x + target.collision.x
    local b_min_y = target.pos.y
    local b_max_y = target.pos.y + target.collision.y

    return a_min_x < b_max_x and a_max_x > b_min_x and
           a_min_y < b_max_y and a_max_y > b_min_y
end

function object:draw()
    if love and self.renderType == 'fill' or self.renderType == 'line' then
        love.graphics.rectangle(self.renderType, self.pos.x, self.pos.y, self.size.x, self.size.y)
    end
end

-- setmetatable(object_class, {
--     --- Create a new instance of `Object`
--     --- @param id Identifer
--     --- @return Object.setters object_unfinished
--     __call = function (_, id)
--         return object_class.new(id)
--     end
-- })
setmetatable(object, {
    __tostring = object.toString
})

return object_class