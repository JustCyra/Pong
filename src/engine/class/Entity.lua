--- @class Entity.class : Object.class
--- @field protected _parent Object.class
local entity_class = setmetatable({}, Object)
entity_class.__index = entity_class
entity_class._parent = Object

--- @class Entity.setters : Object.setters
--- @field protected _parent Object.setters
local entity_unfinished = setmetatable({}, Object.getSettersClass())
entity_unfinished.__index = entity_unfinished
entity_unfinished._parent = Object.getSettersClass()

--- @class Entity : Object
--- @field protected _parent Object
--- @field public _type? 'entity'
--- 
--- @field public vel Vector2
--- @field public acceleration integer
--- @field public moveInputs? { right?: string[], left?: string[], up?: string[], down?: string[] }
---
--- @field public flags? EntityFlags 
---
--- @field public load? fun(self: self)
--- @field public update? fun(self: self, delta: number)
--- @field public draw? fun(self: self)
local entity = setmetatable({} --[[@as Entity]], Object.getInstanceClass())
entity.__index = entity
entity._type = 'entity'
entity._parent = Object.getInstanceClass()

local format = 'Entity[%s] | Pos: %s'

--- Create a new instance of `Entity`
--- @param id Identifer
--- @return Entity.setters entity_unfinished
function entity_class.new(id)
    return setmetatable({ id = id, flags = {}, vel = Vectors.vec2() }, entity_unfinished)
end

--- Get methods used for setting up an `Entity`
--- @return Entity.setters
function entity_class.getSettersClass()
    return entity_unfinished
end

--- Get methods used by `Entity` instances
--- @return Entity
function entity_class.getInstanceClass()
    return entity
end

--- @param self Entity.setters|Entity
--- @param renderType ObjectRenderType
--- @return Entity.setters entity_unfinished
function entity_unfinished:setRenderType(renderType)
    return entity_unfinished._parent.setRenderType(self, renderType) --[[@as Entity.setters]]
end

--- @param self Entity.setters|Entity
--- @param x_or_vec number|Vector2|nil
--- @param y number?
--- @return self entity_unfinished
function entity_unfinished:setPos(x_or_vec, y)
    return entity_unfinished._parent.setPos(self, x_or_vec, y) --[[@as self]]
end

--- @param self Entity.setters|Entity
--- @param x_or_vec number|Vector2|nil
--- @param y number?
--- @return self entity_unfinished
function entity_unfinished:setSize(x_or_vec, y)
    return entity_unfinished._parent.setSize(self, x_or_vec, y) --[[@as self]]
end

--- Set and enable/disable instances Collision
--- If `x_or_vec` is `nil`, `entity.size` is used as an argument
--- @param self Entity.setters|Entity
--- @param x_or_vec number|Vector2|nil
--- @param y number?
--- @return self entity_unfinished
function entity_unfinished:setCollision(x_or_vec, y)
    return entity_unfinished._parent.setCollision(self, x_or_vec, y) --[[@as self]]
end

--- @param self Entity.setters|Entity
--- @param acceleration any
--- @return self entity_unfinished
function entity_unfinished:setAcceleration(acceleration)
    self.acceleration = acceleration
    return self --[[@as Entity.setters]]
end

--- Sets the movement keys for this `entity` and marks it as a player `entity`
--- @param self Entity.setters|Entity
--- @param right string[]?
--- @param left string[]?
--- @param up string[]?
--- @param down string[]?
--- @return self entity_unfinished
function entity_unfinished:setMoveInputs(right, left, up, down)
    if right or left or up or down then
        self:setFlags('is_cpu', false)
        self.moveInputs = {
            right = right,
            left = left,
            up = up,
            down = down
        }
    else
        self:setFlags('is_cpu', true)
        self.moveInputs = nil
    end
    return self --[[@as Entity.setters]]
end

--- @param self Entity.setters|Entity
--- @param flags EntityFlags|EntityFlag
--- @param state boolean?
--- @return self entity_unfinished
function entity_unfinished:setFlags(flags, state)
    return entity_unfinished._parent.setFlags(self, flags --[[@as ObjectFlags|ObjectFlag]], state) --[[@as self]]
end

--- @param self Entity.setters|Entity
--- @param components ComponentList?
--- @return self entity_unfinished
function entity_unfinished:setComponents(components)
    return entity_unfinished._parent.setComponents(self, components) --[[@as self]]
end

