local Players = game:GetService("Players")
local Theme = Import("core/Theme")
local Utils = Import("core/Utils")
local TweenController = Import("animations/TweenController")

local T = Theme
local inst = Utils.inst
local corner = Utils.corner
local mkStroke = Utils.mkStroke
local mkPad = Utils.mkPad
local mkIcon = Utils.mkIcon
local tw = TweenController.tw
local fast = TweenController.fast

local DialogModule = {}
local currentDialogGui = nil

function DialogModule.Show(config, callback)
    config = config or {}
    local title    = config.Title       or "Dialog"
    local desc     = config.Description or ""
    local iconName = config.Icon        or "info"
    local buttons  = config.Buttons     or { "Cancelar", "Confirmar" }
    local primary  = config.Primary     or #buttons

    local pGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Fecha qualquer dialog já aberto antes de criar um novo
    local existingDialog = pGui:FindFirstChild("ClaudeUI_Dialog")
    if existingDialog then existingDialog:Destroy() end

    -- ── ScreenGui + overlay ───────────────────────────────
    local overlayGui = inst("ScreenGui", {
        Name           = "ClaudeUI_Dialog",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = pGui,
    })
    currentDialogGui = overlayGui

    -- Botão invisível de fundo apenas para detectar clique fora do card
    local overlayBtn = inst("TextButton", {
        Size                  = UDim2.fromScale(1, 1),
        BackgroundTransparency= 1,
        Text                  = "",
        BorderSizePixel       = 0,
        ZIndex                = 201,
        Parent                = overlayGui,
    })

    -- ── Card central ──────────────────────────────────────
    local CARD_W = 360
    local card = inst("CanvasGroup", {
        Size              = UDim2.new(0, CARD_W, 0, 0),
        AnchorPoint       = Vector2.new(0.5, 0.5),
        Position          = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3  = Color3.fromRGB(30, 30, 30),
        BorderSizePixel   = 0,
        AutomaticSize     = Enum.AutomaticSize.Y,
        GroupTransparency = 1,
        ZIndex            = 202,
        Parent            = overlayGui,
    })
    corner(card, 12)
    mkStroke(card, Color3.fromRGB(60, 60, 60), 1)

    local cardInner = inst("Frame", {
        Size          = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex        = 202,
        Parent        = card,
    })
    mkPad(cardInner, 22, 22, 20, 22)
    inst("UIListLayout", {
        SortOrder           = Enum.SortOrder.LayoutOrder,
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding             = UDim.new(0, 10),
        Parent              = cardInner,
    })

    -- ── Ícone ─────────────────────────────────────────────
    local iconBg = inst("Frame", {
        Size             = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = T.Primary,
        BackgroundTransparency = 0.85,
        BorderSizePixel  = 0,
        LayoutOrder      = 1,
        ZIndex           = 203,
        Parent           = cardInner,
    })
    corner(iconBg, 8)
    mkStroke(iconBg, T.Primary, 1)
    mkIcon(iconBg, iconName, 18, T.Primary, 204,
        Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0))

    -- ── Título ────────────────────────────────────────────
    inst("TextLabel", {
        Size                  = UDim2.new(1, 0, 0, 0),
        AutomaticSize         = Enum.AutomaticSize.Y,
        BackgroundTransparency= 1,
        Text                  = title,
        TextColor3            = T.TextPrimary,
        TextSize              = 16,
        Font                  = Enum.Font.GothamBold,
        TextXAlignment        = Enum.TextXAlignment.Left,
        TextWrapped           = true,
        LayoutOrder           = 2,
        ZIndex                = 203,
        Parent                = cardInner,
    })

    -- ── Descrição ─────────────────────────────────────────
    if desc and desc ~= "" then
        inst("TextLabel", {
            Size                  = UDim2.new(1, 0, 0, 0),
            AutomaticSize         = Enum.AutomaticSize.Y,
            BackgroundTransparency= 1,
            Text                  = desc,
            TextColor3            = Color3.fromRGB(160, 160, 160),
            TextSize              = 12,
            Font                  = Enum.Font.Gotham,
            TextXAlignment        = Enum.TextXAlignment.Left,
            TextWrapped           = true,
            LayoutOrder           = 3,
            ZIndex                = 203,
            Parent                = cardInner,
        })
    end

    -- ── Divisória ─────────────────────────────────────────
    inst("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel  = 0,
        LayoutOrder      = 4,
        ZIndex           = 202,
        Parent           = cardInner,
    })

    -- ── Linha de botões ───────────────────────────────────
    local btnRow = inst("Frame", {
        Size            = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder     = 5,
        ZIndex          = 202,
        Parent          = cardInner,
    })
    inst("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        Padding             = UDim.new(0, 8),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = btnRow,
    })

    -- ── Animação de fechar ────────────────────────────────
    local dialogAnim = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local closing = false
    local function doClose(choice)
        if closing then return end
        closing = true
        tw(card, dialogAnim, { GroupTransparency = 1 })
        task.delay(0.22, function()
            if overlayGui and overlayGui.Parent then
                overlayGui:Destroy()
            end
            if currentDialogGui == overlayGui then currentDialogGui = nil end
            if callback then callback(choice) end
        end)
    end

    -- Fechar ao clicar fora do card
    overlayBtn.MouseButton1Click:Connect(function() doClose(0) end)

    -- ── Criar botões ──────────────────────────────────────
    for i, btnText in ipairs(buttons) do
        local isPrimary = (i == primary)
        local bgN = isPrimary and T.Primary              or Color3.fromRGB(45, 45, 45)
        local bgH = isPrimary and T.PrimaryHover         or Color3.fromRGB(58, 58, 58)

        local btn = inst("TextButton", {
            Size             = UDim2.new(0, 0, 1, 0),
            AutomaticSize    = Enum.AutomaticSize.X,
            BackgroundColor3 = bgN,
            Text             = "",
            BorderSizePixel  = 0,
            AutoButtonColor  = false,
            LayoutOrder      = i,
            ZIndex           = 204,
            Parent           = btnRow,
        })
        corner(btn, 6)
        if not isPrimary then
            mkStroke(btn, Color3.fromRGB(65, 65, 65), 1)
        end
        mkPad(btn, 0, 16, 0, 16)

        inst("TextLabel", {
            Size                  = UDim2.new(0, 0, 1, 0),
            AutomaticSize         = Enum.AutomaticSize.X,
            BackgroundTransparency= 1,
            Text                  = btnText,
            TextColor3            = isPrimary and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200),
            TextSize              = 13,
            Font                  = isPrimary and Enum.Font.GothamMedium or Enum.Font.Gotham,
            ZIndex                = 205,
            Parent                = btn,
        })

        btn.MouseEnter:Connect(function()    tw(btn, fast, { BackgroundColor3 = bgH }) end)
        btn.MouseLeave:Connect(function()    tw(btn, fast, { BackgroundColor3 = bgN }) end)
        btn.MouseButton1Down:Connect(function() tw(btn, fast, { BackgroundColor3 = T.SurfaceActive }) end)
        btn.MouseButton1Click:Connect(function() doClose(i) end)
    end

    -- ── Animação de entrada ───────────────────────────────
    tw(card, dialogAnim, { GroupTransparency = 0 })
end

function DialogModule.Close()
    local overlayGui = currentDialogGui
    if not overlayGui or not overlayGui.Parent then
        local pGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        overlayGui = pGui:FindFirstChild("ClaudeUI_Dialog")
    end
    if not overlayGui then return end

    local card = overlayGui:FindFirstChildWhichIsA("CanvasGroup")
    if card then
        local dialogAnim = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        tw(card, dialogAnim, { GroupTransparency = 1 })
    end

    task.delay(0.22, function()
        if overlayGui and overlayGui.Parent then
            overlayGui:Destroy()
        end
        currentDialogGui = nil
    end)
end

return DialogModule
