local Registry = {}
Registry.__index = Registry

function Registry.new()
    local self = setmetatable({}, Registry)
    self._items = {}
    return self
end

function Registry:Register(id, item)
    self._items[id] = item
end

function Registry:Get(id)
    return self._items[id]
end

function Registry:Unregister(id)
    self._items[id] = nil
end

function Registry:GetAll()
    return self._items
end

return Registry
