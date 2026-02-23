local State = {}
State.__index = State

<<<<<<< HEAD
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
=======
function State.new(initialValue)
    local self = setmetatable({}, State)
    self._value = initialValue
    self._listeners = {}
    self._destroyed = false
    return self
end

function State:Get()
    return self._value
end

function State:Set(value)
    if self._destroyed then
        return
    end
    if self._value == value then
        return
    end
    self._value = value
    for _, listener in ipairs(self._listeners) do
        task.spawn(listener, value)
    end
end

function State:OnChange(callback, fireNow)
    if self._destroyed then
        return function() end
    end
    table.insert(self._listeners, callback)
    if fireNow ~= false then
        callback(self._value)
    end
    return function()
        for i, listener in ipairs(self._listeners) do
            if listener == callback then
                table.remove(self._listeners, i)
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
                break
            end
        end
    end
end

<<<<<<< HEAD
=======
function State:Destroy()
    self._destroyed = true
    self._listeners = {}
end

>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
return State
