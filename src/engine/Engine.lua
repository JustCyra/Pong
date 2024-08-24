Identifier  = require "engine.class.Identifier"
Vectors     = require "engine.class.Vectors"
Components  = require "engine.class.Components"
Events      = require "engine.class.Events"
Utility     = require "engine.class.Utility"

Registry    = require "engine.class.Registry"
Input       = require "engine.class.Input"

Object      = require "engine.class.Object"
Entity      = require "engine.class.Entity"

--- @class Engine
local engine = {
    flags = {
        debug = false,
        fps = false
    },
    renderer_info = {
        api_name = 'undefined',
        api_version = 'undefined',
        device_name = 'undefined',
        device_vendor = 'undefined',
    }
}

--- @enum (key) EngineFlags
local engine_flags = {
    ['--debug'] = true,
    ['--fps'] = true,
}

--- @private
--- Checks if the `arg` is a defined launch flag<br>
--- If `arg` is a `table`, checks if any `value` is a defined launch flag instead
--- @param arg string|string[]
--- @return string|string[]|nil flag
function engine:isLaunchFlag(arg)
    if type(arg) == 'table' then
        local tbl = {}
        for _, value in ipairs(arg) do
            if engine_flags[value] then
                table.insert(tbl, value:sub(3))
            end
        end
        return tbl
    elseif type(arg) == 'string' then
        if engine_flags[arg] then
            return arg:sub(3)
        end
    end
end

--- @private
--- Scan the `arg` if it is a Launch Flag<br>
--- If `arg` is a `table`, scans the entire table `values` for defined launch flags instead
--- @param arg string|string[]
function engine:scanForLaunchFlags(arg)
    local result = self:isLaunchFlag(arg)

    if result then
        if type(result) == 'table' then
            for _, value in ipairs(result) do
                self.flags[value] = true
            end
        else
            self.flags[result] = true
        end
    end
end

--- @private
--- Update `Engine.renderer_info` table
function engine:updateRendererInformation()
    local renderer_info = self.renderer_info
    renderer_info.api_name, renderer_info.api_version, renderer_info.device_vendor, renderer_info.device_name = love.graphics.getRendererInfo()
end

--- @private
--- Draw `device information` at the top left
function engine:drawDeviceInformation()
    love.graphics.print(string.format('[%s] | %s (%s)', jit.os .. ' ' .. jit.arch, self.renderer_info.device_name, self.renderer_info.api_version), 0, 0)
end

--- @private
--- Draw `fps` count at the top left
function engine:drawFPS()
    love.graphics.print(string.format('FPS: %s', love.timer.getFPS()), 0, self.flags.debug and 14 or 0)
end

--- @param arg string[]
--- @param unfilteredArg string[]
function love.load(arg, unfilteredArg)
    engine:scanForLaunchFlags(arg)
    engine:updateRendererInformation()

    if engine.flags.debug then
        love.window.setTitle(string.format('%s <%s>', love.window.getTitle(), engine.renderer_info.api_name))
    end

    math.randomseed(love.timer.getTime())

    -- Registry:load()
    Events.ON_LOAD(arg, unfilteredArg)
end

--- @param delta number
function love.update(delta)
    Registry:update(delta)
    Events.ON_UPDATE(delta)
end

function love.draw()
    if engine.flags.debug then
        engine:drawDeviceInformation()
    end
    if engine.flags.fps then
        engine:drawFPS()
    end
    Registry:draw()
    Events.ON_DRAW()
end

return engine