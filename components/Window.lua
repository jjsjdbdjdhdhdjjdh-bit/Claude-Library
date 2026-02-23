<<<<<<< HEAD
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
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, 8),
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Parent        = mainRow,
    })

    -- Changelog
    local clPanel = inst("ScrollingFrame", {
        Size                 = UDim2.new(0.6, -4, 1, 0),
        BackgroundColor3     = Color3.fromRGB(30, 30, 30),
        BorderSizePixel      = 0,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = T.ScrollBar,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        LayoutOrder          = 1,
        ZIndex               = 5,
        Parent               = mainRow,
    })
    corner(clPanel, 7)
    mkStroke(clPanel, Color3.fromRGB(70, 70, 70), 1)

    local clInner = inst("Frame", {
        Size          = UDim2.new(1, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex        = 6,
        Parent        = clPanel,
    })
    mkPad(clInner, 10, 10, 10, 14)
    inst("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 0),
        Parent    = clInner,
    })

    local clHdr = inst("Frame", {
        Size            = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder     = 0,
        ZIndex          = 6,
        Parent          = clInner,
    })
    mkIcon(clHdr, "history", 13, T.Primary, 7, Vector2.new(0, 0.5), UDim2.new(0, 0, 0.5, 0))
    inst("TextLabel", {
        Size            = UDim2.new(1, -20, 1, 0),
        Position        = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text            = "Changelog",
        TextColor3      = T.TextPrimary,
        TextSize        = 13,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 7,
        Parent          = clHdr,
    })

    local changelog = config.Changelog or {}
    for i, entry in ipairs(changelog) do
        local isLast = (i == #changelog)
        local row = inst("Frame", {
            Size            = UDim2.new(1, 0, 0, 0),
            AutomaticSize   = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder     = i,
            ZIndex          = 6,
            Parent          = clInner,
        })
        inst("Frame", {
            Size             = UDim2.new(0, 1, 1, 0),
            Position         = UDim2.new(0, 5, 0, 14),
            BackgroundColor3 = T.Border,
            BorderSizePixel  = 0,
            Visible          = not isLast,
            ZIndex           = 7,
            Parent           = row,
        })
        local dot = inst("Frame", {
            Size             = UDim2.new(0, 11, 0, 11),
            Position         = UDim2.new(0, 0, 0, 7),
            BackgroundColor3 = (i == 1) and T.Primary or T.Border,
            BorderSizePixel  = 0,
            ZIndex           = 8,
            Parent           = row,
        })
        corner(dot, 6)
        if i == 1 then
            local dotGlow = inst("Frame", {
                Size             = UDim2.new(0, 5, 0, 5),
                Position         = UDim2.new(0.5, -2, 0.5, -2),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.4,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = dot,
            })
            corner(dotGlow, 3)
        end
        local entryContent = inst("Frame", {
            Size          = UDim2.new(1, -24, 0, 0),
            Position      = UDim2.new(0, 22, 0, 2),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            ZIndex        = 7,
            Parent        = row,
        })
        inst("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = entryContent })
        local titleRow = inst("Frame", {
            Size            = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            LayoutOrder     = 1,
            ZIndex          = 7,
            Parent          = entryContent,
        })
        inst("TextLabel", {
            Size            = UDim2.new(0.55, 0, 1, 0),
            BackgroundTransparency = 1,
            Text            = entry.Title or "",
            TextColor3      = (i == 1) and T.TextPrimary or Color3.fromRGB(200, 200, 200),
            TextSize        = 12,
            Font            = (i == 1) and Enum.Font.GothamBold or Enum.Font.GothamMedium,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 8,
            Parent          = titleRow,
        })
        inst("TextLabel", {
            Size            = UDim2.new(0.45, 0, 1, 0),
            Position        = UDim2.new(0.55, 0, 0, 0),
            BackgroundTransparency = 1,
            Text            = entry.Date or "",
            TextColor3      = (i == 1) and T.Primary or Color3.fromRGB(150, 150, 150),
            TextSize        = 10,
            Font            = Enum.Font.Gotham,
            TextXAlignment  = Enum.TextXAlignment.Right,
            ZIndex          = 8,
            Parent          = titleRow,
        })
        if entry.Description and entry.Description ~= "" then
            inst("TextLabel", {
                Size            = UDim2.new(1, 0, 0, 0),
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text            = entry.Description,
                TextColor3      = Color3.fromRGB(185, 185, 185),
                TextSize        = 10,
                Font            = Enum.Font.Gotham,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextWrapped     = true,
                LayoutOrder     = 2,
                ZIndex          = 8,
                Parent          = entryContent,
            })
        end
        inst("Frame", {
            Size            = UDim2.new(1, 0, 0, 10),
            BackgroundTransparency = 1,
            LayoutOrder     = 3,
            ZIndex          = 6,
            Parent          = entryContent,
        })
    end

    -- Painel de amigos
    local friendsPanel = inst("Frame", {
        Size             = UDim2.new(0.4, -4, 1, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel  = 0,
        LayoutOrder      = 2,
        ZIndex           = 5,
        Parent           = mainRow,
    })
    corner(friendsPanel, 7)
    mkStroke(friendsPanel, Color3.fromRGB(70, 70, 70), 1)

    local fHdr = inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = friendsPanel,
    })
    corner(fHdr, 7)
    inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = fHdr,
    })
    mkIcon(fHdr, "users", 13, T.Primary, 7, Vector2.new(0, 0.5), UDim2.new(0, 12, 0.5, 0))
    inst("TextLabel", {
        Size            = UDim2.new(1, -34, 1, 0),
        Position        = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text            = "Amigos",
        TextColor3      = T.TextPrimary,
        TextSize        = 13,
        Font            = Enum.Font.GothamBold,
        ZIndex          = 7,
        Parent          = fHdr,
    })
    local fCountLbl = inst("TextLabel", {
        Size            = UDim2.new(0, 40, 1, 0),
        Position        = UDim2.new(1, -44, 0, 0),
        BackgroundTransparency = 1,
        Text            = "...",
        TextColor3      = Color3.fromRGB(190, 190, 190),
        TextSize        = 11,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Right,
        ZIndex          = 7,
        Parent          = fHdr,
    })

    local fStatsGrid = inst("Frame", {
        Size        = UDim2.new(1, -20, 1, -52),
        Position    = UDim2.new(0.5, 0, 1, -8),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        ZIndex      = 6,
        Parent      = friendsPanel,
    })
    inst("UIGridLayout", {
        CellSize    = UDim2.new(0.5, -6, 0.5, -6),
        CellPadding = UDim2.new(0, 10, 0, 10),
        SortOrder   = Enum.SortOrder.LayoutOrder,
        Parent      = fStatsGrid,
    })

    local function mkFStatChip(order, label, accent)
        local chip = inst("Frame", {
            BackgroundColor3 = Color3.fromRGB(28, 28, 28),
            BorderSizePixel  = 0,
            LayoutOrder      = order,
            ZIndex           = 7,
            Parent           = fStatsGrid,
        })
        corner(chip, 5)
        inst("UIListLayout", {
            SortOrder           = Enum.SortOrder.LayoutOrder,
            FillDirection       = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment   = Enum.VerticalAlignment.Center,
            Padding             = UDim.new(0, 1),
            Parent              = chip,
        })
        local valLbl = inst("TextLabel", {
            Size            = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text            = "—",
            TextColor3      = accent,
            TextSize        = 14,
            Font            = Enum.Font.GothamBold,
            TextXAlignment  = Enum.TextXAlignment.Center,
            LayoutOrder     = 1,
            ZIndex          = 8,
            Parent          = chip,
        })
        inst("TextLabel", {
            Size            = UDim2.new(1, 0, 0, 12),
            BackgroundTransparency = 1,
            Text            = label,
            TextColor3      = Color3.fromRGB(160, 160, 160),
            TextSize        = 9,
            Font            = Enum.Font.Gotham,
            TextXAlignment  = Enum.TextXAlignment.Center,
            LayoutOrder     = 2,
            ZIndex          = 8,
            Parent          = chip,
        })
        return valLbl
    end

    local fInServer = mkFStatChip(1, "no server", T.Primary)
    local fOnline   = mkFStatChip(2, "online",    T.Success)
    local fOffline  = mkFStatChip(3, "offline",   Color3.fromRGB(120, 120, 120))
    local fTotal    = mkFStatChip(4, "total",     T.Info)

    task.spawn(function()
        local localPlayer   = Players.LocalPlayer
        local serverPlayers = {}
        for _, p in ipairs(Players:GetPlayers()) do serverPlayers[p.UserId] = true end
        local success, result = pcall(function() return localPlayer:GetFriendsOnline() end)
        local inServer, onlineOut, total = 0, 0, 0
        if success and result then
            total = #result
            for _, friend in ipairs(result) do
                if serverPlayers[friend.VisitorId] then inServer = inServer + 1
                else onlineOut = onlineOut + 1 end
            end
        end
        local realTotal = total
        pcall(function()
            local pages = Players:GetFriendsAsync(localPlayer.UserId)
            local count = 0
            repeat
                for _ in ipairs(pages:GetCurrentPage()) do count = count + 1 end
                if not pages.IsFinished then pages:AdvanceToNextPageAsync() end
            until pages.IsFinished
            realTotal = count
        end)
        local offline = math.max(0, realTotal - inServer - onlineOut)
        fInServer.Text = tostring(inServer)
        fOnline.Text   = tostring(onlineOut)
        fOffline.Text  = tostring(offline)
        fTotal.Text    = tostring(realTotal)
        fCountLbl.Text = realTotal .. " total"
    end)

    -- Banner do Discord
    if config.DiscordInvite and config.DiscordInvite ~= "" then
        local discordBanner = inst("Frame", {
            Size             = UDim2.new(1, 0, 0, 62),
            BackgroundColor3 = Color3.fromRGB(24, 25, 56),
            BorderSizePixel  = 0,
            ClipsDescendants = true,
            LayoutOrder      = 3,
            ZIndex           = 5,
            Parent           = inner,
        })
        corner(discordBanner, 8)
        mkStroke(discordBanner, Color3.fromRGB(55, 60, 140), 1)
        local dCircle = inst("Frame", {
            Size             = UDim2.new(0, 26, 0, 26),
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 12, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(88, 101, 242),
            BorderSizePixel  = 0,
            ZIndex           = 7,
            Parent           = discordBanner,
        })
        corner(dCircle, 13)
        inst("ImageLabel", {
            Size            = UDim2.new(0, 18, 0, 18),
            AnchorPoint     = Vector2.new(0.5, 0.5),
            Position        = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Image           = "rbxassetid://114656582279734",
            ScaleType       = Enum.ScaleType.Fit,
            ZIndex          = 8,
            Parent          = dCircle,
        })
        inst("TextLabel", {
            Size            = UDim2.new(0.5, 0, 0, 16),
            Position        = UDim2.new(0, 54, 0, 11),
            BackgroundTransparency = 1,
            Text            = "Servidor do Discord",
            TextColor3      = Color3.fromRGB(235, 236, 255),
            TextSize        = 12,
            Font            = Enum.Font.GothamBold,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 8,
            Parent          = discordBanner,
        })
        inst("TextLabel", {
            Size            = UDim2.new(0.5, 0, 0, 12),
            Position        = UDim2.new(0, 54, 0, 28),
            BackgroundTransparency = 1,
            Text            = "Clique para copiar o convite",
            TextColor3      = Color3.fromRGB(140, 145, 210),
            TextSize        = 10,
            Font            = Enum.Font.Gotham,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 8,
            Parent          = discordBanner,
        })
        local pill = inst("Frame", {
            Size             = UDim2.new(0, 0, 0, 22),
            AutomaticSize    = Enum.AutomaticSize.X,
            Position         = UDim2.new(1, -14, 0.5, 0),
            AnchorPoint      = Vector2.new(1, 0.5),
            BackgroundColor3 = Color3.fromRGB(15, 16, 38),
            BorderSizePixel  = 0,
            ZIndex           = 8,
            Parent           = discordBanner,
        })
        corner(pill, 14)
        mkStroke(pill, Color3.fromRGB(66, 72, 140), 1)
        mkPad(pill, 0, 12, 0, 10)
        local pillIcon = mkIcon(pill, "copy", 12, Color3.fromRGB(140, 148, 220), 7,
            Vector2.new(0, 0.5), UDim2.new(0, 0, 0.5, 0))
        local pillLbl = inst("TextLabel", {
            Size            = UDim2.new(0, 0, 1, 0),
            AutomaticSize   = Enum.AutomaticSize.X,
            Position        = UDim2.new(0, 18, 0, 0),
            BackgroundTransparency = 1,
            Text            = "discord.gg/" .. config.DiscordInvite,
            TextColor3      = Color3.fromRGB(170, 175, 230),
            TextSize        = 11,
            Font            = Enum.Font.GothamMedium,
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 9,
            Parent          = pill,
        })
        local pillBtn = inst("TextButton", {
            Size            = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text            = "",
            ZIndex          = 10,
            Parent          = pill,
        })
        local copying = false
        local function doCopy()
            if copying then return end
            copying = true
            pcall(function() setclipboard("https://discord.gg/" .. config.DiscordInvite) end)
            pillLbl.Text = "Copiado!"
            tw(pill,    fast, { BackgroundColor3 = Color3.fromRGB(20, 50, 30) })
            tw(pillLbl, fast, { TextColor3 = Color3.fromRGB(100, 220, 130) })
            if pillIcon then tw(pillIcon, fast, { ImageColor3 = Color3.fromRGB(100, 220, 130) }) end
            task.delay(2, function()
                if pill.Parent then
                    pillLbl.Text = "discord.gg/" .. config.DiscordInvite
                    tw(pill,    fast, { BackgroundColor3 = Color3.fromRGB(15, 16, 38) })
                    tw(pillLbl, fast, { TextColor3 = Color3.fromRGB(170, 175, 230) })
                    if pillIcon then tw(pillIcon, fast, { ImageColor3 = Color3.fromRGB(140, 148, 220) }) end
                end
                copying = false
            end)
        end
        pillBtn.MouseEnter:Connect(function()
            tw(pill,    fast, { BackgroundColor3 = Color3.fromRGB(22, 24, 55) })
            tw(pillLbl, fast, { TextColor3 = Color3.fromRGB(200, 205, 255) })
            if pillIcon then tw(pillIcon, fast, { ImageColor3 = Color3.fromRGB(170, 178, 255) }) end
        end)
        pillBtn.MouseLeave:Connect(function()
            if not copying then
                tw(pill,    fast, { BackgroundColor3 = Color3.fromRGB(15, 16, 38) })
                tw(pillLbl, fast, { TextColor3 = Color3.fromRGB(170, 175, 230) })
                if pillIcon then tw(pillIcon, fast, { ImageColor3 = Color3.fromRGB(140, 148, 220) }) end
            end
        end)
        pillBtn.MouseButton1Click:Connect(doCopy)
        local bannerBtn = inst("TextButton", {
            Size            = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text            = "",
            ZIndex          = 6,
            Parent          = discordBanner,
        })
        bannerBtn.MouseEnter:Connect(function() tw(discordBanner, fast, { BackgroundColor3 = Color3.fromRGB(28, 30, 65) }) end)
        bannerBtn.MouseLeave:Connect(function() tw(discordBanner, fast, { BackgroundColor3 = Color3.fromRGB(24, 25, 56) }) end)
        bannerBtn.MouseButton1Click:Connect(doCopy)
    end

    local tabData = {
        name      = TAB_TITLE,
        btn       = btn,
        btnLabel  = btnLabel,
        iconImg   = homeIconImg,
        indicator = indicator,
        panel     = panel,
    }
    table.insert(self._tabs, 1, tabData)
    self._tabData[TAB_TITLE] = tabData
    Tabs.SwitchTab(self, TAB_TITLE)

    clickArea.MouseEnter:Connect(function()
        if self._activeTab ~= TAB_TITLE then
            tw(btn, fast, { BackgroundColor3 = T.TabHover })
            tw(btnLabel, fast, { TextColor3 = T.TextPrimary })
        end
    end)
    clickArea.MouseLeave:Connect(function()
        if self._activeTab ~= TAB_TITLE then
            tw(btn, fast, { BackgroundColor3 = T.TabNormal })
            tw(btnLabel, fast, { TextColor3 = T.TabNormalText })
            if homeIconImg then tw(homeIconImg, fast, { ImageColor3 = T.IconTint }) end
        end
    end)
    clickArea.MouseButton1Click:Connect(function() Tabs.SwitchTab(self, TAB_TITLE) end)
