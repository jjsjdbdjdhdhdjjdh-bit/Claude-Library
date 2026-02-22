local Effects = {}

function Effects.Ripple(parent, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.new(1, 1, 1)
    ripple.BackgroundTransparency = 0.6
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    local px = x or parent.AbsoluteSize.X / 2
    local py = y or parent.AbsoluteSize.Y / 2
    ripple.Position = UDim2.new(0, px, 0, py)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    ripple.Parent = parent
    
    local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.6
    local targetSize = UDim2.new(0, maxSize, 0, maxSize)
    
    local TweenService = game:GetService("TweenService")
    TweenService:Create(ripple, tweenInfo, {
        Size = targetSize,
        BackgroundTransparency = 1
    }):Play()
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

function Effects.Glow(parent, color, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857472" -- Soft glow texture
    glow.ImageColor3 = color
    glow.ImageTransparency = transparency or 0.5
    glow.Size = UDim2.new(1, 40, 1, 40)
    glow.Position = UDim2.new(0, -20, 0, -20)
    glow.ZIndex = 0
    glow.Parent = parent
    return glow
end

return Effects
