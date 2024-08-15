--- @class Vectors : table
local vectors = {}

--- @class Vector : table
local vector = {}

--- @class Vector2 : Vector
--- @field x number
--- @field y number

--- @class Vector3 : Vector2
--- @field z number?

--- @class Vector4 : Vector3
--- @field w number?

--- @alias VectorX Vector2 | Vector3 | Vector4

local format_vec2 = 'vec2[%s, %s]'
local format_vec3 = 'vec2[%s, %s, %s]'
local format_vec4 = 'vec2[%s, %s, %s, %s]'

--- @param vec VectorX
--- @param arg number|VectorX
--- @return VectorX result
local function __add(vec, arg)
    if type(arg) == 'number' then
        return vectors.vec(
            vec.x + arg,
            vec.y + arg,
            vec.z and vec.z + arg,
            vec.w and vec.w + arg
        )
    else
        return vectors.vec(
            vec.x + arg.x,
            vec.y + arg.y,
            vec.z and (vec.z + arg.z),
            vec.w and (vec.w + arg.w)
        )
    end
end

--- @param vec VectorX
--- @param arg number|VectorX
--- @return VectorX result
local function __sub(vec, arg)
    if type(arg) == 'number' then
        return vectors.vec(
            vec.x - arg,
            vec.y - arg,
            vec.z and vec.z - arg,
            vec.w and vec.w - arg
        )
    else
        return vectors.vec(
            vec.x - arg.x,
            vec.y - arg.y,
            vec.z and (vec.z - arg.z),
            vec.w and (vec.w - arg.w)
        )
    end
end

--- @param vec VectorX
--- @param arg number|VectorX
--- @return VectorX result
local function __mul(vec, arg)
    if type(arg) == 'number' then
        return vectors.vec(
            vec.x * arg,
            vec.y * arg,
            vec.z and vec.z * arg,
            vec.w and vec.w * arg
        )
    else
        return vectors.vec(
            vec.x * arg.x,
            vec.y * arg.y,
            vec.z and (vec.z * arg.z),
            vec.w and (vec.w * arg.w)
        )
    end
end

--- @param vec VectorX
--- @param arg number|VectorX
--- @return VectorX result
local function __div(vec, arg)
    if type(arg) == 'number' then
        if arg == 0 then error("Division by zero in vector division", 2) end
        return vectors.vec(
            vec.x / arg,
            vec.y / arg,
            vec.z and vec.z / arg,
            vec.w and vec.w / arg
        )
    else
        if arg.x == 0 or arg.y == 0 or (arg.z == 0 and vec.z) or (arg.w == 0 and vec.w) then
            error("Division by zero in vector division", 2)
        end
        return vectors.vec(
            vec.x / arg.x,
            vec.y / arg.y,
            vec.z and (vec.z / arg.z),
            vec.w and (vec.w / arg.w)
        )
    end
end

--- @param x number?
--- @param y number?
--- @param z number?
--- @param w number?
--- @return VectorX
local function new(x, y, z, w)
    return setmetatable({
        x = x or 0,
        y = y or 0,
        z = z,
        w = w,
    } --[[@as VectorX]], {
        __index = vector,
        __tostring = vector.toString,
        __add = __add,
        __sub = __sub,
        __mul = __mul,
        __div = __div,
        __eq = vector.equals
    })
end

--- @param x number?
--- @param y number?
--- @return Vector2 vector
--- @nodiscard
function vectors.vec2(x, y)
    return new(x or 0, y or 0)
end

--- @param x number?
--- @param y number?
--- @param z number?
--- @return Vector3 vector
--- @nodiscard
function vectors.vec3(x, y, z)
    return new(x or 0, y or 0, z or 0)
end

--- @param x number?
--- @param y number?
--- @param z number?
--- @param w number?
--- @return Vector4 vector
--- @nodiscard
function vectors.vec4(x, y, z, w)
    return new(x or 0, y or 0, z or 0, w or 0)
end

--- @param x number?
--- @param y number?
--- @param z number?
--- @param w number?
--- @return VectorX vector
--- @nodiscard
function vectors.vec(x, y, z, w)
    if w and z then
        return new(x, y, z, w)
    elseif z then
        return new(x, y, z)
    else
        return new(x, y)
    end
