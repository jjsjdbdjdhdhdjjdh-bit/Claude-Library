local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
    local self = setmetatable({}, EventBus)
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
        end
    end
end

function EventBus:Publish(event, ...)
    if self._listeners[event] then
        for _, callback in ipairs(self._listeners[event]) do
            task.spawn(callback, ...)
        end
    end
end

return EventBus
