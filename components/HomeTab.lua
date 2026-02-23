-- ╔══════════════════════════════════════════════════════╗
-- ║           HOME TAB - Sistema de Changelog           ║
-- ║     Modular, escalável e fiel ao design original    ║
-- ╚══════════════════════════════════════════════════════╝

local HomeTab = {}
HomeTab.__index = HomeTab

-- ════════════════════════════════════════════════════════
--   CONFIGURAÇÃO DE CORES (Importadas do tema original)
-- ════════════════════════════════════════════════════════
local THEME = {
    WindowBg      = Color3.fromRGB(28,  28,  28),
    Primary       = Color3.fromRGB(207, 100, 54),
    PrimaryHover  = Color3.fromRGB(224, 120, 72),
    TextPrimary   = Color3.fromRGB(232, 232, 232),
    TextSecondary = Color3.fromRGB(148, 148, 148),
    TextMuted     = Color3.fromRGB(85,  85,  85),
    Border        = Color3.fromRGB(55,  55,  55),
    Surface       = Color3.fromRGB(40,  40,  40),
    SurfaceHover  = Color3.fromRGB(50,  50,  50),
    Success       = Color3.fromRGB(52,  168, 83),
    Warning       = Color3.fromRGB(251, 188, 4),
    Error         = Color3.fromRGB(220, 53,  69),
    Info          = Color3.fromRGB(66,  133, 244),
    ScrollBar     = Color3.fromRGB(68,  68,  68),
    IconTint      = Color3.fromRGB(148, 148, 148),
}

-- ════════════════════════════════════════════════════════
--   HELPERS PARA CRIAÇÃO DE ELEMENTOS
-- ════════════════════════════════════════════════════════

-- Cria uma instância com propriedades
local function inst(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    return o
end

-- Adiciona cantos arredondados
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end

-- Adiciona stroke (borda)
local function mkStroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color     = col   or THEME.Border
    s.Thickness = thick or 1
    s.Parent    = p
    return s
end

-- Adiciona padding
local function mkPad(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 8)
    u.PaddingRight  = UDim.new(0, r or 8)
    u.PaddingBottom = UDim.new(0, b or 8)
    u.PaddingLeft   = UDim.new(0, l or 8)
    u.Parent = p
    return u
end

-- Animação suave
local TweenService = game:GetService("TweenService")
local function tw(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

-- Informações de animação
local FAST_TWEEN = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local MED_TWEEN  = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ════════════════════════════════════════════════════════
--   CHANGELOG ENTRY - Estrutura de um item do changelog
-- ════════════════════════════════════════════════════════

-- Cria um entry individual do changelog
-- @param parent: Frame pai onde o entry será adicionado
-- @param entry: Tabela com {Title, Description, Date, Type}
-- @param index: Posição do entry na lista
-- @param totalEntries: Total de entries para determinar se é o último
-- @return: Frame do entry criado
local function createChangelogEntry(parent, entry, index, totalEntries)
    local isFirst = (index == 1)
    local isLast  = (index == totalEntries)
    
    -- Container principal do entry
    local row = inst("Frame", {
        Size            = UDim2.new(1, 0, 0, 0),
        AutomaticSize   = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder     = index,
        ZIndex          = 6,
        Parent          = parent,
    })
    
    -- Linha vertical conectando os dots (timeline)
    inst("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(0, 5, 0, 14),
        BackgroundColor3 = THEME.Border,
        BorderSizePixel  = 0,
        Visible          = not isLast,  -- Não mostra na última entrada
        ZIndex           = 7,
        Parent           = row,
    })
    
    -- Dot (círculo) da timeline
    -- O primeiro dot é colorido (Primary), os outros são cinzas
    local dot = inst("Frame", {
        Size             = UDim2.new(0, 11, 0, 11),
        Position         = UDim2.new(0, 0, 0, 7),
        BackgroundColor3 = isFirst and THEME.Primary or THEME.Border,
        BorderSizePixel  = 0,
        ZIndex           = 8,
        Parent           = row,
    })
    corner(dot, 6)
    
    -- Glow no primeiro dot (efeito visual)
    if isFirst then
        local dotGlow = inst("Frame", {
            Size             = UDim2.new(0, 5, 0, 5),
            Position         = UDim2.new(0.5, -2, 0.5, -2),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.4,
            BorderSizePixel  = 0,
            ZIndex           = 9,
            Parent           = dot,
        })
        corner(dotGlow, 3)
    end
    
    -- Container do conteúdo do entry
    local entryContent = inst("Frame", {
        Size          = UDim2.new(1, -24, 0, 0),
        Position      = UDim2.new(0, 22, 0, 2),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex        = 7,
        Parent        = row,
    })
    inst("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 2),
        Parent    = entryContent
    })
    
    -- Linha com Título e Data
    local titleRow = inst("Frame", {
        Size            = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        LayoutOrder     = 1,
        ZIndex          = 7,
        Parent          = entryContent,
    })
    
    -- Título do changelog
    inst("TextLabel", {
        Size            = UDim2.new(0.55, 0, 1, 0),
        BackgroundTransparency = 1,
        Text            = entry.Title or "Sem título",
        TextColor3      = isFirst and THEME.TextPrimary or Color3.fromRGB(200, 200, 200),
        TextSize        = 12,
        Font            = isFirst and Enum.Font.GothamBold or Enum.Font.GothamMedium,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 8,
        Parent          = titleRow,
    })
    
    -- Data do changelog
    inst("TextLabel", {
        Size            = UDim2.new(0.45, 0, 1, 0),
        Position        = UDim2.new(0.55, 0, 0, 0),
        BackgroundTransparency = 1,
        Text            = entry.Date or "—",
        TextColor3      = isFirst and THEME.Primary or Color3.fromRGB(150, 150, 150),
        TextSize        = 10,
        Font            = Enum.Font.Gotham,
        TextXAlignment  = Enum.TextXAlignment.Right,
        ZIndex          = 8,
        Parent          = titleRow,
    })
    
    -- Descrição do changelog (se existir)
    if entry.Description and entry.Description ~= "" then
        inst("TextLabel", {
            Size            = UDim2.new(1, 0, 0, 0),
            AutomaticSize   = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text            = entry.Description,
            TextColor3      = Color3.fromRGB(185, 185, 185),
            TextSize        = 10,
            Font            = Enum.Font.Gotham,
            TextXAlignment  = Enum.TextXAlignment.Left,
            TextWrapped     = true,
            LayoutOrder     = 2,
            ZIndex          = 8,
            Parent          = entryContent,
        })
    end
    
    -- Espaçamento após o entry
    inst("Frame", {
        Size            = UDim2.new(1, 0, 0, 10),
        BackgroundTransparency = 1,
        LayoutOrder     = 3,
        ZIndex          = 6,
        Parent          = entryContent,
    })
    
    return row
