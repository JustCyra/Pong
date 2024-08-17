--- @class Input
--- @field lastKeyPress? string
local input = {}

--- @param key string
--- @param scanCode string
--- @param isRepeat boolean
function input:keypressed(key, scanCode, isRepeat)
    self.lastKeyPress = key
end

--- @param key string
function input:keyreleased(key)
    -- self.lastKeyPress = nil
end

return input