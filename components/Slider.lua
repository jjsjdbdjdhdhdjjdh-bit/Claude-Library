<<<<<<< HEAD
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
=======
return function(Theme, Utils, TweenController)
    local Slider = {}
    Slider.__index = Slider

    local UserInputService = game:GetService("UserInputService")

    function Slider.new(parent, config)
        local self = setmetatable({}, Slider)

        self.Config = config or {}
        self.Text = self.Config.Text or "Slider"
        self.Min = self.Config.Min or 0
        self.Max = self.Config.Max or 100
        self.Default = self.Config.Default or self.Min
        self.Decimals = self.Config.Decimals or 0
        self.Callback = self.Config.Callback or function() end

        self.Value = self.Default
        self.Dragging = false

        self.Instance = Utils.Create("Frame", {
            Name = "SliderWrap",
            Size = UDim2.new(1, 0, 0, 58),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = parent
        })
        Utils.Corner(self.Instance, Theme.Sizes.RadiusMedium)
        Utils.Stroke(self.Instance, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(self.Instance, 12)

        local header = Utils.Create("Frame", {
            Name = "Header",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Parent = self.Instance
        })

        self.Label = Utils.Create("TextLabel", {
            Name = "Label",
            Text = self.Text,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextMedium,
            TextColor3 = Theme.Colors.TextMed,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = header
        })

        self.ValueLabel = Utils.Create("TextLabel", {
            Name = "Value",
            Text = tostring(self.Value),
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.Accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 60, 1, 0),
            Position = UDim2.new(1, -60, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = header
        })

        self.Track = Utils.Create("Frame", {
            Name = "Track",
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 0.92,
            Parent = self.Instance
        })
        Utils.Corner(self.Track, UDim.new(1, 0))

        self.Fill = Utils.Create("Frame", {
            Name = "Fill",
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.Colors.Accent,
            BorderSizePixel = 0,
            Parent = self.Track
        })
        Utils.Gradient(self.Fill, ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Colors.Accent),
            ColorSequenceKeypoint.new(1, Theme.Colors.AccentHigh)
        }), 0)
        Utils.Corner(self.Fill, UDim.new(1, 0))

        self.Knob = Utils.Create("Frame", {
            Name = "Knob",
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 0, 0.5, -7),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = self.Track
        })
        Utils.Corner(self.Knob, UDim.new(1, 0))
        Utils.Stroke(self.Knob, Theme.Colors.Accent, 2, 0)

        self.ClickArea = Utils.Create("TextButton", {
            Name = "ClickArea",
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 24),
            Parent = self.Instance
        })

        self.ClickArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Dragging = true
                self:UpdateFromInput(input.Position.X)
            end
        end)

        self.ClickArea.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                self:UpdateFromInput(input.Position.X)
            end
        end)

        self:Set(self.Value, true)

        return self
    end

    function Slider:UpdateFromInput(xPos)
        local absPos = self.Track.AbsolutePosition.X
        local absSize = self.Track.AbsoluteSize.X
        local ratio = math.clamp((xPos - absPos) / absSize, 0, 1)
        local value = self.Min + (self.Max - self.Min) * ratio
        if self.Decimals > 0 then
            value = math.floor(value * 10 ^ self.Decimals + 0.5) / 10 ^ self.Decimals
        else
            value = math.floor(value + 0.5)
        end
        self:Set(value)
    end

    function Slider:Set(value, skipCallback)
        self.Value = math.clamp(value, self.Min, self.Max)
        local percent = (self.Value - self.Min) / (self.Max - self.Min)
        local text = self.Decimals > 0 and string.format("%." .. self.Decimals .. "f", self.Value) or tostring(self.Value)
        self.ValueLabel.Text = text
        TweenController:Play(self.Fill, TweenController.Smooth, {Size = UDim2.new(percent, 0, 1, 0)})
        TweenController:Play(self.Knob, TweenController.Smooth, {Position = UDim2.new(percent, -7, 0.5, -7)})
        if not skipCallback then
            self.Callback(self.Value)
        end
    end

    return Slider
end
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
