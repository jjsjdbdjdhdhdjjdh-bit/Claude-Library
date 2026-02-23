local RunService = game:GetService("RunService")
local Lighting   = game:GetService("Lighting")
local Camera     = workspace.CurrentCamera
local isStudio   = RunService:IsStudio()

local function _map(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end
local function _viewportPointToWorld(location, distance)
    local unitRay = Camera:ScreenPointToRay(location.X, location.Y)
    return unitRay.Origin + unitRay.Direction * distance
end
local function _getOffset()
    return _map(Camera.ViewportSize.Y, 0, 2560, 8, 56)
end
local function _acrylicSupported()
    return getgenv and (
        (getgenv().NoAnticheat == nil and true or getgenv().NoAnticheat)
        or not getgenv().SecureMode
    ) or isStudio
end
local function _createAcrylicPart()
    if not _acrylicSupported() then return nil end
    local part = Instance.new("Part")
    part.Name         = "ClaudeUIBlur"
    part.Color        = Color3.new(0, 0, 0)
    part.Material     = Enum.Material.Glass
    part.Size         = Vector3.new(1.04, 1.12, 0)
    part.Anchored     = true
    part.CanCollide   = false
    part.Locked       = true
    part.CastShadow   = false
    part.Transparency = 0.98
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Brick
    mesh.Offset   = Vector3.new(0, 0, -0.000001)
    mesh.Parent   = part
    return part
end
local function _initDOF()
    if not _acrylicSupported() then return end
    local existing
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("DepthOfFieldEffect") and v.Name ~= "ClaudeUIBlur" then
            existing = v; break
        end
    end
    if not existing then
        existing = Instance.new("DepthOfFieldEffect")
        existing.FarIntensity  = 0
        existing.NearIntensity = 0
        existing.FocusDistance = 500
        existing.InFocusRadius = 500
        existing.Enabled       = true
        existing.Parent        = Lighting
    end
    local blurDOF = Lighting:FindFirstChild("ClaudeUIBlur")
    if not blurDOF then
        blurDOF = existing:Clone()
        blurDOF.Name          = "ClaudeUIBlur"
        blurDOF.NearIntensity = 1
        blurDOF.Parent        = Lighting
    end
    local function sync()
        blurDOF.FarIntensity  = existing.FarIntensity
        blurDOF.FocusDistance = existing.FocusDistance
        blurDOF.InFocusRadius = existing.InFocusRadius
    end
    existing:GetPropertyChangedSignal("FarIntensity"):Connect(sync)
    existing:GetPropertyChangedSignal("FocusDistance"):Connect(sync)
    existing:GetPropertyChangedSignal("InFocusRadius"):Connect(sync)
end
local function _getBlurFolder()
    local folder = Camera:FindFirstChild("ClaudeUI Blur Elements")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name   = "ClaudeUI Blur Elements"
        folder.Parent = Camera
    end
    return folder
end

return function(parentFrame, windowBg)
    if not _acrylicSupported() then return nil end
    _initDOF()
    local part = _createAcrylicPart()
    if not part then return nil end
    part.Color  = windowBg or Color3.fromRGB(28, 28, 28)
    part.Parent = _getBlurFolder()
    local mesh     = part:FindFirstChildWhichIsA("SpecialMesh")
    local cleanups = {}
    local positions = { topLeft = Vector2.new(), topRight = Vector2.new(), bottomRight = Vector2.new() }
    local function updatePositions(size, position)
        positions.topLeft     = position
        positions.topRight    = position + Vector2.new(size.X, 0)
        positions.bottomRight = position + size
    end
    local function render()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local cf = cam.CFrame
        local tl = _viewportPointToWorld(positions.topLeft,     0.001)
        local tr = _viewportPointToWorld(positions.topRight,    0.001)
        local br = _viewportPointToWorld(positions.bottomRight, 0.001)
        local w  = (tr - tl).Magnitude
        local h  = (tr - br).Magnitude
        part.CFrame = CFrame.fromMatrix((tl + br) / 2, cf.XVector, cf.YVector, cf.ZVector)
        if mesh then mesh.Scale = Vector3.new(w, h, 0) end
    end
    local function onChange()
        local offset   = _getOffset()
        local abs      = parentFrame.AbsoluteSize
        local absPos   = parentFrame.AbsolutePosition
        local size     = abs    - Vector2.new(offset, offset)
        local position = absPos + Vector2.new(offset / 2, offset / 2)
        updatePositions(size, position)
        task.spawn(render)
    end
    local function hookCamera()
        local cam = workspace.CurrentCamera
        if not cam then return end
        cleanups[#cleanups+1] = cam:GetPropertyChangedSignal("CFrame"):Connect(render)
        cleanups[#cleanups+1] = cam:GetPropertyChangedSignal("ViewportSize"):Connect(render)
        cleanups[#cleanups+1] = cam:GetPropertyChangedSignal("FieldOfView"):Connect(render)
        task.spawn(render)
    end
    cleanups[#cleanups+1] = parentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(onChange)
    cleanups[#cleanups+1] = parentFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(onChange)
    part.Destroying:Connect(function()
        for _, c in ipairs(cleanups) do pcall(function() c:Disconnect() end) end
    end)
    hookCamera()
    task.spawn(onChange)
    local acrylicFrame = Instance.new("Frame")
    acrylicFrame.Name                   = "AcrylicLayer"
    acrylicFrame.Size                   = UDim2.fromScale(1, 1)
    acrylicFrame.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    acrylicFrame.BackgroundTransparency = 0.88
    acrylicFrame.BorderSizePixel        = 0
    acrylicFrame.ZIndex                 = 0
    local shadow = Instance.new("ImageLabel")
    shadow.Image             = "rbxassetid://8992230677"
    shadow.ScaleType         = Enum.ScaleType.Slice
    shadow.SliceCenter       = Rect.new(99, 99, 99, 99)
    shadow.AnchorPoint       = Vector2.new(0.5, 0.5)
    shadow.Size              = UDim2.new(1, 140, 1, 130)
    shadow.Position          = UDim2.new(0.5, 0, 0.5, 0)
    shadow.BackgroundTransparency = 1
    shadow.ImageColor3       = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.55
    shadow.Name              = "Shadow"
    shadow.ZIndex            = 0
    shadow.Parent            = acrylicFrame
    local tint = Instance.new("ImageLabel")
    tint.Image              = "rbxassetid://9968344105"
    tint.ImageTransparency  = 0.65
    tint.ImageColor3        = Color3.fromRGB(20, 20, 30)
    tint.ScaleType          = Enum.ScaleType.Tile
    tint.TileSize           = UDim2.new(0, 128, 0, 128)
    tint.Size               = UDim2.fromScale(1, 1)
    tint.BackgroundTransparency = 1
    tint.Name               = "Tint"
    tint.ZIndex             = 0
    tint.Parent             = acrylicFrame
    local noise = Instance.new("ImageLabel")
    noise.Image             = "rbxassetid://9968344227"
    noise.ImageTransparency = 0.60
    noise.ScaleType         = Enum.ScaleType.Tile
    noise.TileSize          = UDim2.new(0, 128, 0, 128)
    noise.Size              = UDim2.fromScale(1, 1)
    noise.BackgroundTransparency = 1
    noise.Name              = "Noise"
    noise.ZIndex            = 0
    noise.Parent            = acrylicFrame
    local highlight = Instance.new("Frame")
    highlight.Name               = "GlassHighlight"
    highlight.Size               = UDim2.new(1, 0, 0, 1)
    highlight.Position           = UDim2.new(0, 0, 0, 0)
    highlight.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
    highlight.BackgroundTransparency = 0.7
    highlight.BorderSizePixel    = 0
    highlight.ZIndex             = 1
    highlight.Parent             = acrylicFrame
    acrylicFrame.Parent = parentFrame
    local function setVisible(v)
        pcall(function() part.Transparency = v and 0.98 or 1 end)
        acrylicFrame.Visible = v
    end
    return {
        Frame      = acrylicFrame,
        Part       = part,
        SetVisible = setVisible,
        Destroy    = function()
            pcall(function() part:Destroy() end)
            pcall(function() acrylicFrame:Destroy() end)
        end,
    }
end
