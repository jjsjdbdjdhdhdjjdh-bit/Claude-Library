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

local Toggle = {}

function Toggle.Create(parent, label, default, callback, opts)
    opts  = opts or {}
    local state = default or false
    local style = opts.Style or "box"

    local row = inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        LayoutOrder      = opts.Order or 0,
        ZIndex           = 4,
        Parent           = parent,
    })
    corner(row, 5)
    mkStroke(row, Theme.Border, 1)
    Utils.mkPad(row, 0, 14, 0, 12)

    local iconW   = 0
    local iconImg = mkIcon(row, opts.Icon, 14, Theme.TextSecondary, 6,
        Vector2.new(0, 0.5), UDim2.new(0, 0, 0.5, 0))
    if iconImg then iconW = 14 + 8 end

    inst("TextLabel", {
        Size            = UDim2.new(1, -(iconW + 46), 1, 0),
        Position        = UDim2.new(0, iconW, 0, 0),
        BackgroundTransparency = 1,
        Text            = label,
        TextColor3      = Theme.TextPrimary,
        TextSize        = 13,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 5,
        Parent          = row,
    })

    local set
    if style == "box" then
        local BOX = 26
        local box = inst("Frame", {
            Size             = UDim2.new(0, BOX, 0, BOX),
            Position         = UDim2.new(1, -BOX, 0.5, -BOX/2),
            BackgroundColor3 = state and Theme.ToggleOn or Color3.fromRGB(45, 45, 45),
            BorderSizePixel  = 0,
            ZIndex           = 5,
            Parent           = row,
        })
        corner(box, 6)
        local boxStroke = inst("UIStroke", {
            Color           = state and Theme.ToggleOn or Color3.fromRGB(80, 80, 80),
            Thickness       = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent          = box,
        })
        local checkIcon = mkIcon(box, "check", 14, Color3.fromRGB(255, 255, 255), 6,
            Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0))
        if checkIcon then checkIcon.ImageTransparency = state and 0 or 1 end
        set = function(v)
            state = v
            if state then
                tw(box,       fast, { BackgroundColor3 = Theme.ToggleOn })
                tw(boxStroke, fast, { Color = Theme.ToggleOn })
                if checkIcon then tw(checkIcon, fast, { ImageTransparency = 0 }) end
            else
                tw(box,       fast, { BackgroundColor3 = Color3.fromRGB(45, 45, 45) })
                tw(boxStroke, fast, { Color = Color3.fromRGB(80, 80, 80) })
                if checkIcon then tw(checkIcon, fast, { ImageTransparency = 1 }) end
            end
        end
    else
        local TW, TH = 46, 24
        local track = inst("Frame", {
            Size             = UDim2.new(0, TW, 0, TH),
            Position         = UDim2.new(1, -TW, 0.5, -TH/2),
            BackgroundColor3 = state and Theme.ToggleOn or Color3.fromRGB(30, 30, 30),
            BorderSizePixel  = 0,
            ZIndex           = 5,
            Parent           = row,
        })
        corner(track, TH/2)
        local trackStroke = inst("UIStroke", {
            Color           = state and Theme.ToggleOn or Color3.fromRGB(15, 15, 15),
            Thickness       = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Parent          = track,
        })
        local KS   = TH - 6
        local knob = inst("Frame", {
            Size             = UDim2.new(0, KS, 0, KS),
            Position         = UDim2.new(0, state and (TW - KS - 3) or 3, 0.5, -KS/2),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel  = 0,
            ZIndex           = 6,
            Parent           = track,
        })
        corner(knob, KS/2)
        set = function(v)
            state = v
            if state then
                tw(track,       fast, { BackgroundColor3 = Theme.ToggleOn })
                tw(trackStroke, fast, { Color = Theme.ToggleOn })
                tw(knob,        fast, { Position = UDim2.new(0, TW - KS - 3, 0.5, -KS/2) })
            else
                tw(track,       fast, { BackgroundColor3 = Color3.fromRGB(30, 30, 30) })
                tw(trackStroke, fast, { Color = Color3.fromRGB(15, 15, 15) })
                tw(knob,        fast, { Position = UDim2.new(0, 3, 0.5, -KS/2) })
            end
        end
    end

    inst("TextButton", {
        Size            = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = "",
        ZIndex          = 7,
        Parent          = row,
    }).MouseButton1Click:Connect(function()
        set(not state)
        if callback then callback(state) end
    end)

    return { Get = function() return state end, Set = set }
