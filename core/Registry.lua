local Registry = {}
<<<<<<< HEAD
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
=======
Registry.Components = {}
Registry.Windows = {}
Registry.Bindings = {}

function Registry.Register(component, window)
    table.insert(Registry.Components, component)
    if window then
        Registry.Windows[window] = Registry.Windows[window] or {Components = {}, Connections = {}}
        table.insert(Registry.Windows[window].Components, component)
    end
end

function Registry.RegisterWindow(window)
    if not Registry.Windows[window] then
        Registry.Windows[window] = {Components = {}, Connections = {}}
    end
end

function Registry.RegisterConnection(window, connection)
    if not window then
        return
    end
    Registry.Windows[window] = Registry.Windows[window] or {Components = {}, Connections = {}}
    table.insert(Registry.Windows[window].Connections, connection)
end

function Registry.Cleanup()
    for _, comp in ipairs(Registry.Components) do
        if comp.Destroy then comp:Destroy() end
    end
    Registry.Components = {}
    Registry.Windows = {}
end

function Registry.CleanupWindow(window)
    local entry = Registry.Windows[window]
    if not entry then
        return
    end
    for _, comp in ipairs(entry.Components) do
        if comp.Destroy then
            comp:Destroy()
        end
    end
    for _, conn in ipairs(entry.Connections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    Registry.Windows[window] = nil
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
end

return Registry