end

--- @return string
--- @nodiscard
function vector:toString()
    if self.w then
        return string.format(format_vec4, self:unpack())
    elseif self.z then
        return string.format(format_vec3, self:unpack())
    else
        return string.format(format_vec2, self:unpack())
    end
end

--- @param self VectorX
--- @return number x, number y, number? z, number? w
--- @nodiscard
function vector:unpack()
    return self.x, self.y, self.z, self.w
end

--- @param self VectorX
--- @return VectorX copy
--- @nodiscard
function vector:copy()
    return new(self:unpack())
end

--- @param self VectorX
--- @param func fun(index: 1|2|3|4, value: number): value: number
--- @return VectorX
function vector:applyFunc(func)
    self.x = func(1, self.x)
    self.y = func(2, self.y)
    if self.z then
        self.z = func(3, self.z)
    end
    if self.w then
        self.w = func(4, self.w)
    end

    return self
end

--- @param self VectorX
--- @param min number? Default: 0
--- @param max number? Default: 1
--- @return VectorX vector
function vector:clamp(min, max)
    min = min or 0
    max = max or 1
    self.x = self.x > max and max or self.x < min and min or self.x
    self.y = self.y > max and max or self.y < min and min or self.y
    if self.z then
        self.z = self.z > max and max or self.z < min and min or self.z
    end
    if self.w then
        self.w = self.w > max and max or self.w < min and min or self.w
    end
    return self
end

--- @param self VectorX
--- @param vec VectorX
--- @return number distance_squared
--- @nodiscard
function vector:distanceSquared(vec)
    local dx = vec.x - self.x
    local dy = vec.y - self.y

    if self.z and vec.z then
        local dz = vec.z - self.z
        
        if self.w and vec.w then
            local dw = vec.w - self.w
            return dx * dx + dy * dy + dz * dz + dw * dw
        end
        return dx * dx + dy * dy + dz * dz
    end
    return dx * dx + dy * dy
end

--- @param self VectorX
--- @param vec VectorX
--- @return number distance
--- @nodiscard
function vector:distance(vec)
    return math.sqrt(self:distanceSquared(vec))
end

--- @param self VectorX
--- @return number length_squared
--- @nodiscard
function vector:lengthSquared()
    local squared = self.x * self.x + self.y * self.y
    if self.z then
        squared = squared + self.z * self.z
    end
    if self.w then
        squared = squared + self.w * self.w
    end
    return squared
end

--- @param self VectorX
--- @return number length
--- @nodiscard
function vector:length()
    return math.sqrt(self:lengthSquared())
end

--- @param self VectorX
--- @param vec VectorX
--- @return number dot_product
--- @nodiscard
function vector:dot(vec)
    local dot = self.x * vec.x + self.y * vec.y
    if self.z and vec.z then
        dot = dot + self.z * vec.z
    end
    if self.w and vec.w then
        dot = dot + self.w * vec.w
    end
    return dot
end

--- @param self Vector3
--- @param vec Vector3
--- @return Vector3 cross_product
--- @nodiscard
function vector:cross(vec)
    return vectors.vec3(
        self.y * vec.z - self.z * vec.y,
        self.z * vec.x - self.x * vec.z,
        self.x * vec.y - self.y * vec.x
    )
end

--- @param self VectorX
--- @return VectorX normalized_vector
--- @nodiscard
function vector:normalize()
    local len = self:length()
    if len == 0 then
        return self
    end
    return self:div(len)
end

--- @param self VectorX
--- @param x (number|VectorX)? Default: 0
--- @param y number? Default: `x`
--- @param z number? Default: `x` or `nil` if not `Vector3` or `Vector4`
--- @param w number? Default: `x` or `nil` if not `Vector4`
--- @return VectorX vector
function vector:set(x, y, z, w)
    if not x then
        x, y, z, w = 0, 0, 0, 0
    elseif type(x) == 'number' then
        x = x or 0
        y = y or x
        z = z or (self.z and x)
        w = w or (self.w and x)
    else
        x, y, z, w = x:unpack()
    end

    self.x = x
    self.y = y
    if self.z then
        self.z = z
    end
    if self.w then
        self.w = w
    end
    return self
