local UILib = require(script.Parent.init)

local Win = UILib.Window.new({
    Title = "Claude UI",
    Width = 940,
    Height = 620
})

-- Notificação Inicial
UILib.Notification("Interface carregada com sucesso.", "success", 4)

-- [[ Tab 1: Main ]]
local MainTab = Win:CreateTab({
    Title = "Main",
    Icon = "home"
})

-- 2 Buttons (Total: 2/3)
MainTab:AddButton("Confirm Action", function()
    -- Dialog 1 (Total: 1/2)
    Win:Dialog({
        Title = "Confirm Action",
        Description = "Are you sure you want to proceed with this action?",
        Buttons = {"Cancel", "Confirm"},
        Icon = "alert-circle"
    }, function(option)
        if option == "Confirm" then
            UILib.Notification("Action confirmed!", "success")
        else
            UILib.Notification("Action cancelled.", "error")
        end
    end)
end)

MainTab:AddButton("Reset Settings", function()
    UILib.Notification("Settings reset to default.", "info")
end)

-- 2 Toggles (Total: 2/4)
MainTab:AddToggle("Enable Feature A", true, function(state)
    print("Feature A is now:", state)
end)

MainTab:AddToggle("Enable Feature B", false, function(state)
    print("Feature B is now:", state)
end)

-- 2 Dropdowns (Total: 2/3)
MainTab:AddDropdown("Select Mode", {"Easy", "Medium", "Hard"}, function(selected)
    print("Mode selected:", selected)
end)

MainTab:AddDropdown("Select Theme", {"Dark", "Light", "Blue"}, function(selected)
    print("Theme selected:", selected)
end)


-- [[ Tab 2: Settings ]]
local SettingsTab = Win:CreateTab({
    Title = "Settings",
    Icon = "settings"
})

-- 1 Button (Total: 3/3)
SettingsTab:AddButton("Clear Cache", function()
    -- Dialog 2 (Total: 2/2)
    Win:Dialog({
        Title = "Clear Cache",
        Description = "This will clear all temporary files. Continue?",
        Buttons = {"No", "Yes"},
        Icon = "trash-2"
    }, function(option)
        if option == "Yes" then
            UILib.Notification("Cache cleared!", "success")
        end
    end)
end)

-- 2 Toggles (Total: 4/4)
SettingsTab:AddToggle("Notifications", true, function(state)
    print("Notifications:", state)
end)

SettingsTab:AddToggle("Auto-Save", true, function(state)
    print("Auto-Save:", state)
end)

-- 1 Dropdown (Total: 3/3)
SettingsTab:AddDropdown("Language", {"English", "Portuguese", "Spanish"}, function(selected)
    print("Language selected:", selected)
end)
