--- @class Events
local events = {}

--- @class Event
--- @field public id string
--- @field public list table<string, fun(...)>
local event = {}

--- @generic T : Event
--- Create a new `Event`
--- @param id string
--- @param __call function
--- @return T event
function events:new(id, __call)
    return setmetatable({ id = id, list = {} }, {
        __index = event,
        __call = __call,
    })
end

--- @param id string
--- @param func function
--- @return self self
function event:register(id, func)
    self.list[id] = func
    return self
end

--- @param ... any
function event:trigger(...)
    for _, func in pairs(self.list) do
        func(...)
    end
end

--- @param id_or_func string
--- @return boolean success
function event:remove(id_or_func)
    local arg_type = type(id_or_func)

    if arg_type == 'function' then
        for key, value in pairs(self.list) do
            if value == id_or_func then
                self.list[key] = nil
                return true
            end
        end
    else
        if self.list[id_or_func] then
            self.list[id_or_func] = nil
            return true
        end
    end

    return false
end

--- @param id string
--- @return fun(...)? event_func
function event:findFunc(id)
    return self.list[id]
end

--- @param func function
--- @return string? event_id
function event:findID(func)
    for key, value in pairs(self.list) do
        if value == func then
            return key
        end
    end
end

--- @class Event.LoadCallback.class : Event
--- @field public trigger fun(self: self, arg: string[], unfilteredArg: string[])
--- @field public register fun(self: self, id: string, func: fun(arg: string[], unfilteredArg: string[]))

--- @alias Event.LoadCallback Event.LoadCallback.class | fun(arg: string[], unfilteredArg: string[])
events.ON_LOAD = events:new('load', function (self, arg, unfilteredArg)
    self:trigger(arg, unfilteredArg)
end) --[[@as Event.LoadCallback]]

--- @class Event.UpdateCallback.class : Event
--- @field public trigger fun(self: self, delta: number)
--- @field public register fun(self: self, id: string, func: fun(delta: number))

--- @alias Event.UpdateCallback Event.UpdateCallback.class | fun(delta: number)
events.ON_UPDATE = events:new('update', function (self, delta)
    self:trigger(delta)
end) --[[@as Event.UpdateCallback]]

--- @class Event.DrawCallback.class : Event
--- @field public trigger fun(self: self)
--- @field public register fun(self: self, id: string, func: fun())

--- @alias Event.DrawCallback Event.DrawCallback.class | fun()
events.ON_DRAW = events:new('load', function (self)
    self:trigger()
end) --[[@as Event.DrawCallback]]

return events