end

--- @param self VectorX
--- @param x (number|VectorX)? Default: 0
--- @param y number? Default: `x`
--- @param z number? Default: `x` or `nil` if not `Vector3` or `Vector4`
--- @param w number? Default: `x` or `nil` if not `Vector4`
--- @return VectorX vector
function vector:add(x, y, z, w)
    if not x then
        x, y, z, w = 0, 0, 0, 0
    elseif type(x) == 'number' then
        x = x or 0
        y = y or x
        z = z or (self.z and x)
        w = w or (self.w and x)
    else
        x, y, z, w = x:unpack()
    end

    self.x = self.x + x
    self.y = self.y + y
    if self.z then
        self.z = self.z + z
    end
    if self.w then
        self.w = self.w + w
    end
    return self
end

--- @param self VectorX
--- @param x (number|VectorX)? Default: 0
--- @param y number? Default: `x`
--- @param z number? Default: `x` or `nil` if not `Vector3` or `Vector4`
--- @param w number? Default: `x` or `nil` if not `Vector4`
--- @return VectorX vector
function vector:sub(x, y, z, w)
    if not x then
        x, y, z, w = 0, 0, 0, 0
    elseif type(x) == 'number' then
        x = x or 0
        y = y or x
        z = z or (self.z and x)
        w = w or (self.w and x)
    else
        x, y, z, w = x:unpack()
    end

    self.x = self.x - x
    self.y = self.y - y
    if self.z then
        self.z = self.z - z
    end
    if self.w then
        self.w = self.w - w
    end
    return self
end

--- @param self VectorX
--- @param x (number|VectorX)? Default: 1
--- @param y number? Default: `x`
--- @param z number? Default: `x` or `nil` if not `Vector3` or `Vector4`
--- @param w number? Default: `x` or `nil` if not `Vector4`
--- @return VectorX vector
function vector:mul(x, y, z, w)
    if not x then
        x, y, z, w = 1, 1, 1, 1
    elseif type(x) == 'number' then
        x = x or 1
        y = y or x
        z = z or (self.z and x)
        w = w or (self.w and x)
    else
        x, y, z, w = x:unpack()
    end

    self.x = self.x * x
    self.y = self.y * y
    if self.z then
        self.z = self.z * z
    end
    if self.w then
        self.w = self.w * w
    end
    return self
end

--- @param self VectorX
--- @param x (number|VectorX)? Default: 1
--- @param y number? Default: `x`
--- @param z number? Default: `x` or `nil` if not `Vector3` or `Vector4`
--- @param w number? Default: `x` or `nil` if not `Vector4`
--- @return VectorX vector
function vector:div(x, y, z, w)
    if not x then
        x, y, z, w = 1, 1, 1, 1
    elseif type(x) == 'number' then
        x = x or 1
        y = y or x
        z = z or (self.z and x)
        w = w or (self.w and x)
    else
        x, y, z, w = x:unpack()
    end


    if x == 0 or y == 0 or z == 0 or w == 0 then
        error("Division by zero in vector division", 2)
    end
    self.x = self.x / x
    self.y = self.y / y
    if self.z then
        self.z = self.z / z
    end
    if self.w then
        self.w = self.w / w
    end
    return self
end

--- @param self VectorX
--- @param vec_or_x (number|VectorX)? Default: 0
--- @param y number? Default: `x`
--- @param z number? Default: `x` or `nil` if not `Vector3` or `Vector4`
--- @param w number? Default: `x` or `nil` if not `Vector4`
--- @return boolean
--- @nodiscard
function vector:equals(vec_or_x, y, z, w)
    if type(vec_or_x) == "table" then
        vec_or_x, y, z, w = vec_or_x:unpack()
    end

    if self.x ~= vec_or_x or self.y ~= y then
        return false
    end

    if self.z and (self.z ~= z) then
        return false
    end

    if self.w and (self.w ~= w) then
        return false
    end

    return true
end

return vectors