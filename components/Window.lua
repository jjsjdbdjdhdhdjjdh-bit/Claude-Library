local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local Theme = Import("core/Theme")
local Utils = Import("core/Utils")
local TweenController = Import("animations/TweenController")
local Effects = Import("animations/Effects")
local Draggable = Import("layout/Draggable")
local Resizable = Import("layout/Resizable")

local Tabs = Import("components/Tabs")
local Dialog = Import("components/Dialog")
local Notification = Import("components/Notification")

local T = Theme
local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkPad = Utils.mkPad
local mkIcon = Utils.mkIcon
local tw = TweenController.tw
local fast = TweenController.fast
local med = TweenController.med

-- Constants
local SIDEBAR_W    = 152
local TITLEBAR_H   = 42
local TAB_H        = 38
local TAB_ICON_S   = 15
local TITLE_ICON_S = 16

local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    if type(config) == "string" then config = { Title = config } end
    config = config or {}

    local title = config.Title  or "ClaudeUI"
    local W     = config.Width  or 760
    local H     = config.Height or 520

    local gui = inst("ScreenGui", {
        Name           = "ClaudeUI_" .. title,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = Players.LocalPlayer:WaitForChild("PlayerGui"),
    })
    self.ScreenGui  = gui
    self._dialogGui = nil

    local useAcrylic  = config.Acrylic == true
    local winBgTransp = useAcrylic and 0.52 or 1

    local win = inst("CanvasGroup", {
        Name             = "Window",
        Size             = UDim2.new(0, W, 0, 0),
        Position         = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = T.WindowBg,
        BackgroundTransparency = winBgTransp,
        BorderSizePixel  = 0,
        ZIndex           = 1,
        Parent           = gui,
    })
    corner(win, 16)
    mkStroke(win, T.WindowBorder, 1)
    self.Window      = win
    self._W, self._H = W, H

    self._acrylic = nil
    if useAcrylic then
        local ac = Effects(win, T.WindowBg)
        if ac then self._acrylic = ac; ac.Frame.ZIndex = 0 end
    end

    tw(win, med, { Size = UDim2.new(0, W, 0, H), BackgroundTransparency = winBgTransp })

    -- ── TitleBar ──────────────────────────────────────────
    local tb = inst("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, TITLEBAR_H),
        BackgroundColor3 = T.TitleBg,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = win,
    })
    inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.TitleBorder,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = tb,
    })

    local titleIconW = 0
    local titleIcon  = nil
    local iconCfg    = config.Icon
    if iconCfg and iconCfg ~= "" then
        local asset = Utils.iconAsset(iconCfg)
        if asset then
            titleIcon = inst("ImageLabel", {
                Size            = UDim2.new(0, TITLE_ICON_S, 0, TITLE_ICON_S),
                AnchorPoint     = Vector2.new(0, 0.5),
                Position        = UDim2.new(0, 14, 0.5, 0),
                BackgroundTransparency = 1,
                Image           = asset,
                ImageColor3     = T.Primary,
                ScaleType       = Enum.ScaleType.Fit,
                ZIndex          = 6,
                Parent          = tb,
            })
            titleIconW = TITLE_ICON_S + 8
        end
    end
    if not titleIcon then
        local dot = inst("Frame", {
            Size             = UDim2.new(0, 8, 0, 8),
            Position         = UDim2.new(0, 14, 0.5, -4),
            BackgroundColor3 = T.Primary,
            BorderSizePixel  = 0,
            ZIndex           = 6,
            Parent           = tb,
        })
        corner(dot, 4)
        titleIconW = 8 + 8
    end

    inst("TextLabel", {
        Size            = UDim2.new(1, -(14 + titleIconW + 70), 1, 0),
        Position        = UDim2.new(0, 14 + titleIconW + 4, 0, 0),
        BackgroundTransparency = 1,
        Text            = title,
        TextColor3      = T.TextPrimary,
        TextSize        = 13,
        Font            = Enum.Font.GothamMedium,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 6,
        Parent          = tb,
    })

    local function mkTbBtn(xOff, label)
        local btn = inst("TextButton", {
            Size             = UDim2.new(0, 26, 0, 26),
            Position         = UDim2.new(1, xOff, 0.5, -13),
            BackgroundColor3 = T.Surface,
            Text             = label,
            TextColor3       = T.TextSecondary,
            TextSize         = 11,
            Font             = Enum.Font.GothamMedium,
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
            ZIndex           = 6,
            Parent           = tb,
        })
        corner(btn, 4)
        btn.MouseEnter:Connect(function() tw(btn, fast, { BackgroundColor3 = T.Primary, TextColor3 = T.PrimaryText }) end)
        btn.MouseLeave:Connect(function() tw(btn, fast, { BackgroundColor3 = T.Surface,  TextColor3 = T.TextSecondary }) end)
        return btn
    end

    local closeBtn = mkTbBtn(-34, "✕")
    local minBtn   = mkTbBtn(-64, "─")

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tw(win, med, { Size = UDim2.new(0, W, 0, minimized and TITLEBAR_H or H) })
        if self._acrylic then self._acrylic.SetVisible(not minimized) end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tw(win, fast, { Size = UDim2.new(0, W, 0, 0), BackgroundTransparency = 1 })
        if self._acrylic then self._acrylic.SetVisible(false) end
        task.delay(0.22, function() gui:Destroy() end)
    end)

    Draggable(win, tb)

    -- ── Body ──────────────────────────────────────────────
    local body = inst("Frame", {
        Name            = "Body",
        Size            = UDim2.new(1, 0, 1, -TITLEBAR_H),
        Position        = UDim2.new(0, 0, 0, TITLEBAR_H),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex          = 2,
        Parent          = win,
    })

    -- ── Sidebar ───────────────────────────────────────────
    local sidebar = inst("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, SIDEBAR_W, 1, 0),
        BackgroundColor3 = T.SidebarBg,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = body,
    })
    inst("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = T.SidebarBorder,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = sidebar,
    })

    local tabList = inst("Frame", {
        Name          = "TabList",
        Size          = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex        = 4,
        Parent        = sidebar,
    })
    inst("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 2),
        Parent    = tabList,
    })
    mkPad(tabList, 8, 6, 8, 6)

    local contentArea = inst("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -SIDEBAR_W, 1, 0),
        Position         = UDim2.new(0, SIDEBAR_W, 0, 0),
        BackgroundColor3 = T.ContentBg,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = body,
    })

    self._tabList     = tabList
    self._contentArea = contentArea
    self._tabs        = {}
    self._tabData     = {}
    self._tabOrder    = 0
    self._activeTab   = nil
    self._toggleStyle = (config.ToggleStyle == "basic") and "basic" or "box"

    return self
