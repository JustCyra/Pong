--- @class Identifier.class
local identifier_class = {}
identifier_class.__index = identifier_class

--- @class Identifier
--- @field private translation_key? string
--- @field public path string
--- @field public class string
local identifier = {}
identifier.__index = identifier

local format = '%s:%s'
local translation_key_format = '%s.%s.%s'

--- Create a new `identifier`
--- @param class string
--- @param path string
--- @return Identifier
function identifier_class.new(class, path)
    return setmetatable({ path = path, class = class }, identifier)
end

--- Unpack the `identifier` into `namespace` and `path`
--- @return string class
--- @return string path
--- @nodiscard
function identifier:unpack()
    return self.class, self.path
end

--- Convert `identifier` to `string`
--- @return string
--- @nodiscard
function identifier:toString()
    return string.format(format, self:unpack())
end

--- Compares 2 `identifier` if they're equal
--- @param id Identifier|string
--- @return boolean
function identifier:equals(id)
    local id_type = type(id)
    if not (id_type == 'table' or id_type == 'string') then
        error(string.format('Cannot compare an "identifier" to a not compatible type!\nExpected "identifier" or "string", got %s', id_type), 2)
    end

    return
        id_type == 'string' and self:toString() == id or
        id_type == 'table' and self.class == id.class and self.path == id.path
end

--- Gets or creates a Translation Key prefixed with a given `key`
--- @param key string
--- @return string
--- @nodiscard
function identifier:getOrCreateTranslationKey(key)
    if not self.translation_key then
        self.translation_key = string.format(translation_key_format, key, self:unpack())
    end

    return self.translation_key
end

-- setmetatable(identifier_class, {
--     --- Create a new `identifier`
--     --- @param path string
--     --- @param namespace? string
--     --- @return Identifier
--     __call = function (_, path, namespace)
--         return identifier_class.new(path, namespace)
--     end
-- })
setmetatable(identifier, {
    __tostring = identifier.toString,
    -- __eq = identifier.equals,
})

return identifier_class