end

-- ════════════════════════════════════════════════════════
--   CHANGELOG PANEL - Painel principal do changelog
-- ════════════════════════════════════════════════════════

-- Cria o painel do changelog com todos os entries
-- @param parent: Frame pai
-- @param entries: Array de entries {Title, Description, Date}
-- @return: ScrollingFrame do changelog
local function createChangelogPanel(parent, entries)
    -- Container do changelog
    local clPanel = inst("ScrollingFrame", {
        Size                 = UDim2.new(0.6, -4, 1, 0),
        BackgroundColor3     = Color3.fromRGB(30, 30, 30),
        BorderSizePixel      = 0,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = THEME.ScrollBar,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        LayoutOrder          = 1,
        ZIndex               = 5,
        Parent               = parent,
    })
    corner(clPanel, 7)
    mkStroke(clPanel, Color3.fromRGB(70, 70, 70), 1)
    
    -- Inner frame com padding
    local clInner = inst("Frame", {
        Size          = UDim2.new(1, -8, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex        = 6,
        Parent        = clPanel,
    })
    mkPad(clInner, 10, 10, 10, 14)
    inst("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 0),
        Parent    = clInner,
    })
    
    -- Header do changelog
    local clHdr = inst("Frame", {
        Size            = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder     = 0,
        ZIndex          = 6,
        Parent          = clInner,
    })
    
    -- Ícone do header
    inst("ImageLabel", {
        Size            = UDim2.new(0, 13, 0, 13),
        Position        = UDim2.new(0, 0, 0.5, -6),
        BackgroundTransparency = 1,
        Image           = "rbxasset://textures/Cursor.png",
        ImageColor3     = THEME.Primary,
        ScaleType       = Enum.ScaleType.Fit,
        ZIndex          = 7,
        Parent          = clHdr,
    })
    
    -- Título do header
    inst("TextLabel", {
        Size            = UDim2.new(1, -20, 1, 0),
        Position        = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text            = "Changelog",
        TextColor3      = THEME.TextPrimary,
        TextSize        = 13,
        Font            = Enum.Font.GothamBold,
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 7,
        Parent          = clHdr,
    })
    
    -- Renderiza cada entry do changelog
    for i, entry in ipairs(entries) do
        createChangelogEntry(clInner, entry, i, #entries)
    end
    
    return clPanel
end

-- ════════════════════════════════════════════════════════
--   CHANGELOG MANAGER - Gerenciador de changelog
-- ════════════════════════════════════════════════════════

-- Cria um novo gerenciador de changelog
-- @param initialEntries: Array inicial de entries
-- @return: Objeto com métodos para gerenciar o changelog
function HomeTab.createChangelogManager(initialEntries)
    local manager = {
        entries = initialEntries or {},
        panel = nil,
        inner = nil,
    }
    
    -- Adiciona um novo entry ao changelog
    -- @param title: Título do entry
    -- @param description: Descrição (opcional)
    -- @param date: Data (opcional)
    function manager:addEntry(title, description, date)
        table.insert(self.entries, 1, {
            Title = title,
            Description = description or "",
            Date = date or os.date("%d/%m/%Y"),
        })
        if self.panel then self:refresh() end
    end
    
    -- Remove um entry pelo índice
    -- @param index: Índice do entry a remover
    function manager:removeEntry(index)
        table.remove(self.entries, index)
        if self.panel then self:refresh() end
    end
    
    -- Atualiza um entry existente
    -- @param index: Índice do entry
    -- @param newData: Novos dados {Title, Description, Date}
    function manager:updateEntry(index, newData)
        if self.entries[index] then
            self.entries[index] = newData
            if self.panel then self:refresh() end
        end
    end
    
    -- Limpa todos os entries
    function manager:clear()
        self.entries = {}
        if self.panel then self:refresh() end
    end
    
    -- Retorna todos os entries
    function manager:getEntries()
        return self.entries
    end
    
    -- Atualiza a visualização do changelog
    function manager:refresh()
        if not self.inner then return end
        -- Remove todos os entries antigos (mantém o header)
        for _, child in ipairs(self.inner:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
                if child.LayoutOrder > 0 then child:Destroy() end
            end
        end
        -- Renderiza os novos entries
        for i, entry in ipairs(self.entries) do
            createChangelogEntry(self.inner, entry, i, #self.entries)
        end
    end
    
    return manager
end

return HomeTab
