local vectors   = require "src.engine.class.vectors"
local registry  = require "src.engine.class.registry"

--- @class Object
--- @field created boolean
--- @field type RegistryType
--- @field id Identifer
---
--- @field renderType ObjectRenderType
---
--- @field pos Vector2
--- @field size Vector2
--- @field collision Vector2?
---
--- @field components ComponentList?
---
--- @field load fun(self: self)?
--- @field update fun(self: self, delta: number)?
--- @field draw fun(self: self)?
local object = {}
object.__index = object
object.__tostring = object.toString

local format = 'Object[%s] | Pos: %s'

--- Create a new instance of `object`
--- @param id Identifer
--- @return Object object
function object.new(id)
    return setmetatable({ created = false, id = id, }, object)
end

--- Finilize creation of a new `object`
--- @return self object
function object:create()
    assert(self.renderType and self.pos and self.size, string.format(
        '[OBJECT]: Cannot create Object "%s" as it is missing properties!\n%s (%s), %s (%s), %s (%s)',
        self.id:toString(),
        'renderType', self.renderType,
        'pos', self.pos,
        'size', self.size
    ))
    self.created = true
    self.type = 'object'
    registry:register(self)
    return self
end

--- Remove this instance of `object`
--- @return nil
function object:delete()
    registry:unregister(self)
    self = nil
    return nil
end

--- @return string
function object:toString()
    return string.format(format, self.id:toString(), self.pos:toString())
end

--- Gets this instance Translation Key
--- @return string
function object:getTranslationKey()
    return self.id:getOrCreateTranslationKey(self.type)
end

--- Set instances Render Type
--- @param renderType ObjectRenderType
--- @return self object
function object:setRenderType(renderType)
    self.renderType = renderType
    return self
end

--- Set instances Position
--- @param x_or_vec (number|Vector2)?
--- @param y number?
--- @return self object
function object:setPos(x_or_vec, y)
    if type(x_or_vec) == "number" then
        self.pos = vectors.vec2(x_or_vec, y)
    else
        self.pos = x_or_vec--[[@as Vector2]]
    end
    return self
end

--- Set instances Size
--- @param x_or_vec (number|Vector2)?
--- @param y number?
--- @return self object
function object:setSize(x_or_vec, y)
    if type(x_or_vec) == "number" then
        self.size = vectors.vec2(x_or_vec, y)
    else
        self.size = x_or_vec--[[@as Vector2]]
    end
    return self
end

--- Set and enable/disable instances Collision
--- If `x_or_vec` is `nil`, `object.size` is used as an argument
--- @param x_or_vec (number|Vector2)?
--- @param y number?
--- @return self object
function object:setCollision(x_or_vec, y)
    if not x_or_vec and self.size then
        self.collision = self.size:copy()
    elseif type(x_or_vec) == "number" then
        self.collision = vectors.vec2(x_or_vec, y)
    else
        self.collision = x_or_vec--[[@as Vector2]]
    end

    if self.collision and self.collision.x == 0 and self.collision.y == 0 then
        self.collision = nil
    end

    return self
end

--- Set instances custom Data
--- @param components ComponentList?
--- @return self object
function object:setComponents(components)
    self.components = components
    return self
end

--- Get instances Component by `id`
--- @param id ComponentID
--- @return any|ComponentList|nil
--- @nodiscard
function object:getComponent(id)
    if self.components then
        return id and self.components[id] or self.components
    end
end

--- Get instances Custom Data Component by `key`
--- @param key string?
--- @return any?
--- @nodiscard
function object:getCustomData(key)
    local component_custom_data = Components.types.engine_custom_data
    if not (self.components and self.components[component_custom_data]) then
        return
    end

    local custom_data = self.components[component_custom_data]
    if key and custom_data[key] then
        return custom_data[key]
    else
        return custom_data
    end
end

--- Gets a point where the `object` origin is
--- @param offset_or_x (Vector2|number)? Adds this offset to the result value
--- @param y number? Adds this offset to the result value
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

--- Gets a center point of the `object`
--- @return Vector2
function object:getCenteredOriginPoint()
    return self:getOriginPoint(self.pos + self.size / 2)
end

--- Gets a center point of the `object` via collision instead of size
--- @return Vector2?
function object:getCenteredCollisionPoint()
    if self.collision then
        return self:getOriginPoint(self.pos + self.collision / 2)
    end
end

--- Check if this `object` is colliding with another `object`
--- @param target Object
--- @param offset Vector2?
--- @return boolean
function object:isCollidingWith(target, offset)
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

return object