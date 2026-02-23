local State = {}
State.__index = State

function State.new(initialState)
    local self = setmetatable({}, State)
    self._state = initialState or {}
    self._listeners = {}
    return self
end

function State:Get(key)
    return self._state[key]
end

function State:Set(key, value)
    local oldValue = self._state[key]
    self._state[key] = value
    if self._listeners[key] then
        for _, callback in ipairs(self._listeners[key]) do
            task.spawn(callback, value, oldValue)
        end
    end
end

function State:Subscribe(key, callback)
    if not self._listeners[key] then
        self._listeners[key] = {}
    end
    table.insert(self._listeners[key], callback)
    return function()
        for i, cb in ipairs(self._listeners[key]) do
            if cb == callback then
                table.remove(self._listeners[key], i)
                break
            end
        end
    end
end

return State