end

return Toggle
=======
return function(Theme, Utils, Effects, TweenController)
    local Toggle = {}
    Toggle.__index = Toggle

    function Toggle.new(parent, config)
        local self = setmetatable({}, Toggle)

        self.Config = config or {}
        self.Text = self.Config.Text or "Toggle"
        self.Icon = self.Config.Icon or ""
        self.State = self.Config.State or false
        self.Locked = self.Config.Locked or false
        self.Callback = self.Config.Callback or function() end

        self.Instance = Utils.Create("Frame", {
            Name = "ToggleRow",
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = Theme.Colors.Surface,
            BackgroundTransparency = Theme.Transparencies.Surface,
            Parent = parent
        })
        Utils.Corner(self.Instance, Theme.Sizes.RadiusMedium)
        local stroke = Utils.Stroke(self.Instance, Theme.Colors.Border, 1, Theme.Transparencies.Border)
        Utils.Padding(self.Instance, 13)

        local icon = Utils.Create("TextLabel", {
            Name = "Icon",
            Text = self.Icon,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextNormal,
            TextColor3 = Theme.Colors.TextLow,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, self.Icon == "" and 0 or 14, 1, 0),
            Visible = self.Icon ~= "",
            Parent = self.Instance
        })

        self.Label = Utils.Create("TextLabel", {
            Name = "Label",
            Text = self.Text,
            Font = Theme.Fonts.Main,
            TextSize = Theme.Sizes.TextMedium,
            TextColor3 = Theme.Colors.TextMed,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -80, 1, 0),
            Position = UDim2.new(0, self.Icon == "" and 0 or 23, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Instance
        })

        self.Switch = Utils.Create("Frame", {
            Name = "Switch",
            Size = UDim2.new(0, 40, 0, 22),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            BackgroundColor3 = Theme.Colors.TextMuted,
            BorderSizePixel = 0,
            Parent = self.Instance
        })
        Utils.Corner(self.Switch, UDim.new(1, 0))

        self.Knob = Utils.Create("Frame", {
            Name = "Knob",
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 2, 0.5, -7),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Parent = self.Switch
        })
        Utils.Corner(self.Knob, UDim.new(1, 0))

        self.Button = Utils.Create("TextButton", {
            Text = "",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = self.Instance
        })

        self.Button.MouseEnter:Connect(function()
            if self.Locked then
                return
            end
            TweenController:Play(self.Instance, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.SurfaceHover})
            stroke.Transparency = Theme.Transparencies.BorderMid
        end)

        self.Button.MouseLeave:Connect(function()
            TweenController:Play(self.Instance, TweenController.Smooth, {BackgroundTransparency = Theme.Transparencies.Surface})
            stroke.Transparency = Theme.Transparencies.Border
        end)

        self.Button.MouseButton1Click:Connect(function()
            if self.Locked then
                return
            end
            self:Set(not self.State)
        end)

        self:Set(self.State, true)

        if self.Locked then
            self.Instance.BackgroundTransparency = 0.6
            self.Label.TextTransparency = 0.45
            icon.TextTransparency = 0.45
        end

        return self
    end

    function Toggle:Set(state, skipCallback)
        self.State = state
        if self.State then
            TweenController:Play(self.Switch, TweenController.Smooth, {BackgroundColor3 = Theme.Colors.Accent})
            TweenController:Play(self.Knob, TweenController.Spring, {Position = UDim2.new(0, 24, 0.5, -7), BackgroundTransparency = 0})
            self.Label.TextColor3 = Theme.Colors.TextHigh
        else
            TweenController:Play(self.Switch, TweenController.Smooth, {BackgroundColor3 = Theme.Colors.TextMuted})
            TweenController:Play(self.Knob, TweenController.Spring, {Position = UDim2.new(0, 2, 0.5, -7), BackgroundTransparency = 0.4})
            self.Label.TextColor3 = Theme.Colors.TextMed
        end
        if not skipCallback then
            self.Callback(self.State)
        end
    end

    return Toggle
end
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