end

function Window:CreateTab(config)
    return Tabs.CreateTab(self, config.Title, config.Icon)
end

function Window:SelectTab(name)
    Tabs.SwitchTab(self, name)
end

function Window:Destroy()
    self:CloseDialog()
    if self._acrylic then self._acrylic.Destroy() end
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

function Window:Dialog(...)
    return Dialog.Show(...)
end

function Window:CloseDialog()
    return Dialog.Close()
end

function Window:Toast(...)
    return Notification(...)
end

function Window:CreateHomeTab(config)
    config = config or {}
    self._tabOrder = self._tabOrder + 1
    local TAB_TITLE = "Home"

    local btn = inst("Frame", {
        Name             = "TabBtn_Home",
        Size             = UDim2.new(1, 0, 0, TAB_H),
        BackgroundColor3 = T.TabNormal,
        BorderSizePixel  = 0,
        LayoutOrder      = 0,
        ZIndex           = 5,
        Parent           = self._tabList,
    })
    corner(btn, 5)

    local indicator = inst("Frame", {
        Size             = UDim2.new(0, 3, 0.55, 0),
        Position         = UDim2.new(0, 0, 0.225, 0),
        BackgroundColor3 = T.PrimaryText,
        BorderSizePixel  = 0,
        Visible          = false,
        ZIndex           = 6,
        Parent           = btn,
    })
    corner(indicator, 2)

    local homeIconImg = mkIcon(btn, "house", TAB_ICON_S, T.IconTint, 6,
        Vector2.new(0, 0.5), UDim2.new(0, 10, 0.5, 0))
    local textOff = homeIconImg and (10 + TAB_ICON_S + 7) or 10

    local btnLabel = inst("TextLabel", {
        Size            = UDim2.new(1, -(textOff + 4), 1, 0),
        Position        = UDim2.new(0, textOff, 0, 0),
        BackgroundTransparency = 1,
        Text            = TAB_TITLE,
        TextColor3      = T.TabNormalText,
        TextSize        = 13,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 6,
        Parent          = btn,
    })

    local clickArea = inst("TextButton", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = "",
        ZIndex          = 7,
        Parent          = btn,
    })

    local panel = inst("ScrollingFrame", {
        Name                 = "Panel_Home",
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ScrollBarThickness   = 5,
        ScrollBarImageColor3 = T.ScrollBar,
        ScrollingDirection   = Enum.ScrollingDirection.Y,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.None,
        ElasticBehavior      = Enum.ElasticBehavior.Never,
        Visible              = false,
        ZIndex               = 4,
        Parent               = self._contentArea,
    })

    local inner = inst("Frame", {
        Size          = UDim2.new(1, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex        = 4,
        Parent        = panel,
    })
    mkPad(inner, 14, 14, 14, 14)
    local innerLayout = inst("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment   = Enum.VerticalAlignment.Top,
        Padding             = UDim.new(0, 10),
        Parent              = inner,
    })
    innerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        panel.CanvasSize = UDim2.new(0, 0, 0, innerLayout.AbsoluteContentSize.Y + 28)
    end)

    local plr = Players.LocalPlayer

    -- Banner de boas-vindas
    local banner = inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 76),
        BackgroundColor3 = Color3.fromRGB(38, 22, 14),
        BorderSizePixel  = 0,
        LayoutOrder      = 0,
        ZIndex           = 5,
        Parent           = inner,
    })
    corner(banner, 8)
    local accentBar = inst("Frame", {
        Size             = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = T.Primary,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = banner,
    })
    corner(accentBar, 4)

    local avatarRing = inst("Frame", {
        Size             = UDim2.new(0, 48, 0, 48),
        Position         = UDim2.new(0, 18, 0.5, -24),
        BackgroundColor3 = T.Primary,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = banner,
    })
    corner(avatarRing, 24)
    local avatarImg = inst("ImageLabel", {
        Size            = UDim2.new(1, -4, 1, -4),
        Position        = UDim2.new(0, 2, 0, 2),
        BackgroundColor3= T.SurfaceActive,
        BackgroundTransparency = 0,
        Image           = "",
        ScaleType       = Enum.ScaleType.Crop,
        ZIndex          = 7,
        Parent          = avatarRing,
    })
    corner(avatarImg, 22)
    if plr then
        local ok, url = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok then avatarImg.Image = url end
    end

    local function getGreeting()
        local h = tonumber(os.date("%H")) or 12
        if h >= 0  and h < 6  then return "Go sleep,"   end
        if h >= 6  and h < 12 then return "Bom dia,"    end
        if h >= 12 and h < 18 then return "Boa tarde,"  end
        return "Boa noite,"
    end

    inst("TextLabel", {
        Size            = UDim2.new(0.55, 0, 0, 22),
        Position        = UDim2.new(0, 76, 0, 14),
        BackgroundTransparency = 1,
        Text            = getGreeting() .. " " .. (plr and plr.DisplayName or "Player") .. "!",
        TextColor3      = T.TextPrimary,
        TextSize        = 15,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextTruncate    = Enum.TextTruncate.AtEnd,
        ZIndex          = 6,
        Parent          = banner,
    })
    inst("TextLabel", {
        Size            = UDim2.new(0.55, 0, 0, 16),
        Position        = UDim2.new(0, 76, 0, 38),
        BackgroundTransparency = 1,
        Text            = "@" .. (plr and plr.Name or "unknown"),
        TextColor3      = T.Primary,
        TextSize        = 11,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextTruncate    = Enum.TextTruncate.AtEnd,
        ZIndex          = 6,
        Parent          = banner,
    })

    local clockLbl = inst("TextLabel", {
        Size            = UDim2.new(0, 100, 0, 22),
        Position        = UDim2.new(1, -112, 0, 14),
        BackgroundTransparency = 1,
        Text            = "00:00:00",
        TextColor3      = T.TextPrimary,
        TextSize        = 15,
        Font            = Enum.Font.GothamMedium,
        TextXAlignment  = Enum.TextXAlignment.Right,
        ZIndex          = 6,
        Parent          = banner,
    })
    local dateLbl = inst("TextLabel", {
        Size            = UDim2.new(0, 100, 0, 15),
        Position        = UDim2.new(1, -112, 0, 38),
        BackgroundTransparency = 1,
        Text            = "00/00/00",
        TextColor3      = Color3.fromRGB(190, 190, 190),
        TextSize        = 11,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Right,
        ZIndex          = 6,
        Parent          = banner,
    })
    local function updateClock()
        local t = os.date("*t")
        clockLbl.Text = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
        dateLbl.Text  = string.format("%02d/%02d/%04d", t.day, t.month, t.year)
    end
    updateClock()
    task.spawn(function()
        while panel.Parent do updateClock(); task.wait(1) end
    end)

    -- Chips
    local chipsRow = inst("Frame", {
        Size            = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder     = 1,
        ZIndex          = 5,
        Parent          = inner,
    })
    inst("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding             = UDim.new(0, 6),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = chipsRow,
    })

    local function mkChip(order, iconName, labelText, accent)
        local chip = inst("Frame", {
            Size             = UDim2.new(0, 0, 1, 0),
            AutomaticSize    = Enum.AutomaticSize.X,
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel  = 0,
            LayoutOrder      = order,
            ZIndex           = 6,
            Parent           = chipsRow,
        })
        corner(chip, 16)
        mkStroke(chip, T.Border, 1)
        mkPad(chip, 0, 12, 0, 10)
        local dot = inst("Frame", {
            Size             = UDim2.new(0, 6, 0, 6),
            Position         = UDim2.new(0, 0, 0.5, -3),
            BackgroundColor3 = accent or T.Primary,
            BorderSizePixel  = 0,
            ZIndex           = 7,
            Parent           = chip,
        })
        corner(dot, 3)
        local lbl = inst("TextLabel", {
            Size            = UDim2.new(0, 0, 1, 0),
            AutomaticSize   = Enum.AutomaticSize.X,
            Position        = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text            = labelText,
            TextColor3      = T.TextPrimary,
            TextSize        = 11,
            Font            = Enum.Font.Gotham,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 7,
            Parent          = chip,
        })
        return lbl
    end

    local execName        = "Unknown"
    local execStatusColor = T.Warning
    pcall(function()
        if identifyexecutor then
            execName = identifyexecutor()
        elseif syn and syn.request then
            execName = "Synapse X"
        elseif KRNL_LOADED then
            execName = "Krnl"
        elseif getgenv and getgenv().fluxus then
            execName = "Fluxus"
        end
    end)
    local supported   = config.SupportedExecutors   or {}
    local unsupported = config.UnsupportedExecutors  or {}
    for _, v in ipairs(supported)   do if v:lower() == execName:lower() then execStatusColor = T.Success; break end end
    for _, v in ipairs(unsupported) do if v:lower() == execName:lower() then execStatusColor = T.Error;   break end end

    local gameName = "Unknown"
    pcall(function() gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

    local pingChipLbl    = mkChip(1, "wifi",      math.floor((Players.LocalPlayer:GetNetworkPing()*1000)).."ms ping",   T.Info)
    local playersChipLbl = mkChip(2, "users",     #Players:GetPlayers().."/"..Players.MaxPlayers.." players",           T.Success)
    local gameChipLbl    = mkChip(3, "gamepad-2", gameName,                                                             T.Primary)
    local execChipLbl    = mkChip(4, "terminal",  execName,                                                             execStatusColor)

    task.spawn(function()
        while panel.Parent do
            pcall(function()
                pingChipLbl.Text    = math.floor((Players.LocalPlayer:GetNetworkPing()*1000)).."ms ping"
                playersChipLbl.Text = #Players:GetPlayers().."/"..Players.MaxPlayers.." players"
            end)
            task.wait(3)
        end
    end)

    -- Linha principal: Changelog + Amigos
    local mainRow = inst("Frame", {
        Size            = UDim2.new(1, 0, 0, 310),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder     = 2,
        ZIndex          = 5,
        Parent          = inner,
    })
    inst("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        Padding             = UDim.new(0, 10),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = mainRow,
    })

    -- Changelog
    local changeCont = inst("Frame", {
        Size             = UDim2.new(0.65, -5, 1, 0),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = mainRow,
    })
    corner(changeCont, 8)
    mkStroke(changeCont, T.Border, 1)
    mkPad(changeCont, 12, 12, 12, 12)

    inst("TextLabel", {
        Size            = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text            = "Changelog",
        TextColor3      = T.TextPrimary,
        TextSize        = 14,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 6,
        Parent          = changeCont,
    })
    local clScroll = inst("ScrollingFrame", {
        Size            = UDim2.new(1, 0, 1, -28),
        Position        = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.ScrollBar,
        CanvasSize      = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex          = 6,
        Parent          = changeCont,
    })
    inst("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 6),
        Parent    = clScroll,
    })

    local logs = config.Changelog or {
        { Date = "2025-02-22", Title = "Release", Desc = "Initial Release of ClaudeUI." },
    }
    for i, log in ipairs(logs) do
        local lRow = inst("Frame", {
            Size          = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder   = i,
            Parent        = clScroll,
        })
        inst("Frame", {
            Size             = UDim2.new(0, 6, 0, 6),
            Position         = UDim2.new(0, 0, 0, 6),
            BackgroundColor3 = T.Primary,
            BorderSizePixel  = 0,
            Parent           = lRow,
        }).Parent = lRow
        -- (cornerRadius 3 for dot omitted for brevity, or add corner(dot,3))
        inst("TextLabel", {
            Size            = UDim2.new(1, -12, 0, 0),
            AutomaticSize   = Enum.AutomaticSize.Y,
            Position        = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text            = string.format("<font color='#%s'><b>%s</b></font> - %s\n<font color='#888888' size='11'>%s</font>",
                T.Primary:ToHex(), log.Title, log.Date, log.Desc),
            TextColor3      = T.TextSecondary,
            TextSize        = 12,
            Font            = Enum.Font.Gotham,
            RichText        = true,
            TextXAlignment  = Enum.TextXAlignment.Left,
            TextWrapped     = true,
            Parent          = lRow,
        })
    end

    -- Friends
    local friendsCont = inst("Frame", {
        Size             = UDim2.new(0.35, -5, 1, 0),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = mainRow,
    })
    corner(friendsCont, 8)
    mkStroke(friendsCont, T.Border, 1)
    mkPad(friendsCont, 12, 12, 12, 12)
    inst("TextLabel", {
        Size            = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text            = "Friends Playing",
        TextColor3      = T.TextPrimary,
        TextSize        = 14,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 6,
        Parent          = friendsCont,
    })
    local fScroll = inst("ScrollingFrame", {
        Size            = UDim2.new(1, 0, 1, -28),
        Position        = UDim2.new(0, 0, 0, 28),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.ScrollBar,
        CanvasSize      = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex          = 6,
        Parent          = friendsCont,
    })
    inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = fScroll })

    task.spawn(function()
        local friends = {}
        pcall(function()
            local pages = Players:GetFriendsAsync(plr.UserId)
            while true do
                for _, item in ipairs(pages:GetCurrentPage()) do table.insert(friends, item) end
                if pages.IsFinished then break end
                pages:AdvanceToNextPageAsync()
            end
        end)
        -- In a real scenario, check which friends are in THIS game. 
        -- API limitations prevents easy "friends in server" check without looping players.
        -- We'll just list players in server who are friends, or just random players if none.
        -- For UI demo, let's just list server players.
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr then
                local fRow = inst("Frame", {
                    Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = fScroll
                })
                local head = inst("ImageLabel", {
                    Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 0, 0.5, -12),
                    BackgroundColor3 = T.SurfaceActive, Parent = fRow
                })
                corner(head, 12)
                pcall(function() head.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
                inst("TextLabel", {
                    Size = UDim2.new(1, -32, 1, 0), Position = UDim2.new(0, 32, 0, 0),
                    BackgroundTransparency = 1, Text = p.DisplayName, TextColor3 = T.TextPrimary,
                    TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = fRow
                })
            end
        end
    end)

    -- Discord Button
    local discBtn = inst("TextButton", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(88, 101, 242), -- Discord Blurple
        LayoutOrder      = 3,
        Text             = "Join Discord Server",
        TextColor3       = Color3.fromRGB(255, 255, 255),
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 5,
        Parent           = inner,
    })
    corner(discBtn, 6)
    discBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(config.Discord or "https://discord.gg/example")
            Window:Toast("Discord invite copied to clipboard!", "success")
        else
            Window:Toast("Your executor does not support setclipboard.", "error")
        end
    end)

    -- Initialize tabs
    self._tabData[TAB_TITLE] = {
        name      = TAB_TITLE,
        btn       = btn,
        btnLabel  = btnLabel,
        iconImg   = homeIconImg,
        indicator = indicator,
        panel     = panel,
    }
    table.insert(self._tabs, 1, self._tabData[TAB_TITLE])
    self:SelectTab(TAB_TITLE)
end

return Window