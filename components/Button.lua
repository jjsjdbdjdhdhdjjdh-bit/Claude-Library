local TweenService = game:GetService("TweenService")
local Theme = Import("core/Theme")
local Utils = Import("core/Utils")
local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkIcon = Utils.mkIcon
local tw = Utils.tw

local fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Button = {}

function Button.Create(parent, text, callback, opts)
    opts = opts or {}
    local isPrimary = opts.Primary or false
    local bgN = isPrimary and Theme.Primary or Theme.Surface
    local bgH = isPrimary and Theme.PrimaryHover or Theme.SurfaceHover

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
    corner(btn, 7)

    if isPrimary then
        -- stroke interno luminoso para botão primário
        mkStroke(btn, Theme.PrimaryHover, 1)
    else
        mkStroke(btn, Theme.Border, 1)
    end

    -- linha de highlight no topo (dá sensação de elevação)
    inst("Frame", {
        Size             = UDim2.new(1, -2, 0, 1),
        Position         = UDim2.new(0, 1, 0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = isPrimary and 0.78 or 0.89,
        BorderSizePixel  = 0,
        ZIndex           = 7,
        Parent           = btn,
    })

    -- sombra interna na base (dá profundidade)
    inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.65,
        BorderSizePixel  = 0,
        ZIndex           = 7,
        Parent           = btn,
    })

    local iconW   = 0
    local iconImg = mkIcon(btn, opts.Icon, 14,
        isPrimary and Theme.PrimaryText or Theme.TextSecondary,
        5, Vector2.new(0, 0.5), UDim2.new(0, 12, 0.5, 0))
    if iconImg then iconW = 14 + 8 end

    inst("TextLabel", {
        Size            = UDim2.new(1, -(12 + iconW), 1, 0),
        Position        = UDim2.new(0, 12 + iconW, 0, 0),
        BackgroundTransparency = 1,
        Text            = text,
        TextColor3      = isPrimary and Theme.PrimaryText or Theme.TextPrimary,
        TextSize        = 13,
        Font            = Enum.Font.GothamMedium,
        TextXAlignment  = iconW > 0 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
        ZIndex          = 5,
        Parent          = btn,
    })

    btn.MouseEnter:Connect(function()
        tw(btn, fast, { BackgroundColor3 = bgH })
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, fast, { BackgroundColor3 = bgN })
    end)
    btn.MouseButton1Down:Connect(function()
        tw(btn, fast, { BackgroundColor3 = Theme.SurfaceActive })
        local r = inst("Frame", {
            Size             = UDim2.new(0, 0, 0, 0),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.86,
            BorderSizePixel  = 0,
            ZIndex           = 6,
            Parent           = btn,
        })
        corner(r, 999)
        local s = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.4
        TweenService:Create(r, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, s, 0, s),
            BackgroundTransparency = 1,
        }):Play()
        game:GetService("Debris"):AddItem(r, 0.45)
    end)
    btn.MouseButton1Up:Connect(function()
        tw(btn, fast, { BackgroundColor3 = bgH })
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return btn
end

return Button
