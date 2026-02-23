local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Theme = Import("core/Theme")
local Utils = Import("core/Utils")

local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkPad = Utils.mkPad
local tw = Utils.tw
local fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Slider = {}

function Slider.Create(parent, label, min, max, default, callback, opts)
    opts  = opts or {}
    min   = min or 0
    max   = max or 100
    local value = math.clamp(default or min, min, max)

    local container = inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        LayoutOrder      = opts.Order or 0,
        ZIndex           = 4,
        Parent           = parent,
    })
    corner(container, 5)
    mkStroke(container, Theme.Border, 1)
    mkPad(container, 8, 14, 8, 14)

    local hdr = inst("Frame", {
        Size            = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        ZIndex          = 5,
        Parent          = container,
    })
    inst("TextLabel", {
        Size            = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = label,
        TextColor3      = Theme.TextPrimary,
        TextSize        = 13,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 5,
        Parent          = hdr,
    })
    local valLbl = inst("TextLabel", {
        Size            = UDim2.new(0.3, 0, 1, 0),
        Position        = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text            = tostring(value),
        TextColor3      = Theme.Primary,
        TextSize        = 13,
        Font            = Enum.Font.GothamMedium,
        TextXAlignment  = Enum.TextXAlignment.Right,
        ZIndex          = 5,
        Parent          = hdr,
    })

    local track = inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 5),
        Position         = UDim2.new(0, 0, 1, -5),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = container,
    })
    corner(track, 3)

    local pct  = (value - min) / (max - min)
    local fill = inst("Frame", {
        Size             = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = track,
    })
    corner(fill, 3)

    local knob = inst("Frame", {
        Size             = UDim2.new(0, 13, 0, 13),
        Position         = UDim2.new(pct, -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0,
        ZIndex           = 7,
        Parent           = track,
    })
    corner(knob, 7)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + rel * (max - min) + 0.5)
        valLbl.Text = tostring(value)
        tw(fill, fast, { Size     = UDim2.new(rel, 0, 1, 0) })
        tw(knob, fast, { Position = UDim2.new(rel, -6, 0.5, -6) })
        if callback then callback(value) end
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end
    end)

    return {
        Get = function() return value end,
        Set = function(v)
            value = math.clamp(v, min, max)
            local r = (value - min) / (max - min)
            valLbl.Text = tostring(value)
            tw(fill, fast, { Size     = UDim2.new(r, 0, 1, 0) })
            tw(knob, fast, { Position = UDim2.new(r, -6, 0.5, -6) })
        end,
    }
end

return Slider
