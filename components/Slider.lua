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
