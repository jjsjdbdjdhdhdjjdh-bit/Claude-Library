<<<<<<< HEAD
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
=======
local Utils = {}

function Utils.Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utils.Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 6)
    corner.Parent = parent
    return corner
end

function Utils.Stroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.new(1, 1, 1)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

function Utils.Padding(parent, px)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, px)
    pad.PaddingBottom = UDim.new(0, px)
    pad.PaddingLeft = UDim.new(0, px)
    pad.PaddingRight = UDim.new(0, px)
    pad.Parent = parent
    return pad
end

function Utils.Scale(parent, value)
    local scale = Instance.new("UIScale")
    scale.Scale = value or 1
    scale.Parent = parent
    return scale
end

function Utils.Gradient(parent, colors, rotation)
    local grad = Instance.new("UIGradient")
    grad.Color = colors
    grad.Rotation = rotation or 0
    grad.Parent = parent
    return grad
end

return Utils
>>>>>>> 68fce3efb4a4e03149113b2568733617304d9375
