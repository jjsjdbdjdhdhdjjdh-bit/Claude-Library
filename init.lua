-- [[ Services ]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- [[ Configuration ]]
-- Base URL for raw files (GitHub)
local REPO_URL = "https://raw.githubusercontent.com/jjsjdbdjdhdhdjjdh-bit/UILib/main/"

local Modules = {}

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
        else
            warn("Failed to compile module: " .. path .. " Error: " .. tostring(err))
        end
    else
        warn("Failed to load module: " .. path .. " from " .. url)
    end
    
    return nil
end

-- Expose Import globally for the script itself
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
local UILib = {}
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

return UILib