--- Finishes creation of `Entity` instance
--- @param self Entity.setters
--- @return Entity
function entity_unfinished:create()
    assert(self.renderType and self.pos and self.size and self.acceleration, string.format(
        '[ENTITY]: Cannot create Entity "%s" as it is missing properties!\n%s (%s), %s (%s), %s (%s), %s (%s)',
        self.id:toString(),
        'renderType', self.renderType,
        'pos', self.pos,
        'size', self.size,
        'acceleration', self.acceleration
    ))

    --- @diagnostic disable-next-line: cast-type-mismatch
    --- @cast self Entity
    self._deleted = false
    Registry:register(setmetatable(self, entity))
    return self
end

--- Remove this instance of `Entity`
--- @return nil
function entity:delete()
    return self._parent.delete(self)
end

--- @return boolean
--- @nodiscard
function entity:exists()
    return self._parent.exists(self)
end

--- @return string
function entity:toString()
    return string.format(format, self.id:toString(), self.pos:toString())
end

--- @param renderType ObjectRenderType
--- @return self entity
function entity:setRenderType(renderType)
    return entity_unfinished.setRenderType(self, renderType) --[[@as self]]
end

--- @param x_or_vec number|Vector2|nil
--- @param y number?
--- @return self entity
function entity:setPos(x_or_vec, y)
    return entity_unfinished.setPos(self, x_or_vec, y) --[[@as self]]
end

--- @param x_or_vec number|Vector2|nil
--- @param y number?
--- @return self entity
function entity:setSize(x_or_vec, y)
    return entity_unfinished.setSize(self, x_or_vec, y) --[[@as self]]
end

--- Set and enable/disable instances Collision
--- If `x_or_vec` is `nil`, `entity.size` is used as an argument
--- @param x_or_vec number|Vector2|nil
--- @param y number?
--- @return self entity
function entity:setCollision(x_or_vec, y)
    return entity_unfinished.setCollision(self, x_or_vec, y) --[[@as self]]
end
--- Set instances Acceleration
--- @param acceleration any
--- @return self entity
function entity:setAcceleration(acceleration)
    return entity_unfinished.setAcceleration(self, acceleration) --[[@as self]]
end

--- Sets the movement keys for this `entity` and marks it as a player `entity`
--- @param right string[]?
--- @param left string[]?
--- @param up string[]?
--- @param down string[]?
function entity:setMoveInputs(right, left, up, down)
    return entity_unfinished.setMoveInputs(self, right, left, up, down) --[[@as self]]
end

--- @param flags EntityFlags|EntityFlag
--- @param state boolean?
--- @return self entity
function entity:setFlags(flags, state)
    return entity_unfinished.setFlags(self, flags, state) --[[@as self]]
end

--- @param components ComponentList?
--- @return self entity
function entity:setComponents(components)
    return entity_unfinished.setComponents(self, components) --[[@as self]]
end

-- --- Get instances Flags
-- --- @param flag EntityFlag? If specified, only gets that flag
-- --- @return EntityFlags|true|nil
-- --- @nodiscard
-- function entity:getFlags(flag)
--     --- @cast flag ObjectFlag?
--     return self._parent.getFlags(self, flag) --[[@as EntityFlags|true|nil]]
-- end

--- Get instances Components
--- @param id ComponentID? If specified, only gets that component
--- @return ComponentList|any|nil
--- @nodiscard
function entity:getComponents(id)
    return self._parent.getComponents(self, id)
end

--- Get instances Custom Data Component by `key`
--- @param key string?
--- @return any?
--- @nodiscard
function entity:getCustomData(key)
    return self._parent.getCustomData(self, key)
end

--- Gets this instance Translation Key
--- @return string
function entity:getTranslationKey()
    return self._parent.getTranslationKey(self)
end

--- Gets a point where the `object` origin is
--- @param offset_or_x number|Vector2|nil Adds this offset to the result value
--- @param y number? Adds this offset to the result value
--- @return Vector2
function entity:getOriginPoint(offset_or_x, y)
    return self._parent.getOriginPoint(self, offset_or_x, y)
end

--- Gets a center point of the `object`
--- @return Vector2
function entity:getCenteredOriginPoint()
    return self._parent.getCenteredOriginPoint(self)
end

--- Gets a center point of the `object` via collision instead of size
--- @return Vector2?
function entity:getCenteredCollisionPoint()
    return self._parent.getCenteredCollisionPoint(self)
end

--- Check if this `object` is colliding with another `object`
--- @param target Object
--- @param offset Vector2?
--- @return boolean
function entity:isCollidingWith(target, offset)
    return self._parent.isCollidingWith(self, target, offset)
end

