return function(Theme, Utils, Effects, TweenController)
    local Toggle = {}
    Toggle.__index = Toggle

    function Toggle.new(parent, config)
        local self = setmetatable({}, Toggle)

        self.Config = config or {}
        self.Text = self.Config.Text or "Toggle"
        self.Icon = self.Config.Icon or ""
        self.State = self.Config.State or false
        self.Locked = self.Config.Locked or false
        self.Callback = self.Config.Callback or function() end

        self.Instance = Utils.Create("Frame", {
            Name = "ToggleRow",
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = parent
        })
        Utils.Corner(self.Instance, Theme.Sizes.RadiusMedium)
        local stroke = Utils.Stroke(self.Instance, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(self.Instance, 13)

        local icon = Utils.Create("TextLabel", {
            Name = "Icon",
            Text = self.Icon,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, self.Icon == "" and 0 or 14, 1, 0),
            Visible = self.Icon ~= "",
            Parent = self.Instance
        })

        self.Label = Utils.Create("TextLabel", {
            Name = "Label",
            Text = self.Text,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextMedium,
            TextColor3 = Theme.Colors.TextMed,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -80, 1, 0),
            Position = UDim2.new(0, self.Icon == "" and 0 or 23, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Instance
        })

        self.Switch = Utils.Create("Frame", {
            Name = "Switch",
            Size = UDim2.new(0, 40, 0, 22),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            BackgroundColor3 = Theme.Colors.TextMuted,
            BorderSizePixel = 0,
            Parent = self.Instance
        })
        Utils.Corner(self.Switch, UDim.new(1, 0))

        self.Knob = Utils.Create("Frame", {
            Name = "Knob",
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Parent = self.Switch
        })
        Utils.Corner(self.Knob, UDim.new(1, 0))

        self.Button = Utils.Create("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = self.Instance
        })

        self.Button.MouseEnter:Connect(function()
            if self.Locked then
                return
            end
            TweenController:Play(self.Instance, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.SurfaceHover})
            stroke.Transparency = Theme.Transparencies.BorderMid
        end)

        self.Button.MouseLeave:Connect(function()
            TweenController:Play(self.Instance, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.Surface})
            stroke.Transparency = Theme.Transparencies.Border
        end)

        self.Button.MouseButton1Click:Connect(function()
            if self.Locked then
                return
            end
            self:Set(not self.State)
        end)

        self:Set(self.State, true)

        if self.Locked then
            self.Instance.BackgroundTransparency = 0.6
            self.Label.TextTransparency = 0.45
            icon.TextTransparency = 0.45
        end

        return self
    end

    function Toggle:Set(state, skipCallback)
        self.State = state
        if self.State then
            TweenController:Play(self.Switch, TweenController.Smooth, {BackgroundColor3 = Theme.Colors.Accent})
            TweenController:Play(self.Knob, TweenController.Spring, {Position = UDim2.new(0, 24, 0.5, -7), BackgroundTransparency = 0})
            self.Label.TextColor3 = Theme.Colors.TextHigh
        else
            TweenController:Play(self.Switch, TweenController.Smooth, {BackgroundColor3 = Theme.Colors.TextMuted})
            TweenController:Play(self.Knob, TweenController.Spring, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundTransparency = 0.4})
            self.Label.TextColor3 = Theme.Colors.TextMed
        end
        if not skipCallback then
            self.Callback(self.State)
        end
    end

    return Toggle
end
