local TweenService = game:GetService("TweenService")
local Theme = Import("core/Theme")
local Utils = Import("core/Utils")

local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkIcon = Utils.mkIcon
local tw = Utils.tw
local fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Toggle = {}

function Toggle.Create(parent, label, default, callback, opts)
    opts  = opts or {}
    local state = default or false
    local style = opts.Style or "box"

    local row = inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        LayoutOrder      = opts.Order or 0,
        ZIndex           = 4,
        Parent           = parent,
    })
    corner(row, 5)
    mkStroke(row, Theme.Border, 1)
    Utils.mkPad(row, 0, 14, 0, 12)

    local iconW   = 0
    local iconImg = mkIcon(row, opts.Icon, 14, Theme.TextSecondary, 6,
        Vector2.new(0, 0.5), UDim2.new(0, 0, 0.5, 0))
    if iconImg then iconW = 14 + 8 end

    inst("TextLabel", {
        Size            = UDim2.new(1, -(iconW + 46), 1, 0),
        Position        = UDim2.new(0, iconW, 0, 0),
        BackgroundTransparency = 1,
        Text            = label,
        TextColor3      = Theme.TextPrimary,
        TextSize        = 13,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 5,
        Parent          = row,
    })

    local set
    if style == "box" then
        local BOX = 26
        local box = inst("Frame", {
            Size             = UDim2.new(0, BOX, 0, BOX),
            Position         = UDim2.new(1, -BOX, 0.5, -BOX/2),
            BackgroundColor3 = state and Theme.ToggleOn or Color3.fromRGB(45, 45, 45),
            BorderSizePixel  = 0,
            ZIndex           = 5,
            Parent           = row,
        })
        corner(box, 6)
        local boxStroke = inst("UIStroke", {
            Color           = state and Theme.ToggleOn or Color3.fromRGB(80, 80, 80),
            Thickness       = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent          = box,
        })
        local checkIcon = mkIcon(box, "check", 14, Color3.fromRGB(255, 255, 255), 6,
            Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0))
        if checkIcon then checkIcon.ImageTransparency = state and 0 or 1 end
        set = function(v)
            state = v
            if state then
                tw(box,       fast, { BackgroundColor3 = Theme.ToggleOn })
                tw(boxStroke, fast, { Color = Theme.ToggleOn })
                if checkIcon then tw(checkIcon, fast, { ImageTransparency = 0 }) end
            else
                tw(box,       fast, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) })
                tw(boxStroke, fast, { Color = Color3.fromRGB(80, 80, 80) })
                if checkIcon then tw(checkIcon, fast, { ImageTransparency = 1 }) end
            end
        end
    else
        local TW, TH = 46, 24
        local track = inst("Frame", {
            Size             = UDim2.new(0, TW, 0, TH),
            Position         = UDim2.new(1, -TW, 0.5, -TH/2),
            BackgroundColor3 = state and Theme.ToggleOn or Color3.fromRGB(30, 30, 30),
            BorderSizePixel  = 0,
            ZIndex           = 5,
            Parent           = row,
        })
        corner(track, TH/2)
        local trackStroke = inst("UIStroke", {
            Color           = state and Theme.ToggleOn or Color3.fromRGB(15, 15, 15),
            Thickness       = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent          = track,
        })
        local KS   = TH - 6
        local knob = inst("Frame", {
            Size             = UDim2.new(0, KS, 0, KS),
            Position         = UDim2.new(0, state and (TW - KS - 3) or 3, 0.5, -KS/2),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel  = 0,
            ZIndex           = 6,
            Parent           = track,
        })
        corner(knob, KS/2)
        set = function(v)
            state = v
            if state then
                tw(track,       fast, { BackgroundColor3 = Theme.ToggleOn })
                tw(trackStroke, fast, { Color = Theme.ToggleOn })
                tw(knob,        fast, { Position = UDim2.new(0, TW - KS - 3, 0.5, -KS/2) })
            else
                tw(track,       fast, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) })
                tw(trackStroke, fast, { Color = Color3.fromRGB(15, 15, 15) })
                tw(knob,        fast, { Position = UDim2.new(0, 3, 0.5, -KS/2) })
            end
        end
    end

    inst("TextButton", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = "",
        ZIndex          = 7,
        Parent          = row,
    }).MouseButton1Click:Connect(function()
        set(not state)
        if callback then callback(state) end
    end)

    return { Get = function() return state end, Set = set }
end

return Toggle
