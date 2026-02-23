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
        ZIndex           = 4,
        Parent           = parent,
    })
    corner(btn, 5)
    if not isPrimary then mkStroke(btn, Theme.Border, 1) end

    local iconW   = 0
    local iconImg = mkIcon(btn, opts.Icon, 14,
        isPrimary and Theme.PrimaryText or Theme.TextSecondary,
        5, Vector2.new(0, 0.5), UDim2.new(0, 12, 0.5, 0))
    if iconImg then iconW = 14 + 8 end

inst("TextLabel", {
    Size                   = UDim2.new(1, -(12 + iconW), 1, 0),
    Position               = UDim2.new(0, 12 + iconW, 0, 0),
    BackgroundTransparency = 1,
    Text                   = text,
    TextColor3             = isPrimary and Theme.PrimaryText or Theme.TextPrimary,
    TextSize               = 13,
    Font                   = Enum.Font.GothamMedium,
    TextXAlignment         = Enum.TextXAlignment.Left, -- sempre à esquerda
    ZIndex                 = 5,
    Parent                 = btn,
})

    btn.MouseEnter:Connect(function()    tw(btn, fast, { BackgroundColor3 = bgH }) end)
    btn.MouseLeave:Connect(function()    tw(btn, fast, { BackgroundColor3 = bgN }) end)
    btn.MouseButton1Down:Connect(function() tw(btn, fast, { BackgroundColor3 = Theme.SurfaceActive }) end)
    btn.MouseButton1Up:Connect(function()   tw(btn, fast, { BackgroundColor3 = bgH }) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

return Button
