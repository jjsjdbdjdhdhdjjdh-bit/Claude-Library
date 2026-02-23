local Players = game:GetService("Players")
local Theme = Import("core/Theme")
local Utils = Import("core/Utils")
local TweenController = Import("animations/TweenController")

local T = Theme
local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkPad = Utils.mkPad
local mkIcon = Utils.mkIcon
local tw = TweenController.tw
local med = TweenController.med

return function(message, kind, duration)
    kind     = kind     or "info"
    duration = duration or 3

    local colorMap = { success = T.Success, warning = T.Warning, error = T.Error, info = T.Info }
    local iconMap  = { success = "circle-check", warning = "triangle-alert", error = "circle-x", info = "info" }
    local accent   = colorMap[kind] or T.Info
    local iconName = iconMap[kind]

    local pGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local tGui = pGui:FindFirstChild("ClaudeUI_Toasts")
    if not tGui then
        tGui = inst("ScreenGui", {
            Name           = "ClaudeUI_Toasts",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent         = pGui,
        })
        inst("UIListLayout", {
            SortOrder           = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment   = Enum.VerticalAlignment.Bottom,
            Padding             = UDim.new(0, 8),
            Parent              = tGui,
        })
        mkPad(tGui, 0, 16, 16, 0)
    end

    local toast = inst("Frame", {
        Size             = UDim2.new(0, 300, 0, 52),
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 100,
        Parent           = tGui,
    })
    corner(toast, 5)
    mkStroke(toast, T.WindowBorder, 1)

    inst("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel  = 0,
        ZIndex           = 101,
        Parent           = toast,
    })

    local iconPlaced = mkIcon(toast, iconName, 15, accent, 102,
        Vector2.new(0, 0.5), UDim2.new(0, 12, 0.5, 0))
    if not iconPlaced then
        local fallback = { success = "✓", warning = "⚠", error = "✕", info = "ℹ" }
        inst("TextLabel", {
            Size            = UDim2.new(0, 30, 1, 0),
            Position        = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Text            = fallback[kind] or "ℹ",
            TextColor3      = accent,
            TextSize        = 14,
            Font            = Enum.Font.GothamBold,
            ZIndex          = 102,
            Parent          = toast,
        })
    end

    inst("TextLabel", {
        Size            = UDim2.new(1, -50, 1, 0),
        Position        = UDim2.new(0, 44, 0, 0),
        BackgroundTransparency = 1,
        Text            = message,
        TextColor3      = T.TextPrimary,
        TextSize        = 13,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextWrapped     = true,
        ZIndex          = 101,
        Parent          = toast,
    })

    tw(toast, med, { BackgroundTransparency = 0 })
    task.delay(duration, function()
        tw(toast, med, { BackgroundTransparency = 1 })
        task.delay(0.25, function() toast:Destroy() end)
    end)
    return toast
end
