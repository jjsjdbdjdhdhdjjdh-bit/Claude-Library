local TweenService = game:GetService("TweenService")
local Theme = Import("core/Theme")
local Utils = Import("core/Utils")

local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkIcon = Utils.mkIcon
local tw = Utils.tw
local fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Input = {}

function Input.Create(parent, placeholder, callback, opts)
    opts = opts or {}
    local container = inst("Frame", {
        Size             = UDim2.new(1, 0, 0, opts.Height or 38),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        LayoutOrder      = opts.Order or 0,
        ZIndex           = 4,
        Parent           = parent,
    })
    corner(container, 5)
    local s = mkStroke(container, Theme.Border, 1)

    local iconW   = 0
    local iconImg = mkIcon(container, opts.Icon, 14, Theme.TextMuted, 6,
        Vector2.new(0, 0.5), UDim2.new(0, 11, 0.5, 0))
    if iconImg then iconW = 14 + 6 end

    local PLACEHOLDER_SIZE = 14
    local CONTENT_SIZE     = 20

    local box = inst("TextBox", {
        Size              = UDim2.new(1, -(12 + iconW), 1, 0),
        Position          = UDim2.new(0, 10 + iconW, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText   = placeholder or "",
        PlaceholderColor3 = Theme.TextMuted,
        Text              = opts.Default or "",
        TextColor3        = Theme.TextPrimary,
        TextSize          = (opts.Default and opts.Default ~= "") and CONTENT_SIZE or PLACEHOLDER_SIZE,
        Font              = Enum.Font.Gotham,
        ClearTextOnFocus  = false,
        ZIndex            = 6,
        Parent            = container,
    })
    box:GetPropertyChangedSignal("Text"):Connect(function()
        box.TextSize = (box.Text ~= "") and CONTENT_SIZE or PLACEHOLDER_SIZE
    end)
    box.Focused:Connect(function()
        tw(s, fast, { Color = Theme.BorderFocus })
        if iconImg then tw(iconImg, fast, { ImageColor3 = Theme.Primary }) end
    end)
    box.FocusLost:Connect(function(enter)
        tw(s, fast, { Color = Theme.Border })
        if iconImg then tw(iconImg, fast, { ImageColor3 = Theme.TextMuted }) end
        if callback then callback(box.Text, enter) end
    end)
    return box
end

return Input