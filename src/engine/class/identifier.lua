--- @class Identifer
--- @field translation_key string?
--- @field path string?
--- @field namespace string?
local identifier = {}
identifier.__index = identifier

local format = '%s:%s'
local translation_key_format = '%s.%s.%s'
local default_namespace = 'game'

--- Create a new `identifier`
--- @param path string
--- @param namespace string?
--- @return Identifer
function identifier.new(path, namespace)
    return setmetatable({ path = path, namespace = namespace or default_namespace }, identifier)
end

--- Sets a `namespace` for all `indetifier` functions to use if one is not provided
--- @param namespace string
function identifier.setDefaultNamespace(namespace)
    default_namespace = namespace
end

--- Gets a `namespace` for all `indetifier` functions to use if one is not provided
--- @return string namespace
function identifier.getDefaultNamespace()
    return default_namespace
end

--- Unpack the `identifier` into `namespace` and `path`
--- @return string namespace
--- @return string path
--- @nodiscard
function identifier:unpack()
    return self.namespace, self.path
end

--- Convert `identifier` to `string`
--- @return string
--- @nodiscard
function identifier:toString()
    return string.format(format, self:unpack())
end

--- Compares 2 `identifier` if they're equal
--- @param id Identifer|string
--- @return boolean
function identifier:equals(id)
    local id_type = type(id)
    if not (id_type == 'table' or id_type == 'string') then
        error(string.format('Cannot compare an "identifier" to a not compatible type!\nExpected "identifier" or "string", got %s', id_type), 2)
    end

    return
        id_type == 'string' and self:toString() == id or
        id_type == 'table' and self.namespace == id.namespace and self.path == id.path
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

identifier.__tostring = identifier.toString
-- identifier.__eq = identifier.equals

return identifier