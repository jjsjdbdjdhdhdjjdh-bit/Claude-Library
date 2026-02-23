local TweenService = game:GetService("TweenService")
local Theme = Import("core/Theme")
local Utils = Import("core/Utils")
local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkIcon = Utils.mkIcon
local tw = Utils.tw

local fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local med  = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Button = {}

function Button.Create(parent, text, callback, opts)
    opts = opts or {}

    local isPrimary = opts.Primary or false
    local isDanger  = opts.Danger  or false
    local isDisabled = opts.Disabled or false

    -- cores base por variante
    local bgN, bgH, bgA, textColor, strokeColor
    if isDanger then
        bgN       = Color3.fromRGB(60, 20, 20)
        bgH       = Color3.fromRGB(80, 25, 25)
        bgA       = Color3.fromRGB(100, 30, 30)
        textColor = Color3.fromRGB(255, 100, 100)
        strokeColor = Color3.fromRGB(120, 40, 40)
    elseif isPrimary then
        bgN       = Theme.Primary
        bgH       = Theme.PrimaryHover
        bgA       = Theme.PrimaryHover
        textColor = Theme.PrimaryText
        strokeColor = nil
    else
        bgN       = Theme.Surface
        bgH       = Theme.SurfaceHover
        bgA       = Theme.SurfaceActive
        textColor = Theme.TextPrimary
        strokeColor = Theme.Border
    end

    if isDisabled then
        bgN     = Color3.fromRGB(35, 35, 35)
        bgH     = bgN
        bgA     = bgN
        textColor = Color3.fromRGB(90, 90, 90)
        strokeColor = Color3.fromRGB(50, 50, 50)
    end

    -- Container
    local btn = inst("TextButton", {
        Size             = UDim2.new(1, 0, 0, opts.Height or 36),
        BackgroundColor3 = bgN,
        Text             = "",
        BorderSizePixel  = 0,
        LayoutOrder      = opts.Order or 0,
        AutoButtonColor  = false,
        ClipsDescendants = true,
        ZIndex           = 4,
        Parent           = parent,
    })
    corner(btn, 6)
    if strokeColor then mkStroke(btn, strokeColor, 1) end

    -- Shimmer/highlight no topo para dar profundidade
    local highlight = inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = isPrimary and 0.82 or 0.92,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = btn,
    })

    -- Ripple layer
    local rippleLayer = inst("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = btn,
    })

    -- Ícone
    local iconW   = 0
    local iconColor = isDisabled and Color3.fromRGB(90, 90, 90)
        or (isPrimary and Theme.PrimaryText or (isDanger and Color3.fromRGB(255, 100, 100) or Theme.TextSecondary))
    local iconImg = mkIcon(btn, opts.Icon, 14, iconColor, 5,
        Vector2.new(0, 0.5), UDim2.new(0, 14, 0.5, 0))
    if iconImg then iconW = 14 + 8 end

    -- Label
    local label = inst("TextLabel", {
        Size            = UDim2.new(1, -(16 + iconW), 1, 0),
        Position        = UDim2.new(0, 14 + iconW, 0, 0),
        BackgroundTransparency = 1,
        Text            = text,
        TextColor3      = textColor,
        TextSize        = 13,
        Font            = Enum.Font.GothamMedium,
        TextXAlignment  = iconW > 0 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
        ZIndex          = 7,
        Parent          = btn,
    })

    -- Badge opcional (ex: opts.Badge = "NEW")
    if opts.Badge then
        local badge = inst("Frame", {
            Size             = UDim2.new(0, 0, 0, 16),
            AutomaticSize    = Enum.AutomaticSize.X,
            Position         = UDim2.new(1, -8, 0.5, 0),
            AnchorPoint      = Vector2.new(1, 0.5),
            BackgroundColor3 = isDanger and Color3.fromRGB(200, 50, 50) or Theme.Primary,
            BorderSizePixel  = 0,
            ZIndex           = 8,
            Parent           = btn,
        })
        corner(badge, 8)
        local mkPad = Utils.mkPad or function(f, t, r, b, l)
            inst("UIPadding", { PaddingTop=UDim.new(0,t), PaddingRight=UDim.new(0,r),
                PaddingBottom=UDim.new(0,b), PaddingLeft=UDim.new(0,l), Parent=f })
        end
        mkPad(badge, 0, 6, 0, 6)
        inst("TextLabel", {
            Size            = UDim2.new(0, 0, 1, 0),
            AutomaticSize   = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text            = opts.Badge,
            TextColor3      = Color3.fromRGB(255, 255, 255),
            TextSize        = 9,
            Font            = Enum.Font.GothamBold,
            TextXAlignment  = Enum.TextXAlignment.Center,
            ZIndex          = 9,
            Parent          = badge,
        })
    end

    -- Ripple effect
    local function spawnRipple()
        local ripple = inst("Frame", {
            Size             = UDim2.new(0, 0, 0, 0),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.85,
            BorderSizePixel  = 0,
            ZIndex           = 5,
            Parent           = rippleLayer,
        })
        corner(ripple, 999)
        local size = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.2
        TweenService:Create(ripple, med, {
            Size = UDim2.new(0, size, 0, size),
            BackgroundTransparency = 1,
        }):Play()
        game:GetService("Debris"):AddItem(ripple, 0.3)
    end

    -- Interações
    if not isDisabled then
        btn.MouseEnter:Connect(function()
            tw(btn, fast, { BackgroundColor3 = bgH })
            tw(highlight, fast, { BackgroundTransparency = isPrimary and 0.75 or 0.88 })
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, fast, { BackgroundColor3 = bgN })
            tw(highlight, fast, { BackgroundTransparency = isPrimary and 0.82 or 0.92 })
        end)
        btn.MouseButton1Down:Connect(function()
            tw(btn, fast, { BackgroundColor3 = bgA })
            spawnRipple()
        end)
        btn.MouseButton1Up:Connect(function()
            tw(btn, fast, { BackgroundColor3 = bgH })
        end)
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    else
        btn.Active = false
    end

    -- API pública
    local api = {}

    function api:SetText(t)   label.Text = t end
    function api:SetDisabled(v)
        isDisabled = v
        btn.Active = not v
        tw(btn,   fast, { BackgroundColor3 = v and Color3.fromRGB(35,35,35) or bgN })
        tw(label, fast, { TextColor3 = v and Color3.fromRGB(90,90,90) or textColor })
    end
    function api:GetButton() return btn end

    return api
end

return Button
