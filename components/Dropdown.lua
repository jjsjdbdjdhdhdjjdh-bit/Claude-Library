return function(Theme, Utils, TweenController, Effects)
    local Dropdown = {}
    Dropdown.__index = Dropdown

    function Dropdown.new(parent, config)
        local self = setmetatable({}, Dropdown)

        self.Config = config or {}
        self.Text = self.Config.Text or "Dropdown"
        self.Items = self.Config.Items or {}
        self.MultiSelect = self.Config.MultiSelect or false
        self.EmptyText = self.Config.EmptyText or (self.MultiSelect and "Nenhuma" or "Selecionar")
        self.Callback = self.Config.Callback or function() end

        self.Open = false
        self.Selected = self.MultiSelect and {} or nil
        if self.Config.Default ~= nil then
            if self.MultiSelect then
                if type(self.Config.Default) == "table" then
                    self.Selected = {}
                    for _, item in ipairs(self.Config.Default) do
                        table.insert(self.Selected, item)
                    end
                else
                    self.Selected = {self.Config.Default}
                end
            else
                self.Selected = self.Config.Default
            end
        end

        self.Instance = Utils.Create("Frame", {
            Name = "DropdownWrap",
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = parent,
            ClipsDescendants = true
        })
        Utils.Corner(self.Instance, Theme.Sizes.RadiusMedium)
        Utils.Stroke(self.Instance, Theme.Colors.Border, 1, Theme.Transparencies.Border)

        self.Header = Utils.Create("TextButton", {
            Name = "Header",
            Text = "",
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Parent = self.Instance
        })

        self.Label = Utils.Create("TextLabel", {
            Name = "Title",
            Text = self.Text,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextMedium,
            TextColor3 = Theme.Colors.TextMed,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -120, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Header
        })

        self.ValueLabel = Utils.Create("TextLabel", {
            Name = "Value",
            Text = self.EmptyText,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 90, 1, 0),
            Position = UDim2.new(1, -120, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = self.Header
        })

        self.Arrow = Utils.Create("TextLabel", {
            Name = "Arrow",
            Text = "▾",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -30, 0.5, -10),
            Parent = self.Header
        })

        self.ListContainer = Utils.Create("ScrollingFrame", {
            Name = "List",
            Size = UDim2.new(1, -4, 0, 0),
            Position = UDim2.new(0, 2, 0, 48),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Colors.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = self.Instance,
            Visible = false
        })

        self.ListLayout = Utils.Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.ListContainer
        })

        self.Header.MouseButton1Click:Connect(function()
            self:Toggle()
        end)

        self:Refresh(self.Items)

        return self
    end

    function Dropdown:Toggle()
        self.Open = not self.Open
        local contentHeight = self.ListLayout.AbsoluteContentSize.Y
        local targetHeight = self.Open and math.min(contentHeight + 60, 220) or 44
        local arrowRotation = self.Open and 180 or 0
        self.ListContainer.Visible = true
        TweenController:Play(self.Instance, TweenController.Spring, {Size = UDim2.new(1, 0, 0, targetHeight)})
        TweenController:Play(self.Arrow, TweenController.Smooth, {Rotation = arrowRotation})
        if not self.Open then
            task.delay(0.25, function()
                if not self.Open then
                    self.ListContainer.Visible = false
                end
            end)
        end
    end

    function Dropdown:Refresh(items)
        self.Items = items or {}
        for _, child in ipairs(self.ListContainer:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, item in ipairs(self.Items) do
            local itemBtn = Utils.Create("TextButton", {
                Name = tostring(item),
                Text = "",
                Size = UDim2.new(1, -10, 0, 34),
                BackgroundColor3 = Theme.Colors.Background,
                BackgroundTransparency = Theme.Transparencies.Surface,
                AutoButtonColor = false,
                Parent = self.ListContainer
            })
            Utils.Corner(itemBtn, Theme.Sizes.RadiusSmall)
            Utils.Stroke(itemBtn, Theme.Colors.Border, 1, Theme.Transparencies.Border)

            local itemLabel = Utils.Create("TextLabel", {
                Text = tostring(item),
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextNormal,
                TextColor3 = Theme.Colors.TextMed,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = itemBtn
            })

            local check = Utils.Create("TextLabel", {
                Name = "Check",
                Text = "✓",
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextNormal,
                TextColor3 = Theme.Colors.Accent,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -26, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Right,
                Visible = false,
                Parent = itemBtn
            })

            itemBtn.MouseEnter:Connect(function()
                TweenController:Play(itemBtn, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.SurfaceHover})
            end)
            itemBtn.MouseLeave:Connect(function()
                TweenController:Play(itemBtn, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.Surface})
            end)

            itemBtn.MouseButton1Click:Connect(function()
                self:Select(item)
                Effects.Ripple(itemBtn, itemBtn.AbsoluteSize.X / 2, itemBtn.AbsoluteSize.Y / 2)
            end)
        end

        self.ListContainer.CanvasSize = UDim2.new(0, 0, 0, self.ListLayout.AbsoluteContentSize.Y + 12)
        self:UpdateVisuals()
    end

    function Dropdown:UpdateVisuals()
        if self.MultiSelect then
            local count = #self.Selected
            if count == 0 then
                self.ValueLabel.Text = self.EmptyText
                self.ValueLabel.TextColor3 = Theme.Colors.TextLow
            else
                self.ValueLabel.Text = tostring(count) .. " selecionado(s)"
                self.ValueLabel.TextColor3 = Theme.Colors.TextHigh
            end
        else
            if self.Selected then
                self.ValueLabel.Text = tostring(self.Selected)
                self.ValueLabel.TextColor3 = Theme.Colors.TextHigh
            else
                self.ValueLabel.Text = self.EmptyText
                self.ValueLabel.TextColor3 = Theme.Colors.TextLow
            end
        end

        for _, child in ipairs(self.ListContainer:GetChildren()) do
            if child:IsA("TextButton") then
                local check = child:FindFirstChild("Check")
                if check then
                    if self.MultiSelect then
                        check.Visible = table.find(self.Selected, child.Name) ~= nil
                    else
                        check.Visible = self.Selected == child.Name
                    end
                end
            end
        end
    end

    function Dropdown:Select(item)
        if self.MultiSelect then
            local idx = table.find(self.Selected, item)
            if idx then
                table.remove(self.Selected, idx)
            else
                table.insert(self.Selected, item)
            end
            self:UpdateVisuals()
            self.Callback(self.Selected)
        else
            self.Selected = item
            self:UpdateVisuals()
            self.Callback(item)
            self:Toggle()
        end
    end

    return Dropdown
end
