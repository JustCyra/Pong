--- @class Entity : Object
--- @field __parent Object
--- @field type 'entity'
--- 
--- @field vel Vector2
--- @field acceleration number
--- @field moveInputs { right: string[]?, left: string[]?, up: string[]?, down: string[]? }?
---
--- @field flags EntityFlags? 
---
--- @field load fun(self: self)?
--- @field update fun(self: self, delta: number)?
--- @field draw fun(self: self)?
local entity = setmetatable({}, Object)
entity.__index = entity
entity.__parent = Object

local format = 'Entity[%s] | Pos: %s'

--- Create a new instance of `entity`
--- @param id Identifer
--- @return Entity entity
function entity.new(id)
    return setmetatable({ created = false, id = id, vel = Vectors.vec2() }, entity)
end

--- Finilize creation of a new `entity`
--- @return self entity
function entity:create()
    assert(self.renderType and self.pos and self.size and self.acceleration, string.format(
        '[ENTITY]: Cannot create Entity "%s" as it is missing properties!\n%s (%s), %s (%s), %s (%s), %s (%s)',
        self.id:toString(),
        'renderType', self.renderType,
        'pos', self.pos,
        'size', self.size,
        'acceleration', self.acceleration
    ))
    self.created = true
    self.type = 'entity'
    Registry:register(self)
    return self
end

--- Remove this instance of `object`
--- @return nil
function entity:delete()
    return self.__parent.delete(self)
end

--- @return string
function entity:toString()
    return string.format(format, self.id:toString(), self.pos:toString())
end

--- Gets this instance Translation Key
--- @return string
function entity:getTranslationKey()
    return self.__parent.getTranslationKey(self)
end

--- Set instances Render Type
--- @param renderType ObjectRenderType
--- @return self entity
function entity:setRenderType(renderType)
    return self.__parent.setRenderType(self, renderType) --[[@as Entity]]
end

--- Set instances Position
--- @param x_or_vec (number|Vector2)?
--- @param y number?
--- @return self entity
function entity:setPos(x_or_vec, y)
    return self.__parent.setPos(self, x_or_vec, y) --[[@as Entity]]
end

--- Set instances Size
--- @param x_or_vec (number|Vector2)?
--- @param y number?
--- @return self entity
function entity:setSize(x_or_vec, y)
    return self.__parent.setSize(self, x_or_vec, y) --[[@as Entity]]
end

--- Set and enable/disable instances Collision
--- If `x_or_vec` is `nil`, `entity.size` is used as an argument
--- @param x_or_vec (number|Vector2)?
--- @param y number?
--- @return self entity
function entity:setCollision(x_or_vec, y)
    return self.__parent.setCollision(self, x_or_vec, y) --[[@as Entity]]
end

--- Set instances Acceleration
--- @param acceleration any
--- @return self entity
function entity:setAcceleration(acceleration)
    self.acceleration = acceleration
    return self
end

--- Sets the movement keys for this `entity` and marks it as a player `entity`
--- @param right string[]?
--- @param left string[]?
--- @param up string[]?
--- @param down string[]?
function entity:setMoveInputs(right, left, up, down)
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
    return self
end

--- Set instances Flags
--- @param flags EntityFlags|EntityFlag
--- @param state boolean?
--- @return self entity
function entity:setFlags(flags, state)
    return self.__parent.setFlags(self, flags --[[@as ObjectFlags|ObjectFlag]], state) --[[@as Entity]]
end

--- Get instances Flags
--- @param flag EntityFlag?
--- @return EntityFlags|true|nil
--- @nodiscard
function entity:getFlags(flag)
    return self.__parent.getFlags(self, flag --[[@as ObjectFlag?]]) --[[@as EntityFlags|true|nil]]
end

--- Set instances Components
--- @param components ComponentList?
--- @return self entity
function entity:setComponents(components)
    return self.__parent.setComponents(self, components) --[[@as Entity]]
end

--- Get instances Components
--- @param id ComponentID? If specified, only gets that component
--- @return ComponentList|any|nil
--- @nodiscard
function entity:getComponents(id)
    return self.__parent.getComponents(self, id)
end

--- Get instances Custom Data Component by `key`
--- @param key string?
--- @return any?
--- @nodiscard
function entity:getCustomData(key)
    return self.__parent.getCustomData(self, key)
end

--- Gets a point where the `object` origin is
--- @param offset_or_x (Vector2|number)? Adds this offset to the result value
--- @param y number? Adds this offset to the result value
--- @return Vector2
function entity:getOriginPoint(offset_or_x, y)
    return self.__parent.getOriginPoint(self, offset_or_x, y)
end

--- Gets a center point of the `object`
--- @return Vector2
function entity:getCenteredOriginPoint()
    return self.__parent.getCenteredOriginPoint(self)
end

--- Gets a center point of the `object` via collision instead of size
--- @return Vector2?
function entity:getCenteredCollisionPoint()
    return self.__parent.getCenteredCollisionPoint(self)
end

--- Check if this `object` is colliding with another `object`
--- @param target Object
--- @param offset Vector2?
--- @return boolean
function entity:isCollidingWith(target, offset)
    return self.__parent.isCollidingWith(self, target, offset)
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
--- @return (-1|1)?
function entity:checkHorizontalMovement()
    local result
    if not self:getFlags('is_cpu') and self.moveInputs then
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
--- @return (-1|1)?
function entity:checkVerticalMovement()
    local result
    if not self:getFlags('is_cpu') and self.moveInputs then
        if wasPressed(self.moveInputs.up) then
            result = 1
        elseif wasPressed(self.moveInputs.down) then
            result = -1
        end
    end
    local custom = self:getComponents(Components.types.engine_apply_vertical_movement)
    return custom and type(custom) == 'function' and custom(self) or result
end

--- @param entity Entity
--- @param offset Vector2
--- @return boolean collided, Vector2 adjustment
local function adjust_position_on_collision(entity, offset)
    local collided = false
    local adjustment = { x = 0, y = 0 }

    Registry:forEach({'object', 'entity'}, function(instance)
        if entity == instance or not instance.collision then
            return
        end

        if entity:isCollidingWith(instance--[[@as Object|Entity]], offset) then
            collided = true
            -- Adjust position to be right at the edge of the collided object
            if offset.x ~= 0 then
                if offset.x > 0 then
                    adjustment.x = instance.pos.x - (entity.pos.x + entity.collision.x)
                else
                    adjustment.x = (instance.pos.x + instance.collision.x) - entity.pos.x
                end
            end
            if offset.y ~= 0 then
                if offset.y > 0 then
                    adjustment.y = instance.pos.y - (entity.pos.y + entity.collision.y)
                else
                    adjustment.y = (instance.pos.y + instance.collision.y) - entity.pos.y
                end
            end
            return true
        end
    end)

    return collided, adjustment
end

--- Move this `entity` in a direction
--- @param horizontal (-1|1)?
--- @param vertical (-1|1)?
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
    self.__parent.draw(self)
end

entity.__tostring = entity.toString

return entity