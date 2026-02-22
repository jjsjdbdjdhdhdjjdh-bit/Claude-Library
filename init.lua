local UILib = {}

-- [[ Services ]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- [[ Configuration ]]
-- Base URL for raw files (GitHub)
local REPO_URL = "https://raw.githubusercontent.com/jjsjdbdjdhdhdjjdh-bit/UILib/main/"

-- [[ Module Cache ]]
local Modules = {}

-- [[ Loader System ]]
local function Import(path)
    -- 1. Check Cache
    if Modules[path] then return Modules[path] end
    
    -- 2. Check Local Child (for development/bundling)
    local function findLocal(current, parts)
        for _, name in ipairs(parts) do
            current = current:FindFirstChild(name)
            if not current then return nil end
        end
        return current
    end
    
    local parts = string.split(path, "/")
    local localModule = findLocal(script, parts)
    
    if localModule and localModule:IsA("ModuleScript") then
        local result = require(localModule)
        Modules[path] = result
        return result
    end
    
    -- 3. Remote Fetch (Fallback)
    local url = REPO_URL .. path .. ".lua"
    local success, content
    
    if request then
        local response = request({
            Url = url,
            Method = "GET"
        })
        if response.Success and response.StatusCode == 200 then
            content = response.Body
            success = true
        end
    else
        -- Fallback to HttpGet
        local s, r = pcall(function() return game:HttpGet(url) end)
        if s then
            content = r
            success = true
        end
    end
    
    if success and content then
        local func, err = loadstring(content)
        if func then
            local factory = func() 
            Modules[path] = factory
            return factory
        else
            warn("Failed to compile module: " .. path .. " Error: " .. tostring(err))
        end
    else
        warn("Failed to load module: " .. path .. " from " .. url)
    end
    
    return nil
end

-- [[ Dependency Injection Container ]]
-- We load modules in specific order to satisfy dependencies.

-- 1. Core
local Theme = Import("core/Theme")
local Utils = Import("core/Utils")
local State = Import("core/State")
local EventBus = Import("core/EventBus")
local Registry = Import("core/Registry")
local TweenController = Import("animations/TweenController")
local Effects = Import("animations/Effects")
local Draggable = Import("layout/Draggable")
local Resizable = Import("layout/Resizable")

-- 2. Components Factories
local WindowFactory = Import("components/Window")
local ButtonFactory = Import("components/Button")
local ToggleFactory = Import("components/Toggle")
local SliderFactory = Import("components/Slider")
local DropdownFactory = Import("components/Dropdown")
local InputFactory = Import("components/Input")
local TabsFactory = Import("components/Tabs")
local NotificationFactory = Import("components/Notification")

-- [[ API Initialization ]]

-- We initialize the components by injecting dependencies.
-- This creates the "Class" tables ready to be used.

local Components = {
    Button = ButtonFactory(Theme, Utils, Effects, TweenController),
    Toggle = ToggleFactory(Theme, Utils, Effects, TweenController),
    Slider = SliderFactory(Theme, Utils, TweenController),
    Dropdown = DropdownFactory(Theme, Utils, TweenController, Effects),
    Input = InputFactory(Theme, Utils, TweenController),
    Tabs = TabsFactory(Theme, Utils, TweenController)
}

local Window = WindowFactory(Theme, Utils, Draggable, Resizable, TweenController, State, EventBus, Registry, Components)
-- For Button, Toggle etc, they are usually instantiated BY the Window or Tabs.
-- But we also want to expose them if the user wants to manually attach them?
-- Better approach: The Window class should have methods like :AddButton which use these factories.
-- OR, we expose a `.new` on them and let the user pass the parent.

-- Let's stick to the User's requested API: `Window:AddButton(...)`
-- To support this, we need to inject the Component Classes into the Window Class, 
-- OR make Window require them (circular dependency risk if not careful).
-- Best way: Pass a "Components" table to Window.

-- Initialize Notification System
NotificationFactory(Theme, Utils, TweenController).Init(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
local Notification = NotificationFactory(Theme, Utils, TweenController)

-- Inject Components into Window so it can use them internally if needed,
-- or we add helper methods to Window now.

function Window:AddButton(config)
    local btn = Components.Button.new(self.Content, config) -- Parent to Content
    return btn
end

function Window:AddToggle(config)
    local tgl = Components.Toggle.new(self.Content, config)
    return tgl
end

function Window:AddSlider(config)
    local sld = Components.Slider.new(self.Content, config)
    return sld
end

function Window:AddDropdown(config)
    local drp = Components.Dropdown.new(self.Content, config)
    return drp
end

function Window:AddInput(config)
    local inp = Components.Input.new(self.Content, config)
    return inp
end

function Window:AddTabs(config)
    local tabs = Components.Tabs.new(self.Content, config)
    return tabs
end

-- [[ Public API ]]
UILib.Window = Window
UILib.Notification = Notification
UILib.Theme = Theme

return UILib
