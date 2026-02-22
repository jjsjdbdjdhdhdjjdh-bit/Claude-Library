local Theme = {}

Theme.Fonts = {
    Main = Enum.Font.Gotham,
    Mono = Enum.Font.Code
}

Theme.Sizes = {
    RadiusSmall = UDim.new(0, 6),
    RadiusMedium = UDim.new(0, 10),
    RadiusLarge = UDim.new(0, 16),
    RadiusXLarge = UDim.new(0, 24),
    TextXS = 9,
    TextSmall = 10,
    TextNormal = 12,
    TextMedium = 12.5,
    TextLarge = 13,
    TextTitle = 15,
    TextHeader = 16
}

Theme.Defs = {
    default = {
        acc = "#d4825a",
        accH = "#e09070",
        accL = "#c97240",
        accRgb = {212, 130, 90},
        bg = "#1a1714",
        bg2 = "#141210",
        bg3 = "#0f0d0b",
        surfaceRgb = {250, 248, 245},
        surfaceA = 0.04,
        surfaceH = 0.07,
        surfaceB = 0.10,
        borderA = 0.08,
        borderM = 0.14,
        tHigh = "#f5f0e8",
        tMed = "#c8bfb0",
        tLow = "#7a7570",
        tMuted = "#4a4540",
        success = "#5a8f6e",
        warning = "#c9943a",
        error = "#c46060",
        info = "#5a7ea8"
    },
    light = {
        acc = "#d4825a",
        accH = "#e09070",
        accL = "#c97240",
        accRgb = {212, 130, 90},
        bg = "#f5f0e8",
        bg2 = "#ede4d4",
        bg3 = "#e0d5c2",
        surfaceRgb = {30, 25, 20},
        surfaceA = 0.04,
        surfaceH = 0.07,
        surfaceB = 0.10,
        borderA = 0.08,
        borderM = 0.16,
        tHigh = "#1a1510",
        tMed = "#4a4038",
        tLow = "#8a8078",
        tMuted = "#b0a898",
        success = "#5a8f6e",
        warning = "#c9943a",
        error = "#c46060",
        info = "#5a7ea8"
    },
    neon = {
        acc = "#00f5a0",
        accH = "#30ffb8",
        accL = "#00c880",
        accRgb = {0, 245, 160},
        bg = "#060a12",
        bg2 = "#040810",
        bg3 = "#020508",
        surfaceRgb = {0, 245, 160},
        surfaceA = 0.04,
        surfaceH = 0.07,
        surfaceB = 0.10,
        borderA = 0.08,
        borderM = 0.15,
        tHigh = "#d0ffe8",
        tMed = "#80c0a0",
        tLow = "#408060",
        tMuted = "#204030",
        success = "#5a8f6e",
        warning = "#c9943a",
        error = "#c46060",
        info = "#5a7ea8"
    },
    rose = {
        acc = "#e87080",
        accH = "#f08898",
        accL = "#d05868",
        accRgb = {232, 112, 128},
        bg = "#120a0c",
        bg2 = "#0e0608",
        bg3 = "#0a0406",
        surfaceRgb = {255, 220, 225},
        surfaceA = 0.04,
        surfaceH = 0.07,
        surfaceB = 0.10,
        borderA = 0.08,
        borderM = 0.14,
        tHigh = "#ffe8ec",
        tMed = "#c09098",
        tLow = "#806068",
        tMuted = "#503038",
        success = "#5a8f6e",
        warning = "#c9943a",
        error = "#c46060",
        info = "#5a7ea8"
    },
    blue = {
        acc = "#5a90d0",
        accH = "#70a8e8",
        accL = "#4878b8",
        accRgb = {90, 144, 208},
        bg = "#0a0e18",
        bg2 = "#080c14",
        bg3 = "#060a10",
        surfaceRgb = {200, 220, 255},
        surfaceA = 0.04,
        surfaceH = 0.07,
        surfaceB = 0.10,
        borderA = 0.08,
        borderM = 0.14,
        tHigh = "#e0ecff",
        tMed = "#90a8c8",
        tLow = "#506888",
        tMuted = "#304058",
        success = "#5a8f6e",
        warning = "#c9943a",
        error = "#c46060",
        info = "#5a7ea8"
    }
}

