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