--- @param direction string[]?
--- @return boolean
local function wasPressed(direction)
    local result = false
    if direction and #direction > 0 then
        for _, value in ipairs(direction) do
            if love.keyboard.isDown(value) then
                result = true
                break
            end
        end
    end
    return result
end

--- Check if horizontal movement should be applied
--- @return -1|1|nil
function entity:checkHorizontalMovement()
    local result
    if not self.flags.is_cpu and self.moveInputs then
        if wasPressed(self.moveInputs.right) then
            result = 1
        elseif wasPressed(self.moveInputs.left) then
            result = -1
        end
    end
    local custom = self:getComponents(Components.types.engine_apply_horizontal_movement)
    return custom and type(custom) == 'function' and custom(self) or result
end

--- Check if vertical movement should be applied
--- @return -1|1|nil
function entity:checkVerticalMovement()
    local result
    if not self.flags.is_cpu and self.moveInputs then
        if wasPressed(self.moveInputs.up) then
            result = 1
        elseif wasPressed(self.moveInputs.down) then
            result = -1
        end
    end
    local custom = self:getComponents(Components.types.engine_apply_vertical_movement)
    return custom and type(custom) == 'function' and custom(self) or result
end

--- @param self Entity
--- @param offset Vector2
--- @return boolean collided, Vector2 adjustment
local function adjust_position_on_collision(self, offset)
    local collided = false
    local adjustment = { x = 0, y = 0 }

    Registry:forEach({'object', 'entity'}, function(instance)
        if self == instance or not instance.collision then
            return
        end

        if self:isCollidingWith(instance, offset) then
            collided = true
            -- Adjust position to be right at the edge of the collided object
            if offset.x ~= 0 then
                if offset.x > 0 then
                    adjustment.x = instance.pos.x - (self.pos.x + self.collision.x)
                else
                    adjustment.x = (instance.pos.x + instance.collision.x) - self.pos.x
                end
            end
            if offset.y ~= 0 then
                if offset.y > 0 then
                    adjustment.y = instance.pos.y - (self.pos.y + self.collision.y)
                else
                    adjustment.y = (instance.pos.y + instance.collision.y) - self.pos.y
                end
            end
            return true
        end
    end)

    return collided, adjustment
end

--- Move this `entity` in a direction
--- @param horizontal -1|1|nil
--- @param vertical -1|1|nil
--- @param delta number
--- @return self entity
function entity:move(horizontal, vertical, delta)
    local vel = self.vel:copy()

    if horizontal then
        if vel.x < 0 then
            vel.x = vel.x + self.acceleration * 2 * delta * horizontal
        else
            vel.x = vel.x + self.acceleration * delta * horizontal
        end
    else
        if vel.x > 0 then
            vel.x = math.max(0, vel.x - 2000 * delta)
        elseif vel.x < 0 then
            vel.x = math.min(0, vel.x + 2000 * delta)
        end
    end

    if vertical then
        if vel.y > 0 then
            vel.y = vel.y - self.acceleration * 2 * delta * vertical
        else
            vel.y = vel.y - self.acceleration * delta * vertical
        end
    else
        if vel.y > 0 then
            vel.y = math.max(0, vel.y - 2000 * delta)
        elseif vel.y < 0 then
            vel.y = math.min(0, vel.y + 2000 * delta)
        end
    end

    local multiplier = horizontal and vertical and 0.7 or 1.0
    vel:clamp(-self.acceleration / 5 * multiplier, self.acceleration / 5 * multiplier)

    local diff_pos = vel * delta
    local future_pos = self.pos + diff_pos

    local collided_x, adjustment_x = adjust_position_on_collision(self, {x = diff_pos.x, y = 0})
    local collided_y, adjustment_y = adjust_position_on_collision(self, {x = 0, y = diff_pos.y})

    if collided_x then
        vel.x = 0
        future_pos.x = self.pos.x + adjustment_x.x
    end

    if collided_y then
        vel.y = 0
        future_pos.y = self.pos.y + adjustment_y.y
    end

    self.pos:set(future_pos)
    self.vel:set(vel)

    return self
end

function entity:updatePosition(delta)
    self:move(self:checkHorizontalMovement(), self:checkVerticalMovement(), delta)
end

function entity:update(delta)
    self:updatePosition(delta)
end

function entity:draw()
    self._parent.draw(self)
end

-- setmetatable(entity_class, {
--     --- Create a new instance of `Entity`
--     --- @param id Identifer
--     --- @return Entity.setters entity_unfinished
--     __call = function (_, id)
--         return entity_class.new(id)
--     end
-- })
setmetatable(entity, {
    __tostring = entity.toString
})

return entity_class