end

return Window
=======
return function(Theme, Utils, Draggable, Resizable, TweenController, State, EventBus, Registry, Components)
    local Window = {}
    Window.__index = Window

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")

    local function pad2(v)
        v = tostring(v)
        return #v == 1 and "0" .. v or v
    end

    local function formatUptime(seconds)
        if seconds >= 3600 then
            local h = math.floor(seconds / 3600)
            local m = math.floor((seconds % 3600) / 60)
            return tostring(h) .. "h" .. pad2(m) .. "m"
        end
        if seconds >= 60 then
            local m = math.floor(seconds / 60)
            local s = seconds % 60
            return tostring(m) .. "m" .. pad2(s) .. "s"
        end
        return tostring(seconds) .. "s"
    end

    function Window.new(config)
        local self = setmetatable({}, Window)
        self.Config = config or {}
        self.Title = self.Config.Title or "Claude UI"
        self.Version = self.Config.Version or "v4.0"
        self.Size = self.Config.Size or UDim2.new(0, 860, 0, 580)
        self.MinSize = self.Config.MinSize or Vector2.new(520, 360)
        self.Parent = self.Config.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
        self.Components = Components
        self.Registry = Registry
        self.Events = EventBus.new()
        self.State = {
            ActiveTab = State.new("home"),
            Theme = State.new(Theme.Current),
            Accent = State.new(Theme.Colors.Accent),
            Uptime = State.new(0),
            Ping = State.new(42)
        }
        self.Destroyed = false
        self.Minimized = false
        self.Maximized = false
        self.LastSize = nil
        self.LastPos = nil

        self.Gui = self.Parent:FindFirstChild("UILibGui")
        if not self.Gui then
            self.Gui = Utils.Create("ScreenGui", {
                Name = "UILibGui",
                ResetOnSpawn = false,
                IgnoreGuiInset = true,
                Parent = self.Parent
            })
        end

        Registry.RegisterWindow(self)

        self.Backdrop = Utils.Create("Frame", {
            Name = "Backdrop",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = self.Gui
        })

        self.Window = Utils.Create("Frame", {
            Name = "Window",
            Size = self.Size,
            Position = UDim2.new(0.5, -self.Size.X.Offset / 2, 0.5, -self.Size.Y.Offset / 2),
            BackgroundColor3 = Theme.Colors.Background,
            BackgroundTransparency = Theme.Transparencies.WindowBg,
            BorderSizePixel = 0,
            Parent = self.Backdrop
        })
        Utils.Corner(self.Window, Theme.Sizes.RadiusLarge)
        Utils.Stroke(self.Window, Theme.Colors.Border, 1, Theme.Transparencies.BorderMid)
        Theme:Bind(self.Window, {BackgroundColor3 = "Background", BackgroundTransparency = "WindowBg"})

        self.TitleBar = Utils.Create("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, 0, 0, 46),
            BackgroundColor3 = Theme.Colors.Background2,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = self.Window
        })
        Utils.Corner(self.TitleBar, Theme.Sizes.RadiusLarge)
        Theme:Bind(self.TitleBar, {BackgroundColor3 = "Background2", BackgroundTransparency = "Surface"})

        local titleInset = Utils.Create("Frame", {
            Name = "TitleInset",
            Size = UDim2.new(1, -16, 1, -8),
            Position = UDim2.new(0, 8, 0, 4),
            BackgroundTransparency = 1,
            Parent = self.TitleBar
        })

        self.Traffic = Utils.Create("Frame", {
            Name = "Traffic",
            Size = UDim2.new(0, 64, 0, 16),
            Position = UDim2.new(0, 0, 0.5, -8),
            BackgroundTransparency = 1,
            Parent = titleInset
        })

        local function trafficDot(color, x, onClick)
            local btn = Utils.Create("TextButton", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, x, 0.5, -6),
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                Text = "",
                Parent = self.Traffic
            })
            Utils.Corner(btn, UDim.new(1, 0))
            if onClick then
                Registry.RegisterConnection(self, btn.MouseButton1Click:Connect(onClick))
            end
            return btn
        end

        trafficDot(Color3.fromRGB(214, 96, 96), 0, function()
            self:Destroy()
        end)
        trafficDot(Color3.fromRGB(201, 148, 58), 18, function()
            self:ToggleMinimize()
        end)
        trafficDot(Color3.fromRGB(90, 143, 110), 36, function()
            self:ToggleMaximize()
        end)

        self.TitleWrap = Utils.Create("Frame", {
            Name = "TitleWrap",
            Size = UDim2.new(1, -160, 1, 0),
            Position = UDim2.new(0, 80, 0, 0),
            BackgroundTransparency = 1,
            Parent = titleInset
        })

        local logo = Utils.Create("Frame", {
            Name = "Logo",
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0, 0, 0.5, -11),
            BackgroundColor3 = Theme.Colors.Accent,
            BackgroundTransparency = 0.75,
            Parent = self.TitleWrap
        })
        Utils.Corner(logo, UDim.new(1, 0))
        Utils.Stroke(logo, Theme.Colors.Accent, 1, 0)
        Theme:Bind(logo, {BackgroundColor3 = "Accent", BackgroundTransparency = function() return 0.75 end})

        local titleText = Utils.Create("TextLabel", {
            Name = "Title",
            Text = self.Title,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextLarge,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 30, 0, 6),
            Size = UDim2.new(1, -30, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.TitleWrap
        })
        Theme:Bind(titleText, {TextColor3 = "TextHigh"})

        local versionText = Utils.Create("TextLabel", {
            Name = "Version",
            Text = self.Version,
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextMuted,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 30, 0, 22),
            Size = UDim2.new(1, -30, 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.TitleWrap
        })
        Theme:Bind(versionText, {TextColor3 = "TextMuted"})

        self.TitleActions = Utils.Create("Frame", {
            Name = "TitleActions",
            Size = UDim2.new(0, 70, 0, 24),
            Position = UDim2.new(1, -70, 0.5, -12),
            BackgroundTransparency = 1,
            Parent = titleInset
        })

        local function smallAction(icon, x, callback)
            local btn = Utils.Create("TextButton", {
                Size = UDim2.new(0, 28, 0, 22),
                Position = UDim2.new(0, x, 0, 0),
                BackgroundColor3 = Theme.Colors.Surface,
                BackgroundTransparency = Theme.Transparencies.Surface,
                Text = icon,
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextNormal,
                TextColor3 = Theme.Colors.TextMed,
                AutoButtonColor = false,
                Parent = self.TitleActions
            })
            Utils.Corner(btn, Theme.Sizes.RadiusSmall)
            Utils.Stroke(btn, Theme.Colors.Border, 1, Theme.Transparencies.Border)
            Theme:Bind(btn, {BackgroundColor3 = "Surface", BackgroundTransparency = "Surface", TextColor3 = "TextMed"})
            Registry.RegisterConnection(self, btn.MouseEnter:Connect(function()
                TweenController:Play(btn, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.SurfaceHover})
            end))
            Registry.RegisterConnection(self, btn.MouseLeave:Connect(function()
                TweenController:Play(btn, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.Surface})
            end))
            if callback then
                Registry.RegisterConnection(self, btn.MouseButton1Click:Connect(callback))
            end
            return btn
        end

        smallAction("⌕", 0, function()
            if self.Notify then
                self.Notify({Text = "Busca rápida disponível", Type = "info"})
            end
        end)
        smallAction("⚙", 34, function()
            self:SwitchTab("settings")
        end)

        self.Body = Utils.Create("Frame", {
            Name = "Body",
            Size = UDim2.new(1, 0, 1, -76),
            Position = UDim2.new(0, 0, 0, 46),
            BackgroundTransparency = 1,
            Parent = self.Window
        })

        self.Sidebar = Utils.Create("Frame", {
            Name = "Sidebar",
            Size = UDim2.new(0, 170, 1, 0),
            BackgroundColor3 = Theme.Colors.Background2,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = self.Body
        })
        Theme:Bind(self.Sidebar, {BackgroundColor3 = "Background2", BackgroundTransparency = "Surface"})

        Utils.Padding(self.Sidebar, 14)
        Utils.Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = self.Sidebar
        })

        local sbLabel = Utils.Create("TextLabel", {
            Text = "MAIN",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextMuted,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Sidebar
        })
        Theme:Bind(sbLabel, {TextColor3 = "TextMuted"})

        self.TabButtons = {}

        local function createTabButton(id, label, badge, locked)
            local btn = Utils.Create("TextButton", {
                Name = "TabButton_" .. id,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Colors.Surface,
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                Parent = self.Sidebar
            })
            Utils.Corner(btn, Theme.Sizes.RadiusMedium)
            Utils.Stroke(btn, Theme.Colors.Border, 1, Theme.Transparencies.Border)

            local marker = Utils.Create("Frame", {
                Name = "Marker",
                Size = UDim2.new(0, 3, 1, -10),
                Position = UDim2.new(0, 4, 0, 5),
                BackgroundColor3 = Theme.Colors.Accent,
                BorderSizePixel = 0,
                Parent = btn,
                Visible = false
            })
            Utils.Corner(marker, UDim.new(1, 0))

            local icon = Utils.Create("TextLabel", {
                Text = "◈",
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextNormal,
                TextColor3 = Theme.Colors.TextLow,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                Parent = btn
            })

            local lbl = Utils.Create("TextLabel", {
                Text = label,
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextMedium,
                TextColor3 = Theme.Colors.TextMed,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 34, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn
            })

            local badgeLabel = nil
            if badge then
                badgeLabel = Utils.Create("TextLabel", {
                    Text = badge,
                    Font = Theme.Fonts.Mono,
                    TextSize = Theme.Sizes.TextSmall,
                    TextColor3 = Theme.Colors.TextHigh,
                    BackgroundColor3 = Theme.Colors.Accent,
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0, 34, 0, 18),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -10, 0.5, 0),
                    Parent = btn
                })
                Utils.Corner(badgeLabel, Theme.Sizes.RadiusSmall)
            end

            if locked then
                btn.AutoButtonColor = false
                btn.BackgroundTransparency = 0.85
                lbl.TextTransparency = 0.5
                icon.TextTransparency = 0.5
                if badgeLabel then
                    badgeLabel.BackgroundTransparency = 0.5
                end
            else
                Registry.RegisterConnection(self, btn.MouseButton1Click:Connect(function()
                    self:SwitchTab(id)
                end))
            end

            self.TabButtons[id] = {Button = btn, Marker = marker, Label = lbl, Icon = icon}
        end

        createTabButton("home", "Home", "NEW", false)
        createTabButton("player", "Player", nil, false)
        createTabButton("visual", "Visual", nil, false)
        createTabButton("aimbot", "Aimbot", "VIP", false)
        createTabButton("misc", "Misc", nil, false)
        createTabButton("settings", "Settings", nil, false)

        self.ContentArea = Utils.Create("Frame", {
            Name = "Content",
            Size = UDim2.new(1, -170, 1, 0),
            Position = UDim2.new(0, 170, 0, 0),
            BackgroundTransparency = 1,
            Parent = self.Body
        })
        self.Content = self.ContentArea

        self.Panels = {}

        local function createPanel(id, title, desc)
            local panel = Utils.Create("ScrollingFrame", {
                Name = "Panel_" .. id,
                Size = UDim2.new(1, -16, 1, -12),
                Position = UDim2.new(0, 8, 0, 6),
                BackgroundTransparency = 1,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Theme.Colors.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Parent = self.ContentArea,
                Visible = false
            })
            local layout = Utils.Create("UIListLayout", {
                Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = panel
            })
            Registry.RegisterConnection(self, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                panel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
            end))
            self.Panels[id] = panel

            local header = Utils.Create("Frame", {
                Name = "PanelHeader",
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = Theme.Colors.Surface,
                BackgroundTransparency = Theme.Transparencies.Surface,
                Parent = panel
            })
            Utils.Corner(header, Theme.Sizes.RadiusLarge)
            Utils.Stroke(header, Theme.Colors.Border, 1, Theme.Transparencies.Border)
            Theme:Bind(header, {BackgroundColor3 = "Surface", BackgroundTransparency = "Surface"})
            Utils.Padding(header, 14)

            local icon = Utils.Create("TextLabel", {
                Text = "◈",
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextLarge,
                TextColor3 = Theme.Colors.Accent,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 26, 1, 0),
                Parent = header
            })
            Theme:Bind(icon, {TextColor3 = "Accent"})

            local headerText = Utils.Create("TextLabel", {
                Text = title,
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextTitle,
                TextColor3 = Theme.Colors.TextHigh,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 0, 20),
                Position = UDim2.new(0, 34, 0, 4),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header
            })
            Theme:Bind(headerText, {TextColor3 = "TextHigh"})

            local headerDesc = Utils.Create("TextLabel", {
                Text = desc,
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextLow,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 0, 14),
                Position = UDim2.new(0, 34, 0, 24),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header
            })
            Theme:Bind(headerDesc, {TextColor3 = "TextLow"})

            return panel
        end

        local function createGroup(parent, label)
            local wrap = Utils.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                Parent = parent,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            local lbl = Utils.Create("TextLabel", {
                Text = label,
                Font = Theme.Fonts.Mono,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextMuted,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = wrap
            })
            Theme:Bind(lbl, {TextColor3 = "TextMuted"})
            local body = Utils.Create("Frame", {
                Name = "Body",
                Position = UDim2.new(0, 0, 0, 18),
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1,
                Parent = wrap,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Utils.Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = body
            })
            return wrap, body
        end

        local function createSeparator(parent)
            local sep = Utils.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Colors.Border,
                BackgroundTransparency = Theme.Transparencies.Border,
                BorderSizePixel = 0,
                Parent = parent
            })
            Theme:Bind(sep, {BackgroundColor3 = "Border", BackgroundTransparency = "Border"})
            return sep
        end

        local function createStatCard(parent, title, value, sub, accent)
            local card = Utils.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 62),
                BackgroundColor3 = Theme.Colors.Surface,
                BackgroundTransparency = Theme.Transparencies.Surface,
                Parent = parent
            })
            Utils.Corner(card, Theme.Sizes.RadiusMedium)
            Utils.Stroke(card, Theme.Colors.Border, 1, Theme.Transparencies.Border)
            Utils.Padding(card, 12)
            Theme:Bind(card, {BackgroundColor3 = "Surface", BackgroundTransparency = "Surface"})

            local t = Utils.Create("TextLabel", {
                Text = title,
                Font = Theme.Fonts.Mono,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextMuted,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card
            })
            Theme:Bind(t, {TextColor3 = "TextMuted"})

            local v = Utils.Create("TextLabel", {
                Text = value,
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextHeader,
                TextColor3 = accent or Theme.Colors.TextHigh,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card
            })
            Theme:Bind(v, {TextColor3 = accent and function() return accent end or "TextHigh"})

            local s = Utils.Create("TextLabel", {
                Text = sub or "",
                Font = Theme.Fonts.Mono,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextLow,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 12),
                Position = UDim2.new(0, 0, 0, 38),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card
            })
            Theme:Bind(s, {TextColor3 = "TextLow"})
            return card, v, s
        end

        local homePanel = createPanel("home", "Home", "Painel geral e status do sistema")

        local welcome = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 86),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = homePanel
        })
        Utils.Corner(welcome, Theme.Sizes.RadiusLarge)
        Utils.Stroke(welcome, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(welcome, 14)
        Theme:Bind(welcome, {BackgroundColor3 = "Surface", BackgroundTransparency = "Surface"})

        local avatar = Utils.Create("Frame", {
            Size = UDim2.new(0, 54, 0, 54),
            BackgroundColor3 = Theme.Colors.Accent,
            BackgroundTransparency = 0.35,
            Parent = welcome
        })
        Utils.Corner(avatar, UDim.new(1, 0))
        Utils.Gradient(avatar, ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Colors.Accent),
            ColorSequenceKeypoint.new(1, Theme.Colors.AccentHigh)
        }), 45)

        local welcomeText = Utils.Create("TextLabel", {
            Text = "Boa noite, ClaudeUser!",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextHeader,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -170, 0, 22),
            Position = UDim2.new(0, 68, 0, 6),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = welcome
        })
        Theme:Bind(welcomeText, {TextColor3 = "TextHigh"})

        local welcomeDesc = Utils.Create("TextLabel", {
            Text = "Hoje é um ótimo dia para dominar o jogo.",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -170, 0, 14),
            Position = UDim2.new(0, 68, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = welcome
        })
        Theme:Bind(welcomeDesc, {TextColor3 = "TextLow"})

        local clockWrap = Utils.Create("Frame", {
            Size = UDim2.new(0, 120, 0, 46),
            Position = UDim2.new(1, -120, 0.5, -23),
            BackgroundColor3 = Theme.Colors.Background2,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = welcome
        })
        Utils.Corner(clockWrap, Theme.Sizes.RadiusMedium)
        Utils.Stroke(clockWrap, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Theme:Bind(clockWrap, {BackgroundColor3 = "Background2", BackgroundTransparency = "Surface"})

        local clockText = Utils.Create("TextLabel", {
            Text = "00:00:00",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextLarge,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 4),
            Parent = clockWrap
        })
        Theme:Bind(clockText, {TextColor3 = "TextHigh"})

        local clockDate = Utils.Create("TextLabel", {
            Text = "00/00/0000",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, 24),
            Parent = clockWrap
        })
        Theme:Bind(clockDate, {TextColor3 = "TextLow"})

        local statRow = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 70),
            BackgroundTransparency = 1,
            Parent = homePanel
        })
        Utils.Create("UIGridLayout", {
            CellSize = UDim2.new(0.25, -8, 0, 70),
            CellPadding = UDim2.new(0, 10, 0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = statRow
        })

        local _, pingValue = createStatCard(statRow, "PING", "42ms", "Servidor 1", Theme.Colors.Accent)
        createStatCard(statRow, "PLAYERS", "12/20", "Online", Theme.Colors.TextHigh)
        createStatCard(statRow, "EXECUTOR", "Synapse X", "Status: OK", Theme.Colors.Success)
        local _, upValue = createStatCard(statRow, "UPTIME", "0s", "Sessão ativa", Theme.Colors.AccentHigh)

        local twoCol = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 180),
            BackgroundTransparency = 1,
            Parent = homePanel
        })
        Utils.Create("UIGridLayout", {
            CellSize = UDim2.new(0.5, -8, 0, 180),
            CellPadding = UDim2.new(0, 12, 0, 0),
            Parent = twoCol
        })

        local changelog = Utils.Create("Frame", {
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = twoCol
        })
        Utils.Corner(changelog, Theme.Sizes.RadiusLarge)
        Utils.Stroke(changelog, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(changelog, 12)

        local chTitle = Utils.Create("TextLabel", {
            Text = "Changelog",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextMedium,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = changelog
        })
        Theme:Bind(chTitle, {TextColor3 = "TextHigh"})

        local function addChange(text, date, y)
            local item = Utils.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, y),
                Parent = changelog
            })
            local t1 = Utils.Create("TextLabel", {
                Text = text,
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextNormal,
                TextColor3 = Theme.Colors.TextHigh,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = item
            })
            Theme:Bind(t1, {TextColor3 = "TextHigh"})
            local t2 = Utils.Create("TextLabel", {
                Text = date,
                Font = Theme.Fonts.Mono,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextMuted,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 12),
                Position = UDim2.new(0, 0, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = item
            })
            Theme:Bind(t2, {TextColor3 = "TextMuted"})
            return item
        end
        addChange("Novo sistema de temas", "Hoje", 24)
        addChange("Correções de performance", "Ontem", 64)
        addChange("Novo painel Visual", "20/02/2026", 104)

        local friends = Utils.Create("Frame", {
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = twoCol
        })
        Utils.Corner(friends, Theme.Sizes.RadiusLarge)
        Utils.Stroke(friends, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(friends, 12)

        local frTitle = Utils.Create("TextLabel", {
            Text = "Amigos",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextMedium,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = friends
        })
        Theme:Bind(frTitle, {TextColor3 = "TextHigh"})

        local frWrap = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 130),
            Position = UDim2.new(0, 0, 0, 26),
            BackgroundTransparency = 1,
            Parent = friends
        })
        Utils.Create("UIGridLayout", {
            CellSize = UDim2.new(0.5, -6, 0, 60),
            CellPadding = UDim2.new(0, 8, 0, 8),
            Parent = frWrap
        })
        createStatCard(frWrap, "ONLINE", "6", "Agora")
        createStatCard(frWrap, "OFFLINE", "18", "Hoje")
        createStatCard(frWrap, "VIP", "2", "Ativo")
        createStatCard(frWrap, "PING", "36ms", "Média")

        local discord = Utils.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 56),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Text = "",
            AutoButtonColor = false,
            Parent = homePanel
        })
        Utils.Corner(discord, Theme.Sizes.RadiusLarge)
        Utils.Stroke(discord, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(discord, 12)
        Theme:Bind(discord, {BackgroundColor3 = "Surface", BackgroundTransparency = "Surface"})

        local dcIcon = Utils.Create("TextLabel", {
            Text = "◎",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextLarge,
            TextColor3 = Theme.Colors.Accent,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 24, 1, 0),
            Parent = discord
        })
        Theme:Bind(dcIcon, {TextColor3 = "Accent"})

        local dcTitle = Utils.Create("TextLabel", {
            Text = "Entre no nosso Discord",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextMedium,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -140, 0, 16),
            Position = UDim2.new(0, 30, 0, 6),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = discord
        })
        Theme:Bind(dcTitle, {TextColor3 = "TextHigh"})

        local dcDesc = Utils.Create("TextLabel", {
            Text = "Atualizações, suporte e recursos exclusivos",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -140, 0, 14),
            Position = UDim2.new(0, 30, 0, 26),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = discord
        })
        Theme:Bind(dcDesc, {TextColor3 = "TextLow"})

        local dcPill = Utils.Create("TextLabel", {
            Text = "discord.gg/meuserver",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundColor3 = Theme.Colors.Background2,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Size = UDim2.new(0, 160, 0, 22),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            Parent = discord
        })
        Utils.Corner(dcPill, Theme.Sizes.RadiusSmall)
        Utils.Stroke(dcPill, Theme.Colors.Border, 1, Theme.Transparencies.Border)

        Registry.RegisterConnection(self, discord.MouseButton1Click:Connect(function()
            if self.Notify then
                self.Notify({Text = "Link copiado", Type = "success"})
            end
        end))

        local playerPanel = createPanel("player", "Player", "Controle de movimento e física")

        local saveBar = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = playerPanel
        })
        Utils.Corner(saveBar, Theme.Sizes.RadiusMedium)
        Utils.Stroke(saveBar, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(saveBar, 10)

        local saveDot = Utils.Create("Frame", {
            Size = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = Theme.Colors.Success,
            BorderSizePixel = 0,
            Parent = saveBar
        })
        Utils.Corner(saveDot, UDim.new(1, 0))

        local saveText = Utils.Create("TextLabel", {
            Text = "Configurações salvas",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextMed,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -140, 1, 0),
            Position = UDim2.new(0, 16, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = saveBar
        })
        Theme:Bind(saveText, {TextColor3 = "TextMed"})

        local smBtnWrap = Utils.Create("Frame", {
            Size = UDim2.new(0, 130, 1, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            BackgroundTransparency = 1,
            Parent = saveBar
        })
        Utils.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = smBtnWrap
        })

        local function smButton(text, accent, callback)
            local btn = Utils.Create("TextButton", {
                Text = text,
                Font = Theme.Fonts.Mono,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = accent and Theme.Colors.TextHigh or Theme.Colors.TextMed,
                BackgroundColor3 = accent and Theme.Colors.Accent or Theme.Colors.Background2,
                BackgroundTransparency = Theme.Transparencies.Surface,
                Size = UDim2.new(0, 60, 0, 22),
                AutoButtonColor = false,
                Parent = smBtnWrap
            })
            Utils.Corner(btn, Theme.Sizes.RadiusSmall)
            Utils.Stroke(btn, Theme.Colors.Border, 1, Theme.Transparencies.Border)
            Registry.RegisterConnection(self, btn.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end))
            return btn
        end

        smButton("Reset", false, function()
            if self.Notify then
                self.Notify({Text = "Configurações resetadas", Type = "warning"})
            end
        end)
        smButton("Salvar", true, function()
            if self.Notify then
                self.Notify({Text = "Configurações salvas", Type = "success"})
            end
        end)

        local _, moveBody = createGroup(playerPanel, "Movimento")
        local speed = Components.Slider.new(moveBody, {Text = "Velocidade", Min = 16, Max = 200, Default = 16})
        local jump = Components.Slider.new(moveBody, {Text = "Altura do Pulo", Min = 7, Max = 100, Default = 7})
        Registry.Register(speed, self)
        Registry.Register(jump, self)

        createSeparator(playerPanel)

        local _, physBody = createGroup(playerPanel, "Físicas")
        local noclip = Components.Toggle.new(physBody, {Text = "NoClip", Icon = "◈"})
        local infjump = Components.Toggle.new(physBody, {Text = "Infinite Jump", Icon = "▲"})
        local fly = Components.Toggle.new(physBody, {Text = "Fly (Locked)", Icon = "✈", Locked = true})
        Registry.Register(noclip, self)
        Registry.Register(infjump, self)
        Registry.Register(fly, self)

        createSeparator(playerPanel)

        local _, actBody = createGroup(playerPanel, "Ações")
        local actionGrid = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 90),
            BackgroundTransparency = 1,
            Parent = actBody
        })
        Utils.Create("UIGridLayout", {
            CellSize = UDim2.new(0.5, -6, 0, 40),
            CellPadding = UDim2.new(0, 8, 0, 8),
            Parent = actionGrid
        })
        local resetBtn = Components.Button.new(actionGrid, {Text = "Resetar", Callback = function()
            if self.Notify then
                self.Notify({Text = "Resetando jogador", Type = "warning"})
            end
        end})
        local spawnBtn = Components.Button.new(actionGrid, {Text = "Ir ao Spawn", Variant = "Primary", Callback = function()
            if self.Notify then
                self.Notify({Text = "Teleportando ao spawn", Type = "info"})
            end
        end})
        local lockedBtn = Components.Button.new(actBody, {Text = "Speed Hack (Locked)", Locked = true})
        Registry.Register(resetBtn, self)
        Registry.Register(spawnBtn, self)
        Registry.Register(lockedBtn, self)

        local visualPanel = createPanel("visual", "Visual", "ESP, câmera e overlays")

        local _, espBody = createGroup(visualPanel, "ESP")
        local espToggle = Components.Toggle.new(espBody, {Text = "ESP Jogadores", Icon = "▦"})
        local namesToggle = Components.Toggle.new(espBody, {Text = "Mostrar Nomes", Icon = "≡", State = true})
        Registry.Register(espToggle, self)
        Registry.Register(namesToggle, self)

        createSeparator(visualPanel)

        local _, cpBody = createGroup(visualPanel, "Cor do ESP — Color Picker")
        local cpWrap = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 120),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = cpBody
        })
        Utils.Corner(cpWrap, Theme.Sizes.RadiusMedium)
        Utils.Stroke(cpWrap, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(cpWrap, 12)

        local cpLabel = Utils.Create("TextLabel", {
            Text = "Selecione a cor do ESP",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 12),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = cpWrap
        })
        Theme:Bind(cpLabel, {TextColor3 = "TextLow"})

        local cpWheel = Utils.Create("TextButton", {
            Size = UDim2.new(0, 80, 0, 80),
            Position = UDim2.new(0, 0, 0, 24),
            BackgroundColor3 = Theme.Colors.Background3,
            Text = "",
            AutoButtonColor = false,
            Parent = cpWrap
        })
        Utils.Corner(cpWheel, UDim.new(1, 0))
        Utils.Gradient(cpWheel, ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        }), 0)

        local cpCursor = Utils.Create("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0.5, -5, 0.5, -5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = cpWheel
        })
        Utils.Corner(cpCursor, UDim.new(1, 0))
        Utils.Stroke(cpCursor, Theme.Colors.Border, 1, 0)

        local cpRight = Utils.Create("Frame", {
            Size = UDim2.new(1, -100, 0, 80),
            Position = UDim2.new(0, 90, 0, 24),
            BackgroundTransparency = 1,
            Parent = cpWrap
        })

        local brightLabel = Utils.Create("TextLabel", {
            Text = "L",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 12, 0, 12),
            Parent = cpRight
        })

        local brightTrack = Utils.Create("Frame", {
            Size = UDim2.new(1, -20, 0, 10),
            Position = UDim2.new(0, 16, 0, 2),
            BackgroundColor3 = Theme.Colors.Background3,
            BorderSizePixel = 0,
            Parent = cpRight
        })
        Utils.Corner(brightTrack, UDim.new(1, 0))
        Utils.Gradient(brightTrack, ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
        }), 0)

        local brightKnob = Utils.Create("Frame", {
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(1, -5, 0.5, -5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = brightTrack
        })
        Utils.Corner(brightKnob, UDim.new(1, 0))
        Utils.Stroke(brightKnob, Theme.Colors.Border, 1, 0)

        local preview = Utils.Create("Frame", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 0, 0, 28),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Parent = cpRight
        })
        Utils.Corner(preview, Theme.Sizes.RadiusSmall)

        local hexLabel = Utils.Create("TextLabel", {
            Text = "#FFFFFF",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 0, 12),
            Position = UDim2.new(0, 28, 0, 28),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = cpRight
        })
        Theme:Bind(hexLabel, {TextColor3 = "TextHigh"})

        local rgbLabel = Utils.Create("TextLabel", {
            Text = "rgb(255,255,255)",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextMuted,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -30, 0, 12),
            Position = UDim2.new(0, 28, 0, 44),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = cpRight
        })
        Theme:Bind(rgbLabel, {TextColor3 = "TextMuted"})

        local cpHue = 0
        local cpSat = 1
        local cpBright = 1

        local function updateColor()
            local color = Color3.fromHSV(cpHue, cpSat, cpBright)
            preview.BackgroundColor3 = color
            local r = math.floor(color.R * 255)
            local g = math.floor(color.G * 255)
            local b = math.floor(color.B * 255)
            hexLabel.Text = string.format("#%02X%02X%02X", r, g, b)
            rgbLabel.Text = string.format("rgb(%d,%d,%d)", r, g, b)
        end

        Registry.RegisterConnection(self, cpWheel.MouseButton1Down:Connect(function()
            local conn
            conn = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = cpWheel.AbsolutePosition
                    local size = cpWheel.AbsoluteSize
                    local x = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                    local y = math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
                    cpHue = x
                    cpSat = 1 - y
                    cpCursor.Position = UDim2.new(x, -5, y, -5)
                    updateColor()
                end
            end)
            local upConn
            upConn = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if conn then conn:Disconnect() end
                    if upConn then upConn:Disconnect() end
                end
            end)
        end))

        Registry.RegisterConnection(self, brightTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = brightTrack.AbsolutePosition
                local size = brightTrack.AbsoluteSize
                local x = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                cpBright = x
                brightKnob.Position = UDim2.new(x, -5, 0.5, -5)
                updateColor()
            end
        end))

        createSeparator(visualPanel)

        local _, camBody = createGroup(visualPanel, "Câmera")
        local fov = Components.Slider.new(camBody, {Text = "FOV", Min = 60, Max = 120, Default = 70})
        Registry.Register(fov, self)

        local _, tagsBody = createGroup(visualPanel, "Tags a mostrar — Multi-select")
        local tags = Components.Dropdown.new(tagsBody, {
            Text = "Tags do ESP",
            Items = {"Nome", "Vida", "Distância", "Time", "Arma"},
            MultiSelect = true
        })
        Registry.Register(tags, self)

        local aimbotPanel = createPanel("aimbot", "Aimbot", "Assistência de mira avançada")

        local _, aimBody = createGroup(aimbotPanel, "Controles")
        local aimbotToggle = Components.Toggle.new(aimBody, {Text = "Aimbot", Icon = "◎"})
        local silent = Components.Toggle.new(aimBody, {Text = "Silentaim", Icon = "△"})
        Registry.Register(aimbotToggle, self)
        Registry.Register(silent, self)

        createSeparator(aimbotPanel)

        local _, aimCfgBody = createGroup(aimbotPanel, "Configurações")
        local smooth = Components.Slider.new(aimCfgBody, {Text = "Suavidade", Min = 1, Max = 20, Default = 5})
        local afov = Components.Slider.new(aimCfgBody, {Text = "FOV do Aimbot", Min = 10, Max = 300, Default = 120})
        Registry.Register(smooth, self)
        Registry.Register(afov, self)

        createSeparator(aimbotPanel)

        local _, aimTargetsBody = createGroup(aimbotPanel, "Alvos — MultiDropdown")
        local bones = Components.Dropdown.new(aimTargetsBody, {
            Text = "Hitboxes Alvo",
            Items = {"Cabeça", "Tronco", "Braços", "Pernas"},
            MultiSelect = true
        })
        Registry.Register(bones, self)

        local _, aimModeBody = createGroup(aimbotPanel, "Modo")
        local mode = Components.Dropdown.new(aimModeBody, {
            Text = "Modo",
            Items = {"Apenas visível", "Todos", "Time"}
        })
        Registry.Register(mode, self)

        local miscPanel = createPanel("misc", "Misc", "Utilitários, dialogs e comandos")

        local _, dialogBody = createGroup(miscPanel, "Dialogs")
        local dlgGrid = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 90),
            BackgroundTransparency = 1,
            Parent = dialogBody
        })
        Utils.Create("UIGridLayout", {
            CellSize = UDim2.new(0.5, -6, 0, 40),
            CellPadding = UDim2.new(0, 8, 0, 8),
            Parent = dlgGrid
        })

        local function dialogButton(text, variant, kind)
            local btn = Components.Button.new(dlgGrid, {Text = text, Variant = variant, Callback = function()
                self:ShowDialog(kind)
            end})
            Registry.Register(btn, self)
        end
        dialogButton("Dialog Confirmar", nil, "confirm")
        dialogButton("Dialog Perigo", "Danger", "danger")
        dialogButton("Dialog Info", nil, "info")
        dialogButton("Dialog 3 Botões", nil, "choices")

        createSeparator(miscPanel)

        local _, notifBody = createGroup(miscPanel, "Notificações")
        local notifGrid = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = notifBody
        })
        Utils.Create("UIGridLayout", {
            CellSize = UDim2.new(0.25, -6, 0, 34),
            CellPadding = UDim2.new(0, 6, 0, 6),
            Parent = notifGrid
        })
        local function toastBtn(text, kind, variant)
            local btn = Components.Button.new(notifGrid, {Text = text, Variant = variant, Callback = function()
                if self.Notify then
                    self.Notify({Text = text, Type = kind})
                end
            end})
            Registry.Register(btn, self)
        end
        toastBtn("✓ OK", "success")
        toastBtn("⚠ Warn", "warning")
        toastBtn("✕ Err", "error", "Danger")
        toastBtn("ℹ Info", "info")

        createSeparator(miscPanel)

        local _, cmdBody = createGroup(miscPanel, "Comando")
        local cmdInput = Components.Input.new(cmdBody, {
            Placeholder = "Digite um comando...",
            Callback = function(text)
                if text and #text > 0 and self.Notify then
                    self.Notify({Text = "Comando executado: " .. text, Type = "info"})
                end
            end
        })
        Registry.Register(cmdInput, self)

        createSeparator(miscPanel)

        local miscGrid = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = miscPanel
        })
        Utils.Create("UIGridLayout", {
            CellSize = UDim2.new(0.5, -6, 0, 40),
            CellPadding = UDim2.new(0, 8, 0, 8),
            Parent = miscGrid
        })
        local reloadBtn = Components.Button.new(miscGrid, {Text = "Recarregar", Callback = function()
            if self.Notify then
                self.Notify({Text = "Recarregando...", Type = "warning"})
            end
        end})
        local closeBtn = Components.Button.new(miscGrid, {Text = "Fechar UI", Variant = "Danger", Callback = function()
            self:ShowDialog("danger")
        end})
        Registry.Register(reloadBtn, self)
        Registry.Register(closeBtn, self)

        local settingsPanel = createPanel("settings", "Settings", "Temas, aparência e preferências")

        local _, themeBody = createGroup(settingsPanel, "Tema")
        local themeGrid = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 90),
            BackgroundTransparency = 1,
            Parent = themeBody
        })
        Utils.Create("UIGridLayout", {
            CellSize = UDim2.new(0.2, -6, 0, 80),
            CellPadding = UDim2.new(0, 8, 0, 0),
            Parent = themeGrid
        })

        local function themeSwatch(id, label, accentColor)
            local sw = Utils.Create("TextButton", {
                Text = "",
                BackgroundColor3 = Theme.Colors.Surface,
                BackgroundTransparency = Theme.Transparencies.Surface,
                AutoButtonColor = false,
                Parent = themeGrid
            })
            Utils.Corner(sw, Theme.Sizes.RadiusMedium)
            Utils.Stroke(sw, Theme.Colors.Border, 1, Theme.Transparencies.Border)
            Utils.Padding(sw, 10)

            Utils.Create("Frame", {
                Size = UDim2.new(0, 24, 0, 24),
                BackgroundColor3 = accentColor,
                Parent = sw
            })
            local name = Utils.Create("TextLabel", {
                Text = label,
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextHigh,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Position = UDim2.new(0, 0, 1, -16),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sw
            })
            Theme:Bind(name, {TextColor3 = "TextHigh"})

            Registry.RegisterConnection(self, sw.MouseButton1Click:Connect(function()
                Theme:SetTheme(id)
                self.State.Theme:Set(id)
                self.State.Accent:Set(Theme.Colors.Accent)
            end))
        end

        themeSwatch("default", "Claude", Color3.fromRGB(unpack(Theme.Defs.default.accRgb)))
        themeSwatch("light", "Light", Color3.fromRGB(unpack(Theme.Defs.light.accRgb)))
        themeSwatch("neon", "Neon", Color3.fromRGB(unpack(Theme.Defs.neon.accRgb)))
        themeSwatch("rose", "Rose", Color3.fromRGB(unpack(Theme.Defs.rose.accRgb)))
        themeSwatch("blue", "Blue", Color3.fromRGB(unpack(Theme.Defs.blue.accRgb)))

        local _, accentBody = createGroup(settingsPanel, "Cor de Destaque Customizada")
        local accentRow = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = accentBody
        })
        Utils.Corner(accentRow, Theme.Sizes.RadiusMedium)
        Utils.Stroke(accentRow, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(accentRow, 10)
        Theme:Bind(accentRow, {BackgroundColor3 = "Surface", BackgroundTransparency = "Surface"})

        local acLabel = Utils.Create("TextLabel", {
            Text = "Cor do Accent",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextMed,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 100, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = accentRow
        })
        Theme:Bind(acLabel, {TextColor3 = "TextMed"})

        local acPreview = Utils.Create("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 110, 0.5, -9),
            BackgroundColor3 = Theme.Colors.Accent,
            Parent = accentRow
        })
        Utils.Corner(acPreview, Theme.Sizes.RadiusSmall)

        local acInput = Utils.Create("TextBox", {
            Text = "#d4825a",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundColor3 = Theme.Colors.Background2,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Size = UDim2.new(0, 90, 0, 22),
            Position = UDim2.new(1, -190, 0.5, -11),
            ClearTextOnFocus = false,
            Parent = accentRow
        })
        Utils.Corner(acInput, Theme.Sizes.RadiusSmall)
        Utils.Stroke(acInput, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Theme:Bind(acInput, {BackgroundColor3 = "Background2", BackgroundTransparency = "Surface", TextColor3 = "TextHigh"})

        local function setAccent(hex)
            Theme:SetCustomAccent(hex)
            acPreview.BackgroundColor3 = Theme.Colors.Accent
        end
        Registry.RegisterConnection(self, acInput.FocusLost:Connect(function()
            local text = acInput.Text
            if text and #text == 7 then
                setAccent(text)
            end
        end))

        local acBtnWrap = Utils.Create("Frame", {
            Size = UDim2.new(0, 120, 1, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0.5, 0),
            BackgroundTransparency = 1,
            Parent = accentRow
        })
        Utils.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = acBtnWrap
        })
        local acPick = Utils.Create("TextButton", {
            Text = "Escolher",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextMed,
            BackgroundColor3 = Theme.Colors.Background2,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Size = UDim2.new(0, 60, 0, 22),
            Parent = acBtnWrap
        })
        Utils.Corner(acPick, Theme.Sizes.RadiusSmall)
        Utils.Stroke(acPick, Theme.Colors.Border, 1, Theme.Transparencies.Border)

        local acReset = Utils.Create("TextButton", {
            Text = "Reset",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextMed,
            BackgroundColor3 = Theme.Colors.Background2,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Size = UDim2.new(0, 50, 0, 22),
            Parent = acBtnWrap
        })
        Utils.Corner(acReset, Theme.Sizes.RadiusSmall)
        Utils.Stroke(acReset, Theme.Colors.Border, 1, Theme.Transparencies.Border)

        Registry.RegisterConnection(self, acPick.MouseButton1Click:Connect(function()
            acInput:CaptureFocus()
        end))
        Registry.RegisterConnection(self, acReset.MouseButton1Click:Connect(function()
            Theme:SetTheme(Theme.Current)
            acPreview.BackgroundColor3 = Theme.Colors.Accent
            acInput.Text = string.format(
                "#%02X%02X%02X",
                math.floor(Theme.Colors.Accent.R * 255),
                math.floor(Theme.Colors.Accent.G * 255),
                math.floor(Theme.Colors.Accent.B * 255)
            )
        end))

        createSeparator(settingsPanel)

        local _, uiBody = createGroup(settingsPanel, "Interface")
        local animToggle = Components.Toggle.new(uiBody, {Text = "Animações", Icon = "○", State = true})
        local noiseToggle = Components.Toggle.new(uiBody, {Text = "Noise Texture", Icon = "▦", State = true})
        Registry.Register(animToggle, self)
        Registry.Register(noiseToggle, self)

        createSeparator(settingsPanel)

        local _, smBody = createGroup(settingsPanel, "Save Manager — Configurações")
        local sm2 = saveBar:Clone()
        sm2.Parent = smBody
        local sm2Btns = sm2:FindFirstChildWhichIsA("Frame")
        if sm2Btns then
            for _, child in ipairs(sm2Btns:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            local resetAll = smButton("Reset Tudo", false, function()
                self:ShowDialog("resetAll")
            end)
            resetAll.Parent = sm2Btns
            local export = smButton("Exportar", true, function()
                if self.Notify then
                    self.Notify({Text = "Config exportada", Type = "success"})
                end
            end)
            export.Parent = sm2Btns
        end

        local _, aboutBody = createGroup(settingsPanel, "Sobre")
        local aboutCard = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 80),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = aboutBody
        })
        Utils.Corner(aboutCard, Theme.Sizes.RadiusMedium)
        Utils.Stroke(aboutCard, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(aboutCard, 12)
        Theme:Bind(aboutCard, {BackgroundColor3 = "Surface", BackgroundTransparency = "Surface"})

        local aboutTitle = Utils.Create("TextLabel", {
            Text = "Claude UI v4.0",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextLarge,
            TextColor3 = Theme.Colors.TextHigh,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = aboutCard
        })
        Theme:Bind(aboutTitle, {TextColor3 = "TextHigh"})

        local aboutSub = Utils.Create("TextLabel", {
            Text = "Build 2026.02.21 · Made by Claude (Anthropic)",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 14),
            Position = UDim2.new(0, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = aboutCard
        })
        Theme:Bind(aboutSub, {TextColor3 = "TextLow"})

        local aboutDesc = Utils.Create("TextLabel", {
            Text = "ColorPicker · SaveManager · Dialogs · MultiDropdown · ResizeHandle · Temas · Locked Components · v4 Complete",
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextMuted,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 40),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = aboutCard
        })
        Theme:Bind(aboutDesc, {TextColor3 = "TextMuted"})

        self.StatusBar = Utils.Create("Frame", {
            Name = "StatusBar",
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 1, -24),
            BackgroundColor3 = Theme.Colors.Background2,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = self.Window
        })
        Theme:Bind(self.StatusBar, {BackgroundColor3 = "Background2", BackgroundTransparency = "Surface"})
        Utils.Padding(self.StatusBar, 10)

        Utils.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 12),
            Parent = self.StatusBar
        })

        local function statusItem(text, color)
            local wrap = Utils.Create("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundTransparency = 1,
                Parent = self.StatusBar,
                AutomaticSize = Enum.AutomaticSize.X
            })
            local dot = Utils.Create("Frame", {
                Size = UDim2.new(0, 6, 0, 6),
                Position = UDim2.new(0, 0, 0.5, -3),
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                Parent = wrap
            })
            Utils.Corner(dot, UDim.new(1, 0))
            local lbl = Utils.Create("TextLabel", {
                Text = text,
                Font = Theme.Fonts.Mono,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextLow,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = wrap
            })
            Theme:Bind(lbl, {TextColor3 = "TextLow"})
            return lbl
        end

        statusItem("Conectado", Theme.Colors.Success)
        local pingLabel = statusItem("Ping: 42ms", Theme.Colors.Warning)
        local saveLabel = Utils.Create("TextLabel", {
            Text = "● Salvo",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.Success,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = self.StatusBar
        })
        Theme:Bind(saveLabel, {TextColor3 = "Success"})

        local statusVersion = Utils.Create("TextLabel", {
            Text = "Claude UI v4.0 · Anthropic · 00:00",
            Font = Theme.Fonts.Mono,
            TextSize = Theme.Sizes.TextSmall,
            TextColor3 = Theme.Colors.TextMuted,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Parent = self.StatusBar
        })
        Theme:Bind(statusVersion, {TextColor3 = "TextMuted"})

        self.ResizeHandle = Utils.Create("Frame", {
            Name = "ResizeHandle",
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -6, 1, -6),
            BackgroundColor3 = Theme.Colors.Background2,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = self.Window
        })
        Utils.Corner(self.ResizeHandle, Theme.Sizes.RadiusSmall)
        Utils.Stroke(self.ResizeHandle, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Theme:Bind(self.ResizeHandle, {BackgroundColor3 = "Background2", BackgroundTransparency = "Surface"})

        Draggable.Enable(self.Window, self.TitleBar)
        Resizable.Enable(self.Window, self.ResizeHandle, self.MinSize)

        self:SwitchTab("home")

        self.Notify = function(cfg)
            if self.Notification then
                self.Notification.New(cfg)
            end
        end

        local startTick = os.clock()
        task.spawn(function()
            while not self.Destroyed do
                local now = os.date("*t")
                clockText.Text = pad2(now.hour) .. ":" .. pad2(now.min) .. ":" .. pad2(now.sec)
                clockDate.Text = pad2(now.day) .. "/" .. pad2(now.month) .. "/" .. tostring(now.year)
                local hour = now.hour
                local greeting = hour < 6 and "Vai dormir," or hour < 12 and "Bom dia," or hour < 18 and "Boa tarde," or "Boa noite,"
                welcomeText.Text = greeting .. " ClaudeUser!"
                local elapsed = math.floor(os.clock() - startTick)
                upValue.Text = formatUptime(elapsed)
                local ping = 38 + math.floor(math.sin(os.clock()) * 8)
                pingValue.Text = tostring(ping) .. "ms"
                pingLabel.Text = "Ping: " .. tostring(ping) .. "ms"
                statusVersion.Text = "Claude UI v4.0 · Anthropic · " .. pad2(now.hour) .. ":" .. pad2(now.min)
                task.wait(1)
            end
        end)

        return self
    end

    function Window:SwitchTab(id)
        if not self.Panels[id] then
            return
        end
        self.State.ActiveTab:Set(id)
        for key, panel in pairs(self.Panels) do
            panel.Visible = key == id
        end
        for key, data in pairs(self.TabButtons) do
            local active = key == id
            data.Marker.Visible = active
            if active then
                TweenController:Play(data.Button, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.Surface})
                data.Label.TextColor3 = Theme.Colors.TextHigh
                data.Icon.TextColor3 = Theme.Colors.Accent
            else
                TweenController:Play(data.Button, TweenController.Smooth, {BackgroundTransparency = 1})
                data.Label.TextColor3 = Theme.Colors.TextMed
                data.Icon.TextColor3 = Theme.Colors.TextLow
            end
        end
    end

    function Window:ToggleMinimize()
        if self.Minimized then
            self.Minimized = false
            if self.LastSize then
                self.Window.Size = self.LastSize
            end
            self.Body.Visible = true
            self.StatusBar.Visible = true
            self.ResizeHandle.Visible = true
        else
            self.Minimized = true
            self.LastSize = self.Window.Size
            self.Body.Visible = false
            self.StatusBar.Visible = false
            self.ResizeHandle.Visible = false
            self.Window.Size = UDim2.new(self.Window.Size.X.Scale, self.Window.Size.X.Offset, 0, 46)
        end
    end

    function Window:ToggleMaximize()
        if self.Maximized then
            self.Maximized = false
            if self.LastSize then
                self.Window.Size = self.LastSize
            end
            if self.LastPos then
                self.Window.Position = self.LastPos
            end
        else
            self.Maximized = true
            self.LastSize = self.Window.Size
            self.LastPos = self.Window.Position
            self.Window.Size = UDim2.new(1, -40, 1, -40)
            self.Window.Position = UDim2.new(0, 20, 0, 20)
        end
    end

    function Window:ShowDialog(kind)
        if not self.Dialog then
            self.Dialog = Utils.Create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.new(0, 0, 0),
                BackgroundTransparency = 0.4,
                Parent = self.Backdrop,
                Visible = false
            })
            local dialogCard = Utils.Create("Frame", {
                Size = UDim2.new(0, 320, 0, 180),
                Position = UDim2.new(0.5, -160, 0.5, -90),
                BackgroundColor3 = Theme.Colors.Surface,
                BackgroundTransparency = Theme.Transparencies.Surface,
                Parent = self.Dialog
            })
            Utils.Corner(dialogCard, Theme.Sizes.RadiusLarge)
            Utils.Stroke(dialogCard, Theme.Colors.Border, 1, Theme.Transparencies.Border)
            Utils.Padding(dialogCard, 14)

            self.DialogTitle = Utils.Create("TextLabel", {
                Text = "Dialog",
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextHeader,
                TextColor3 = Theme.Colors.TextHigh,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dialogCard
            })
            Theme:Bind(self.DialogTitle, {TextColor3 = "TextHigh"})

            self.DialogText = Utils.Create("TextLabel", {
                Text = "Mensagem",
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextLow,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                Position = UDim2.new(0, 0, 0, 28),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = dialogCard
            })
            Theme:Bind(self.DialogText, {TextColor3 = "TextLow"})

            self.DialogButtons = Utils.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                Position = UDim2.new(0, 0, 1, -44),
                BackgroundTransparency = 1,
                Parent = dialogCard
            })
            Utils.Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 8),
                Parent = self.DialogButtons
            })
        end

        self.Dialog.Visible = true
        for _, child in ipairs(self.DialogButtons:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local function dialogBtn(text, variant, cb)
            local btn = Components.Button.new(self.DialogButtons, {Text = text, Variant = variant, Callback = function()
                self.Dialog.Visible = false
                if cb then cb() end
            end})
            Registry.Register(btn, self)
        end

        if kind == "confirm" then
            self.DialogTitle.Text = "Confirmar ação"
            self.DialogText.Text = "Deseja continuar esta operação?"
            dialogBtn("Cancelar", nil)
            dialogBtn("Confirmar", "Primary")
        elseif kind == "danger" then
            self.DialogTitle.Text = "Ação perigosa"
            self.DialogText.Text = "Esta ação não pode ser desfeita."
            dialogBtn("Cancelar", nil)
            dialogBtn("Continuar", "Danger")
        elseif kind == "info" then
            self.DialogTitle.Text = "Informação"
            self.DialogText.Text = "Operação informativa concluída."
            dialogBtn("Ok", "Primary")
        elseif kind == "choices" then
            self.DialogTitle.Text = "Escolha uma opção"
            self.DialogText.Text = "Selecione uma das ações disponíveis."
            dialogBtn("Opção A", nil)
            dialogBtn("Opção B", "Primary")
            dialogBtn("Opção C", nil)
        elseif kind == "resetAll" then
            self.DialogTitle.Text = "Reset completo"
            self.DialogText.Text = "Resetar todas as configurações?"
            dialogBtn("Cancelar", nil)
            dialogBtn("Resetar", "Danger")
        else
            self.DialogTitle.Text = "Dialog"
            self.DialogText.Text = "Mensagem padrão."
            dialogBtn("Ok", "Primary")
        end
    end

    function Window:Init(notificationModule)
        self.Notification = notificationModule
        if self.Notification then
            self.Notification.Init(self.Gui)
        end
    end

    function Window:Mount()
        if self.Window then
            self.Window.Visible = true
        end
    end

    function Window:Destroy()
        if self.Destroyed then
            return
        end
        self.Destroyed = true
        if self.Window then
            self.Window:Destroy()
        end
        Registry.CleanupWindow(self)
    end

    return Window
end
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