Theme.Current = "default"
Theme.Bindings = {}

local function hexToColor3(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    return Color3.fromRGB(r, g, b)
end

local function fromRgb(arr)
    return Color3.fromRGB(arr[1], arr[2], arr[3])
end

local function transparencyFromAlpha(alpha)
    return 1 - alpha
end

function Theme:BuildPalette(name)
    local d = Theme.Defs[name] or Theme.Defs.default
    Theme.Colors = {
        Accent = hexToColor3(d.acc),
        AccentHigh = hexToColor3(d.accH),
        AccentLow = hexToColor3(d.accL),
        AccentRgb = d.accRgb,
        Background = hexToColor3(d.bg),
        Background2 = hexToColor3(d.bg2),
        Background3 = hexToColor3(d.bg3),
        Surface = fromRgb(d.surfaceRgb),
        Border = fromRgb(d.surfaceRgb),
        TextHigh = hexToColor3(d.tHigh),
        TextMed = hexToColor3(d.tMed),
        TextLow = hexToColor3(d.tLow),
        TextMuted = hexToColor3(d.tMuted),
        Success = hexToColor3(d.success),
        Warning = hexToColor3(d.warning),
        Error = hexToColor3(d.error),
        Info = hexToColor3(d.info)
    }
    Theme.Transparencies = {
        Surface = transparencyFromAlpha(d.surfaceA),
        SurfaceHover = transparencyFromAlpha(d.surfaceH),
        SurfaceActive = transparencyFromAlpha(d.surfaceB),
        Border = transparencyFromAlpha(d.borderA),
        BorderMid = transparencyFromAlpha(d.borderM),
        WindowBg = name == "light" and 0.08 or 0.16,
        Noise = 0.975
    }
end

Theme:BuildPalette("default")

function Theme:SetTheme(name)
    Theme.Current = name or "default"
    Theme:BuildPalette(Theme.Current)
    for inst, map in pairs(Theme.Bindings) do
        if inst and inst.Parent then
            Theme:Apply(inst, map)
        else
            Theme.Bindings[inst] = nil
        end
    end
end

function Theme:SetCustomAccent(hex)
    local c = hexToColor3(hex)
    local r = math.floor(c.R * 255)
    local g = math.floor(c.G * 255)
    local b = math.floor(c.B * 255)
    Theme.Colors.Accent = c
    Theme.Colors.AccentHigh = Color3.fromRGB(math.min(255, math.floor(r * 1.15)), math.min(255, math.floor(g * 1.15)), math.min(255, math.floor(b * 1.15)))
    Theme.Colors.AccentLow = Color3.fromRGB(math.floor(r * 0.85), math.floor(g * 0.85), math.floor(b * 0.85))
    Theme.Colors.AccentRgb = {r, g, b}
    for inst, map in pairs(Theme.Bindings) do
        if inst and inst.Parent then
            Theme:Apply(inst, map)
        else
            Theme.Bindings[inst] = nil
        end
    end
end

function Theme:Resolve(key)
    if Theme.Colors[key] ~= nil then
        return Theme.Colors[key]
    end
    if Theme.Transparencies[key] ~= nil then
        return Theme.Transparencies[key]
    end
    return nil
end

function Theme:Apply(instance, map)
    for prop, key in pairs(map) do
        local value
        if type(key) == "function" then
            value = key()
        else
            value = Theme:Resolve(key)
            if value == nil then
                value = key
            end
        end
        instance[prop] = value
    end
end

function Theme:Bind(instance, map)
    Theme:Apply(instance, map)
    Theme.Bindings[instance] = map
    if instance.Destroying then
        instance.Destroying:Connect(function()
            Theme.Bindings[instance] = nil
        end)
    end
end

return Theme
