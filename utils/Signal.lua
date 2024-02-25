--- Lua-side duplication of the API of events on Roblox objects.
-- Signals are needed for to ensure that for local events objects are passed by
-- reference rather than by value where possible, as the BindableEvent objects
-- always pass signal arguments by value, meaning tables will be deep copied.
-- Roblox's deep copy method parses to a non-lua table compatable format.
-- @classmod Signal

local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

--- Constructs a new signal.
-- @constructor Signal.new()
-- @treturn Signal
function Signal.new()
    local self = setmetatable({}, Signal)

    self._bindableEvent = Instance.new("BindableEvent")
    self._argData = nil
    self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil

    return self
end

function Signal.isSignal(object)
    return typeof(object) == 'table' and getmetatable(object) == Signal
end

--- Fire the event with the given arguments. All handlers will be invoked. Handlers follow
-- Roblox signal conventions.
-- @param ... Variable arguments to pass to handler
-- @treturn nil
function Signal:Fire(...)
    self._argData = {...}
    self._argCount = select("#", ...)
    self._bindableEvent:Fire()
    self._argData = nil
    self._argCount = nil
end

--- Connect a new handler to the event. Returns a connection object that can be disconnected.
-- @tparam function handler Function handler called with arguments passed when `:Fire(...)` is called
-- @treturn Connection Connection object that can be disconnected
function Signal:Connect(handler)
    if not self._bindableEvent then
        warn("Attempting to connect to a destroyed signal")
        return nil
    end

    if type(handler) ~= "function" then
        error("Connect argument must be a function", 2)
    end

    return self._bindableEvent.Event:Connect(function()
        handler(unpack(self._argData, 1, self._argCount))
    end)
end

--- Wait for fire to be called, and return the arguments it was given.
-- @treturn ... Variable arguments from connection
function Signal:Wait()
    self._bindableEvent.Event:Wait()
    assert(self._argData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
    return unpack(self._argData, 1, self._argCount)
end

--- Disconnects all connected events to the signal. Voids the signal as unusable.
-- @treturn nil
function Signal:Destroy()
    if not self._bindableEvent then
        warn("Signal has already been destroyed")
        return
    end

    self._bindableEvent:Destroy()
    self._bindableEvent = nil
    self._argData = nil
    self._argCount = nil
end

return Signal
