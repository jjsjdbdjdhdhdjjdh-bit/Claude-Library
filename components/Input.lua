<<<<<<< HEAD
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
=======
return function(Theme, Utils, TweenController)
    local Input = {}
    Input.__index = Input

    function Input.new(parent, config)
        local self = setmetatable({}, Input)

        self.Config = config or {}
        self.Title = self.Config.Title
        self.Icon = self.Config.Icon or "⌘"
        self.Placeholder = self.Config.Placeholder or "Input..."
        self.Text = self.Config.Text or ""
        self.Callback = self.Config.Callback or function() end

        local height = self.Title and 60 or 44
        self.Instance = Utils.Create("Frame", {
            Name = "InputWrap",
            Size = UDim2.new(1, 0, 0, height),
            BackgroundTransparency = 1,
            Parent = parent
        })

        if self.Title then
            self.Label = Utils.Create("TextLabel", {
                Text = self.Title,
                Font = Theme.Fonts.Main,
                TextSize = Theme.Sizes.TextSmall,
                TextColor3 = Theme.Colors.TextMed,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = self.Instance
            })
        end

        self.BoxContainer = Utils.Create("Frame", {
            Name = "InputRow",
            Size = UDim2.new(1, 0, 0, 40),
            Position = UDim2.new(0, 0, 0, self.Title and 20 or 0),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = self.Instance
        })
        Utils.Corner(self.BoxContainer, Theme.Sizes.RadiusMedium)
        local stroke = Utils.Stroke(self.BoxContainer, Theme.Colors.Border, 1, Theme.Transparencies.Border)

        local icon = Utils.Create("TextLabel", {
            Name = "Icon",
            Text = self.Icon,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.BoxContainer
        })

        self.TextBox = Utils.Create("TextBox", {
            Name = "TextBox",
            Text = self.Text,
            PlaceholderText = self.Placeholder,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.TextHigh,
            PlaceholderColor3 = Theme.Colors.TextMuted,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 34, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            Parent = self.BoxContainer
        })

        self.TextBox.Focused:Connect(function()
            TweenController:Play(self.BoxContainer, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.SurfaceHover})
            stroke.Color = Theme.Colors.Accent
            stroke.Transparency = 0
        end)

        self.TextBox.FocusLost:Connect(function(enterPressed)
            TweenController:Play(self.BoxContainer, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.Surface})
            stroke.Color = Theme.Colors.Border
            stroke.Transparency = Theme.Transparencies.Border
            self.Text = self.TextBox.Text
            self.Callback(self.Text)
        end)

        return self
    end

    function Input:Set(text)
        self.Text = text
        self.TextBox.Text = text
    end

    return Input
end
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
