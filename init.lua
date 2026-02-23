local UILib = {}

<<<<<<< HEAD
-- [[ Import Function ]] --
-- Replaces direct requires/loadstrings
local REPO_URL = "https://raw.githubusercontent.com/jjsjdbdjdhdhdjjdh-bit/UILib/main/UILib/"

local Modules = {}

=======
-- [[ Services ]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- [[ Configuration ]]
-- Base URL for raw files (GitHub)
local REPO_URL = "https://raw.githubusercontent.com/jjsjdbdjdhdhdjjdh-bit/UILib/main/"

-- [[ Module Cache ]]
local Modules = {}

-- [[ Loader System ]]
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
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
    
<<<<<<< HEAD
    -- Also try searching in script.Parent if not found in script (useful if init.lua is inside a folder)
    if not localModule and script.Parent then
         localModule = findLocal(script.Parent, parts)
    end
    
    if localModule and localModule:IsA("ModuleScript") then
        local success, result = pcall(require, localModule)
        if success then
            Modules[path] = result
            return result
        end
=======
    if localModule and localModule:IsA("ModuleScript") then
        local result = require(localModule)
        Modules[path] = result
        return result
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
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
<<<<<<< HEAD
            -- Set Global Import for the module to use
            if getgenv then
                getgenv().Import = Import
            else
                _G.Import = Import
            end

            local ok, module = pcall(func)
            if not ok then
                warn("Falha ao executar "..path.." | "..tostring(module))
                return nil
            end

            Modules[path] = module
            return module
=======
            local factory = func() 
            Modules[path] = factory
            return factory
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
        else
            warn("Failed to compile module: " .. path .. " Error: " .. tostring(err))
        end
    else
        warn("Failed to load module: " .. path .. " from " .. url)
    end
    
    return nil
end

<<<<<<< HEAD
-- Expondo globalmente
if getgenv then
    getgenv().Import = Import
else
    _G.Import = Import
end

-- [[ Core Modules ]] --
local Theme      = Import("core/Theme")
local Utils      = Import("core/Utils")
local State      = Import("core/State")
local EventBus   = Import("core/EventBus")
local Registry   = Import("core/Registry")

-- [[ Layout Helpers ]] --
local Draggable  = Import("layout/Draggable")
local Resizable  = Import("layout/Resizable")

-- [[ Animations ]] --
local TweenController = Import("animations/TweenController")
local Effects         = Import("animations/Effects")

-- [[ Components ]] --
local Button       = Import("components/Button")
local Toggle       = Import("components/Toggle")
local Slider       = Import("components/Slider")
local Input        = Import("components/Input")
local Dropdown     = Import("components/Dropdown")
local Tabs         = Import("components/Tabs")
local Notification = Import("components/Notification")
local Dialog       = Import("components/Dialog")
local Window       = Import("components/Window")

-- [[ Build UILib ]] --
UILib.Theme = Theme
UILib.Utils = Utils
UILib.State = State
UILib.EventBus = EventBus
UILib.Registry = Registry

UILib.Draggable = Draggable
UILib.Resizable = Resizable

UILib.TweenController = TweenController
UILib.Effects = Effects

UILib.Button       = Button
UILib.Toggle       = Toggle
UILib.Slider       = Slider
UILib.Input        = Input
UILib.Dropdown     = Dropdown
UILib.Tabs         = Tabs
UILib.Notification = Notification
UILib.Dialog       = Dialog
UILib.Window       = Window

-- [[ Error Handling & Initialization ]] --
-- Ensures everything is fully loaded and functional
-- (Any specific initialization logic from original file would go here)
=======
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
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375

return UILib
