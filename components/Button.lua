return function(Theme, Utils, Effects, TweenController)
    local Button = {}
    Button.__index = Button

    function Button.new(parent, config)
        local self = setmetatable({}, Button)

        self.Config = config or {}
        self.Text = self.Config.Text or "Botão"
        self.Variant = self.Config.Variant or "default"
        self.Icon = self.Config.Icon or ""
        self.Locked = self.Config.Locked or false
        self.Callback = self.Config.Callback or function() end

        self.Instance = Utils.Create("TextButton", {
            Name = "Button",
            Text = "",
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Parent = parent
        })
        Utils.Corner(self.Instance, Theme.Sizes.RadiusMedium)
        local stroke = Utils.Stroke(self.Instance, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        local scale = Utils.Scale(self.Instance, 1)

        local content = Utils.Create("Frame", {
            Name = "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -28, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            Parent = self.Instance
        })
        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 7)
        layout.Parent = content

        local icon = Utils.Create("TextLabel", {
            Name = "Icon",
            Text = self.Icon,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, self.Icon == "" and 0 or 14, 1, 0),
            Visible = self.Icon ~= "",
            Parent = content
        })

        self.Label = Utils.Create("TextLabel", {
            Name = "Label",
            Text = self.Text,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextMedium,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = content
        })

        local variant = tostring(self.Variant):lower()
        if variant == "primary" then
            self.Instance.BackgroundTransparency = 0
            Utils.Gradient(self.Instance, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Colors.Accent),
                ColorSequenceKeypoint.new(1, Theme.Colors.AccentLow)
            }), 135)
            stroke.Color = Theme.Colors.Accent
            stroke.Transparency = Theme.Transparencies.BorderMid
            self.Label.TextColor3 = Color3.new(1, 1, 1)
            icon.TextColor3 = Color3.new(1, 1, 1)
        elseif variant == "danger" then
            self.Instance.BackgroundTransparency = 0
            Utils.Gradient(self.Instance, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Colors.Error),
                ColorSequenceKeypoint.new(1, Theme.Colors.Error)
            }), 135)
            stroke.Color = Theme.Colors.Error
            stroke.Transparency = Theme.Transparencies.BorderMid
            self.Label.TextColor3 = Color3.new(1, 1, 1)
            icon.TextColor3 = Color3.new(1, 1, 1)
        end

        local function setHover(on)
            if self.Locked then
                return
            end
            if variant == "primary" or variant == "danger" then
                return
            end
            if on then
                TweenController:Play(self.Instance, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.SurfaceHover})
                stroke.Transparency = Theme.Transparencies.BorderMid
            else
                TweenController:Play(self.Instance, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.Surface})
                stroke.Transparency = Theme.Transparencies.Border
            end
        end

        self.Instance.MouseEnter:Connect(function()
            setHover(true)
        end)
        self.Instance.MouseLeave:Connect(function()
            setHover(false)
        end)

        self.Instance.MouseButton1Down:Connect(function()
            if self.Locked then
                return
            end
            TweenController:Play(scale, TweenController.Fast, {Scale = 0.98})
        end)
        self.Instance.MouseButton1Up:Connect(function()
            TweenController:Play(scale, TweenController.Fast, {Scale = 1})
        end)

        self.Instance.MouseButton1Click:Connect(function()
            if self.Locked then
                return
            end
            Effects.Ripple(self.Instance, self.Instance.AbsoluteSize.X / 2, self.Instance.AbsoluteSize.Y / 2)
            self.Callback()
        end)

        if self.Locked then
            self.Instance.AutoButtonColor = false
            self.Instance.Active = false
            self.Instance.BackgroundTransparency = 0.6
            self.Label.TextTransparency = 0.45
            icon.TextTransparency = 0.45
        end

        return self
    end

    return Button
end
