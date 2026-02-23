local Theme = Import("core/Theme")
local Utils = Import("core/Utils")
local TweenController = Import("animations/TweenController")

local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkPad = Utils.mkPad
local mkIcon = Utils.mkIcon
local iconAsset = Utils.iconAsset
local tw = TweenController.tw
local fast = TweenController.fast
local med = TweenController.med

local T = Theme

local Dropdown = {}

function Dropdown.Create(parent, label, items, callback, opts)
    opts = opts or {}
    local selected = opts.Default or items[1] or ""
    local open     = false

    local HDR_H  = 36
    local ITEM_H = 32
    local MAX_VIS = math.min(#items, 6)
    local LIST_H  = MAX_VIS * ITEM_H + 8

    local container = inst("Frame", {
        Size             = UDim2.new(1, 0, 0, HDR_H),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        LayoutOrder      = opts.Order or 0,
        ZIndex           = 4,
        Parent           = parent,
    })
    corner(container, 5)
    local stroke = mkStroke(container, T.Border, 1)

    local chevron = inst("ImageLabel", {
        Size               = UDim2.new(0, 14, 0, 14),
        AnchorPoint        = Vector2.new(1, 0.5),
        Position           = UDim2.new(1, -10, 0, HDR_H / 2),
        BackgroundTransparency = 1,
        Image              = iconAsset("chevron-down") or "",
        ImageColor3        = Color3.fromRGB(255, 255, 255),
        ScaleType          = Enum.ScaleType.Fit,
        ZIndex             = 7,
        Parent             = container,
    })

    local iconW = 0
    if opts.Icon then
        local ico = mkIcon(container, opts.Icon, 14, Color3.fromRGB(255, 255, 255), 7,
            Vector2.new(0, 0.5), UDim2.new(0, 10, 0, HDR_H / 2))
        if ico then iconW = 10 + 14 + 6 end
    end
    local LEFT  = (iconW > 0 and iconW or 10)
    local RIGHT = 26

    local labelLbl = inst("TextLabel", {
        Size                  = UDim2.new(1, -(LEFT + RIGHT), 0, 14),
        Position              = UDim2.new(0, LEFT, 0, 5),
        BackgroundTransparency= 1,
        Text                  = label,
        TextColor3            = Color3.fromRGB(225, 225, 225),
        TextSize              = 12,
        Font                  = Enum.Font.GothamMedium,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextTruncate          = Enum.TextTruncate.AtEnd,
        ZIndex                = 7,
        Parent                = container,
    })
    local selLbl = inst("TextLabel", {
        Size                  = UDim2.new(1, -(LEFT + RIGHT), 0, 12),
        Position              = UDim2.new(0, LEFT, 0, 21),
        BackgroundTransparency= 1,
        Text                  = selected,
        TextColor3            = Color3.fromRGB(100, 100, 100),
        TextSize              = 10,
        Font                  = Enum.Font.Gotham,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextTruncate          = Enum.TextTruncate.AtEnd,
        ZIndex                = 7,
        Parent                = container,
    })

    local hdrBtn = inst("TextButton", {
        Size                  = UDim2.new(1, 0, 0, HDR_H),
        BackgroundTransparency= 1,
        Text                  = "",
        AutoButtonColor       = false,
        ZIndex                = 9,
        Parent                = container,
    })
    local divider = inst("Frame", {
        Size                   = UDim2.new(1, -20, 0, 1),
        Position               = UDim2.new(0, 10, 0, HDR_H),
        BackgroundColor3       = T.Border,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ZIndex                 = 5,
        Parent                 = container,
    })

    local scrollList = inst("ScrollingFrame", {
        Size                 = UDim2.new(1, 0, 0, LIST_H),
        Position             = UDim2.new(0, 0, 0, HDR_H + 1),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = T.ScrollBar,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        ScrollingDirection   = Enum.ScrollingDirection.Y,
        ZIndex               = 5,
        Parent               = container,
    })
    mkPad(scrollList, 4, 6, 4, 6)
    local listLayout = inst("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 3),
        Parent    = scrollList,
    })
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    local itemBtns = {}
    local function setActive(ib, on)
        tw(ib, fast, {
            BackgroundTransparency = on and 0 or 1,
            BackgroundColor3       = on and Color3.fromRGB(50, 24, 12) or T.SurfaceHover,
        })
        local lbl = ib:FindFirstChild("ItemLabel")
        if lbl then
            tw(lbl, fast, { TextColor3 = on and T.Primary or T.TextSecondary })
            lbl.Font = on and Enum.Font.GothamMedium or Enum.Font.Gotham
        end
        local bar = ib:FindFirstChild("AccentBar")
        if bar then
            tw(bar, fast, {
                Size = UDim2.new(0, 3, 0, on and 14 or 0),
                BackgroundTransparency = on and 0 or 1,
            })
        end
    end

    local function doClose()
        open = false
        tw(container, med,  { Size = UDim2.new(1, 0, 0, HDR_H) })
        tw(stroke,    fast, { Color = T.Border })
        tw(divider,   fast, { BackgroundTransparency = 1 })
        tw(labelLbl,  fast, { TextColor3 = Color3.fromRGB(225, 225, 225) })
        tw(chevron,   med,  { Rotation = 0 })
    end
    local function doOpen()
        open = true
        tw(container, med,  { Size = UDim2.new(1, 0, 0, HDR_H + 1 + LIST_H) })
        tw(stroke,    fast, { Color = T.BorderFocus })
        tw(divider,   fast, { BackgroundTransparency = 0 })
        tw(labelLbl,  fast, { TextColor3 = T.Primary })
        tw(chevron,   med,  { Rotation = 180 })
    end

    for i, item in ipairs(items) do
        local isSel = (item == selected)
        local ib = inst("TextButton", {
            Name                   = "Item_" .. i,
            Size                   = UDim2.new(1, 0, 0, ITEM_H),
            BackgroundColor3       = isSel and Color3.fromRGB(50, 24, 12) or T.SurfaceHover,
            BackgroundTransparency = isSel and 0 or 1,
            Text                   = "",
            BorderSizePixel        = 0,
            LayoutOrder            = i,
            AutoButtonColor        = false,
            ZIndex                 = 6,
            Parent                 = scrollList,
        })
        corner(ib, 4)
        local accentBar = inst("Frame", {
            Name             = "AccentBar",
            Size             = UDim2.new(0, 3, 0, isSel and 14 or 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = T.Primary,
            BackgroundTransparency = isSel and 0 or 1,
            BorderSizePixel  = 0,
            ZIndex           = 7,
            Parent           = ib,
        })
        corner(accentBar, 2)
        inst("TextLabel", {
            Name                  = "ItemLabel",
            Size                  = UDim2.new(1, -20, 1, 0),
            Position              = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency= 1,
            Text                  = item,
            TextColor3            = isSel and T.Primary or T.TextSecondary,
            TextSize              = 12,
            Font                  = isSel and Enum.Font.GothamMedium or Enum.Font.Gotham,
            TextXAlignment        = Enum.TextXAlignment.Left,
            TextTruncate          = Enum.TextTruncate.AtEnd,
            ZIndex                = 7,
            Parent                = ib,
        })
        itemBtns[item] = ib
        ib.MouseEnter:Connect(function()
            if item ~= selected then
                tw(ib, fast, { BackgroundTransparency = 0, BackgroundColor3 = T.SurfaceHover })
                local lbl = ib:FindFirstChild("ItemLabel")
                if lbl then tw(lbl, fast, { TextColor3 = T.TextPrimary }) end
            end
        end)
        ib.MouseLeave:Connect(function()
            if item ~= selected then
                tw(ib, fast, { BackgroundTransparency = 1 })
                local lbl = ib:FindFirstChild("ItemLabel")
                if lbl then tw(lbl, fast, { TextColor3 = T.TextSecondary }) end
            end
        end)
        ib.MouseButton1Down:Connect(function()
            tw(ib, fast, { BackgroundColor3 = T.SurfaceActive, BackgroundTransparency = 0 })
        end)
        ib.MouseButton1Click:Connect(function()
            if itemBtns[selected] then setActive(itemBtns[selected], false) end
            selected    = item
            selLbl.Text = item
            setActive(ib, true)
            doClose()
            if callback then callback(selected) end
        end)
    end

    hdrBtn.MouseButton1Click:Connect(function()
        if open then doClose() else doOpen() end
    end)
    hdrBtn.MouseEnter:Connect(function()
        if not open then tw(container, fast, { BackgroundColor3 = T.SurfaceHover }) end
    end)
    hdrBtn.MouseLeave:Connect(function()
        if not open then tw(container, fast, { BackgroundColor3 = T.Surface }) end
    end)

    return {
        Get = function() return selected end,
        Set = function(v)
            if itemBtns[selected] then setActive(itemBtns[selected], false) end
            selected    = v
            selLbl.Text = v
            if itemBtns[v] then setActive(itemBtns[v], true) end
        end,
    }
end

return Dropdown