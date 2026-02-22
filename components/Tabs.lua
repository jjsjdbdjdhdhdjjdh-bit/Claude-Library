return function(Theme, Utils, TweenController)
    local Tabs = {}
    Tabs.__index = Tabs

    function Tabs.new(parent, config)
        local self = setmetatable({}, Tabs)

        self.Config = config or {}
        self.Instance = Utils.Create("Frame", {
            Name = "TabsContainer",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = parent
        })

        self.ButtonsContainer = Utils.Create("ScrollingFrame", {
            Name = "TabButtons",
            Size = UDim2.new(0, 120, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            Parent = self.Instance
        })
        
        self.ButtonsLayout = Utils.Create("UIListLayout", {
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.ButtonsContainer
        })

        self.ContentContainer = Utils.Create("Frame", {
            Name = "TabContent",
            Size = UDim2.new(1, -130, 1, 0),
            Position = UDim2.new(0, 130, 0, 0),
            BackgroundTransparency = 1,
            Parent = self.Instance
        })

        self.Pages = {}
        self.ActivePage = nil

        return self
    end

    function Tabs:AddTab(name, options)
        local opts = options or {}
        local TabBtn = Utils.Create("TextButton", {
            Name = name .. "_Btn",
            Text = "",
            Size = UDim2.new(1, -12, 0, 38),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            AutoButtonColor = false,
            Parent = self.ButtonsContainer
        })
        Utils.Corner(TabBtn, Theme.Sizes.RadiusSmall)

        local accent = Utils.Create("Frame", {
            Name = "Accent",
            Size = UDim2.new(0, 3, 1, -12),
            Position = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = Theme.Colors.Accent,
            BackgroundTransparency = 1,
            Parent = TabBtn
        })
        Utils.Corner(accent, UDim.new(1, 0))

        local Label = Utils.Create("TextLabel", {
            Text = name,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.TextMed,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 18, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn
        })

        local Badge = nil
        if opts.Badge then
            Badge = Utils.Create("TextLabel", {
                Text = tostring(opts.Badge),
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextHigh,
                BackgroundColor3 = Theme.Colors.Accent,
                BackgroundTransparency = 0,
                Size = UDim2.new(0, 22, 0, 18),
                Position = UDim2.new(1, -28, 0.5, -9),
                Parent = TabBtn
            })
            Utils.Corner(Badge, Theme.Sizes.RadiusSmall)
        end

        local Page = Utils.Create("ScrollingFrame", {
            Name = name .. "_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            Visible = false,
            Parent = self.ContentContainer
        })
        
        local PageLayout = Utils.Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Page
        })

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        local TabObj = {
            Button = TabBtn,
            Label = Label,
            Page = Page,
            Name = name,
            Accent = accent,
            Badge = Badge
        }

        TabBtn.MouseButton1Click:Connect(function()
            self:Select(TabObj)
        end)

        table.insert(self.Pages, TabObj)

        if #self.Pages == 1 then
            self:Select(TabObj)
        end

        return Page -- Return page so elements can be parented to it
    end

    function Tabs:Select(tabObj)
        if self.ActivePage == tabObj then return end

        if self.ActivePage then
            TweenController:Play(self.ActivePage.Button, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.Surface})
            TweenController:Play(self.ActivePage.Label, TweenController.Smooth, {TextColor3 = Theme.Colors.TextMed})
            TweenController:Play(self.ActivePage.Accent, TweenController.Smooth, {BackgroundTransparency = 1})
            self.ActivePage.Page.Visible = false
        end

        self.ActivePage = tabObj
        TweenController:Play(tabObj.Button, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.SurfaceHover})
        TweenController:Play(tabObj.Label, TweenController.Smooth, {TextColor3 = Theme.Colors.TextHigh})
        TweenController:Play(tabObj.Accent, TweenController.Smooth, {BackgroundTransparency = 0})
        tabObj.Page.Visible = true

        tabObj.Page.CanvasPosition = Vector2.new(0,0)
    end

    return Tabs
end
