return function(Theme, Utils, TweenController)
    local Notification = {}

    local Container = nil

    function Notification.Init(parentGui)
        if Container then return end
        Container = Utils.Create("Frame", {
            Name = "NotificationContainer",
            Size = UDim2.new(0, 320, 1, -20),
            Position = UDim2.new(1, -340, 0, 20),
            BackgroundTransparency = 1,
            Parent = parentGui
        })

        Utils.Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Parent = Container
        })
    end

    function Notification.New(config)
        if not Container then
            return
        end

        local text = config.Text or config.Title or "Notificação"
        local duration = config.Duration or 4
        local kind = (config.Type or "info"):lower()

        local color = Theme.Colors.Info
        local icon = "i"
        if kind == "success" then
            color = Theme.Colors.Success
            icon = "✓"
        elseif kind == "warning" then
            color = Theme.Colors.Warning
            icon = "!"
        elseif kind == "error" then
            color = Theme.Colors.Error
            icon = "×"
        end

        local toast = Utils.Create("Frame", {
            Name = "Toast",
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = Container,
            ClipsDescendants = true
        })
        Utils.Corner(toast, Theme.Sizes.RadiusMedium)
        Utils.Stroke(toast, Theme.Colors.Border, 1, Theme.Transparencies.Border)

        local bar = Utils.Create("Frame", {
            Name = "Bar",
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = toast
        })
        Utils.Corner(bar, UDim.new(1, 0))

        local iconLabel = Utils.Create("TextLabel", {
            Name = "Icon",
            Text = icon,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = color,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 22, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            Parent = toast
        })

        local label = Utils.Create("TextLabel", {
            Text = text,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = toast
        })

        TweenController:Play(toast, TweenController.Spring, {Size = UDim2.new(1, 0, 0, 50)})

        local progress = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Parent = toast
        })

        TweenController:Play(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})

        task.delay(duration, function()
            TweenController:Play(toast, TweenController.Smooth, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
            task.wait(0.35)
            if toast then
                toast:Destroy()
            end
        end)
    end

    return Notification
end
