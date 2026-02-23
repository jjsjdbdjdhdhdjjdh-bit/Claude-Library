<<<<<<< HEAD
local Theme = Import("core/Theme")
local Utils = Import("core/Utils")
local TweenController = Import("animations/TweenController")

local Button = Import("components/Button")
local Toggle = Import("components/Toggle")
local Slider = Import("components/Slider")
local Input = Import("components/Input")
local Dropdown = Import("components/Dropdown")

local T = Theme
local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkPad = Utils.mkPad
local mkIcon = Utils.mkIcon
local tw = TweenController.tw
local fast = TweenController.fast

local TabAPI = {}
TabAPI.__index = TabAPI

function TabAPI:_o()
    self._order = self._order + 1
    return self._order
end

function TabAPI:AddLabel(text, opts)
    opts = opts or {}
    return inst("TextLabel", {
        Size          = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text          = text,
        TextColor3    = opts.Color or T.TextSecondary,
        TextSize      = opts.TextSize or 10,
        Font          = opts.Font or Enum.Font.Gotham,
        TextXAlignment= opts.Align or Enum.TextXAlignment.Left,
        TextWrapped   = true,
        RichText      = opts.Rich or false,
        LayoutOrder   = opts.Order or self:_o(),
        ZIndex        = 4,
        Parent        = self._inner,
    })
end

function TabAPI:AddSeparator()
    return inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        LayoutOrder      = self:_o(),
        ZIndex           = 4,
        Parent           = self._inner,
    })
end

function TabAPI:AddButton(text, callback, opts)
    opts = opts or {}
    opts.Order = opts.Order or self:_o()
    return Button.Create(self._inner, text, callback, opts)
end

function TabAPI:AddToggle(label, default, callback, opts)
    opts = opts or {}
    opts.Order = opts.Order or self:_o()
    opts.Style = opts.Style or self._win._toggleStyle
    return Toggle.Create(self._inner, label, default, callback, opts)
end

function TabAPI:AddSlider(label, min, max, default, callback, opts)
    opts = opts or {}
    opts.Order = opts.Order or self:_o()
    return Slider.Create(self._inner, label, min, max, default, callback, opts)
end

function TabAPI:AddInput(placeholder, callback, opts)
    opts = opts or {}
    opts.Order = opts.Order or self:_o()
    return Input.Create(self._inner, placeholder, callback, opts)
end

function TabAPI:AddDropdown(label, items, callback, opts)
    opts = opts or {}
    opts.Order = opts.Order or self:_o()
    return Dropdown.Create(self._inner, label, items, callback, opts)
end

local Tabs = {}

function Tabs.SwitchTab(window, name)
    if window._activeTab == name then return end
    for _, tabData in pairs(window._tabData) do
        tw(tabData.btn,      fast, { BackgroundColor3 = T.TabNormal })
        tw(tabData.btnLabel, fast, { TextColor3 = T.TabNormalText })
        tabData.btnLabel.Font     = Enum.Font.Gotham
        if tabData.iconImg then tw(tabData.iconImg, fast, { ImageColor3 = T.IconTint }) end
        tabData.indicator.Visible = false
        tabData.panel.Visible     = false
    end
    local next = window._tabData[name]
    if next then
        tw(next.btn,      fast, { BackgroundColor3 = T.TabActive })
        tw(next.btnLabel, fast, { TextColor3 = T.TabActiveText })
        next.btnLabel.Font     = Enum.Font.GothamMedium
        if next.iconImg then tw(next.iconImg, fast, { ImageColor3 = T.IconTintActive }) end
        next.indicator.Visible = true
        next.panel.Visible     = true
    end
    window._activeTab = name
end

function Tabs.CreateTab(window, tabTitle, iconName)
    local tabList   = window._tabList
    local content   = window._contentArea
    
    local btn = inst("TextButton", {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.TabNormal,
        BackgroundTransparency = 0,
        Text             = "",
        AutoButtonColor  = false,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = tabList,
    })
    corner(btn, 6)

    local iconW   = 0
    local iconImg = mkIcon(btn, iconName, 14, T.IconTint, 6,
        Vector2.new(0, 0.5), UDim2.new(0, 10, 0.5, 0))
    if iconImg then iconW = 14 + 8 end

    local btnLabel = inst("TextLabel", {
        Size            = UDim2.new(1, -(12 + iconW), 1, 0),
        Position        = UDim2.new(0, 10 + iconW, 0, 0),
        BackgroundTransparency = 1,
        Text            = tabTitle,
        TextColor3      = T.TabNormalText,
        TextSize        = 12,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 6,
        Parent          = btn,
    })
    
    local indicator = inst("Frame", {
        Size             = UDim2.new(0, 3, 0, 16),
        Position         = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = T.Primary,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 7,
        Parent           = btn,
    })
    corner(indicator, 2)

    local panel = inst("ScrollingFrame", {
        Name             = tabTitle .. "_Panel",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.ScrollBar,
        CanvasSize       = UDim2.new(0, 0, 0, 0),
        Visible          = false,
        ZIndex           = 5,
        Parent           = content,
    })
    mkPad(panel, 2, 10, 2, 2) -- padding right 10 for scrollbar
    
    local inner = inst("Frame", {
        Size          = UDim2.new(1, -6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent        = panel,
    })
    local layout = inst("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 10),
        Parent    = inner,
    })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        panel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local clickArea = inst("TextButton", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=10, Parent=btn
    })
    btn.MouseEnter:Connect(function()
        if window._activeTab ~= tabTitle then
            tw(btn, fast, { BackgroundColor3 = T.SurfaceHover })
            tw(btnLabel, fast, { TextColor3 = T.TextPrimary })
            if iconImg then tw(iconImg, fast, { ImageColor3 = T.TextPrimary }) end
        end
    end)
    btn.MouseLeave:Connect(function()
        if window._activeTab ~= tabTitle then
            tw(btn, fast, { BackgroundColor3 = T.TabNormal })
            tw(btnLabel, fast, { TextColor3 = T.TabNormalText })
            if iconImg then tw(iconImg, fast, { ImageColor3 = T.IconTint }) end
        end
    end)
    clickArea.MouseButton1Click:Connect(function() Tabs.SwitchTab(window, tabTitle) end)

    local tabData = {
        name      = tabTitle,
        btn       = btn,
        btnLabel  = btnLabel,
        iconImg   = iconImg,
        indicator = indicator,
        panel     = panel,
    }
    table.insert(window._tabs, tabData)
    window._tabData[tabTitle] = tabData
    if not window._activeTab then Tabs.SwitchTab(window, tabTitle) end

    local tabObj = { _inner = inner, _order = 2, _win = window }
    setmetatable(tabObj, TabAPI)
    return tabObj
end

return Tabs
=======
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
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
