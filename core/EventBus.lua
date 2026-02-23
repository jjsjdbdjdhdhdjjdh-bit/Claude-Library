local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
    local self = setmetatable({}, EventBus)
<<<<<<< HEAD
    self._listeners = {}
    return self
end

function EventBus:Subscribe(event, callback)
    if not self._listeners[event] then
        self._listeners[event] = {}
    end
    table.insert(self._listeners[event], callback)
    return function()
        for i, cb in ipairs(self._listeners[event]) do
            if cb == callback then
                table.remove(self._listeners[event], i)
                break
            end
=======
    self._connections = {}
    self._destroyed = false
    return self
end

function EventBus:Connect(callback)
    if self._destroyed then
        return {Disconnect = function() end, Connected = false}
    end
    local connection = {
        Callback = callback,
        Connected = true,
        Disconnect = function(self)
            self.Connected = false
        end
    }
    table.insert(self._connections, connection)
    return connection
end

function EventBus:Fire(...)
    if self._destroyed then
        return
    end
    for i = #self._connections, 1, -1 do
        local conn = self._connections[i]
        if conn.Connected then
            task.spawn(conn.Callback, ...)
        else
            table.remove(self._connections, i)
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
        end
    end
end

<<<<<<< HEAD
function EventBus:Publish(event, ...)
    if self._listeners[event] then
        for _, callback in ipairs(self._listeners[event]) do
            task.spawn(callback, ...)
        end
    end
=======
function EventBus:DisconnectAll()
    for _, conn in ipairs(self._connections) do
        conn.Connected = false
    end
    self._connections = {}
end

function EventBus:Destroy()
    self._destroyed = true
    self:DisconnectAll()
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
end

return EventBus
