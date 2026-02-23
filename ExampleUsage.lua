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
            -- Set Global Import for the module to use
            if getgenv then
                getgenv().Import = Import
            else
                _G.Import = Import
            end
            
            local module = func() 
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

-- [[ Load UILib ]]
-- This executes init.lua which returns the library table
local UILib = Import("init")
if not UILib then
    -- Fallback for direct execution context where init.lua might be the main script
    if script and script.Parent and script.Parent:FindFirstChild("init") then
        UILib = require(script.Parent.init)
    else
        warn("Could not load UILib init module")
        return
    end
end

-- [[ Usage Example ]]

local win = UILib.Window.new({
    Title = "Example UI",
    Width = 600,
    Height = 400,
    Acrylic = true
})

local tab = win:CreateTab({
    Title = "Home",
    Icon = "home"
})

tab:AddLabel("Welcome to the Example UI!")

tab:AddButton("Click Me", function()
    print("Button clicked!")
    UILib.Notification("Button Clicked!", "success", 3)
end)

tab:AddToggle("Toggle Me", false, function(state)
    print("Toggle state:", state)
end)

tab:AddSlider("Slider", 0, 100, 50, function(val)
    print("Slider value:", val)
end)

tab:AddInput("Type here...", function(text)
    print("Input text:", text)
end)

tab:AddDropdown("Select Option", {"Option 1", "Option 2", "Option 3"}, function(selected)
    print("Selected:", selected)
end)

-- Window Home Tab (if using built-in Home Tab feature)
win:CreateHomeTab()

return UILib
