local Theme = Import("core/Theme")
local T = Theme

local LucideIcons = nil
local function getLucide()
    if LucideIcons then return LucideIcons end
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library/refs/heads/master/LucideIcons.luau"
        ))()
    end)
    if ok then LucideIcons = result end
    return LucideIcons
end

local function iconAsset(name)
    if not name or name == "" then return nil end
    local lib = getLucide()
    if not lib then return nil end
    local id = lib[name]
    if not id then return nil end
    return "rbxassetid://" .. tostring(id)
end

local function inst(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    return o
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

local function mkStroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color     = col   or T.Border
    s.Thickness = thick or 1
    s.Parent    = p
    return s
end

local function mkPad(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 8)
    u.PaddingRight  = UDim.new(0, r or 8)
    u.PaddingBottom = UDim.new(0, b or 8)
    u.PaddingLeft   = UDim.new(0, l or 8)
    u.Parent = p
    return u
end

local function mkIcon(parent, iconName, size, color, zIndex, anchorPoint, position)
    local asset = iconAsset(iconName)
    if not asset then return nil end
    size        = size        or 16
    color       = color       or T.IconTint
    zIndex      = zIndex      or 3
    anchorPoint = anchorPoint or Vector2.new(0, 0.5)
    position    = position    or UDim2.new(0, 0, 0.5, 0)
    return inst("ImageLabel", {
        Size            = UDim2.new(0, size, 0, size),
        AnchorPoint     = anchorPoint,
        Position        = position,
        BackgroundTransparency = 1,
        Image           = asset,
        ImageColor3     = color,
        ScaleType       = Enum.ScaleType.Fit,
        ZIndex          = zIndex,
        Parent          = parent,
    })
end

return {
    inst = inst,
    corner = corner,
    mkStroke = mkStroke,
    mkPad = mkPad,
    mkIcon = mkIcon,
    iconAsset = iconAsset,
    getLucide = getLucide
}
