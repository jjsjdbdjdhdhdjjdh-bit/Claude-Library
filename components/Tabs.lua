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