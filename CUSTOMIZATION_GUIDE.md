# 🎨 Guia de Customização Avançada - Home Tab

Um guia completo para customizar e estender a Home Tab de acordo com suas necessidades.

## 📑 Índice

1. [Customização de Cores](#customização-de-cores)
2. [Customização de Animações](#customização-de-animações)
3. [Customização de Tipografia](#customização-de-tipografia)
4. [Customização de Layout](#customização-de-layout)
5. [Extensão de Funcionalidades](#extensão-de-funcionalidades)
6. [Temas Personalizados](#temas-personalizados)
7. [Integração com Sistemas Externos](#integração-com-sistemas-externos)

---

## 🎨 Customização de Cores

### Alterar Paleta de Cores Global

Edite a tabela `THEME` em `components/HomeTab.lua`:

```lua
local THEME = {
    WindowBg      = Color3.fromRGB(28,  28,  28),
    Primary       = Color3.fromRGB(207, 100, 54),   -- Cor principal
    PrimaryHover  = Color3.fromRGB(224, 120, 72),   -- Cor ao passar mouse
    TextPrimary   = Color3.fromRGB(232, 232, 232),  -- Texto principal
    TextSecondary = Color3.fromRGB(148, 148, 148),  -- Texto secundário
    TextMuted     = Color3.fromRGB(85,  85,  85),   -- Texto desativado
    Border        = Color3.fromRGB(55,  55,  55),   -- Bordas
    Surface       = Color3.fromRGB(40,  40,  40),   -- Superfícies
    SurfaceHover  = Color3.fromRGB(50,  50,  50),   -- Superfícies ao hover
    Success       = Color3.fromRGB(52,  168, 83),   -- Cor de sucesso
    Warning       = Color3.fromRGB(251, 188, 4),    -- Cor de aviso
    Error         = Color3.fromRGB(220, 53,  69),   -- Cor de erro
    Info          = Color3.fromRGB(66,  133, 244),  -- Cor de informação
    ScrollBar     = Color3.fromRGB(68,  68,  68),   -- Barra de scroll
    IconTint      = Color3.fromRGB(148, 148, 148),  -- Cor dos ícones
}
```

### Criar Temas Predefinidos

```lua
-- Tema Escuro (padrão)
local THEME_DARK = {
    Primary       = Color3.fromRGB(207, 100, 54),
    TextPrimary   = Color3.fromRGB(232, 232, 232),
    Border        = Color3.fromRGB(55,  55,  55),
    -- ... outras cores
}

-- Tema Claro
local THEME_LIGHT = {
    Primary       = Color3.fromRGB(0,   120, 215),
    TextPrimary   = Color3.fromRGB(32,  32,  32),
    Border        = Color3.fromRGB(200, 200, 200),
    -- ... outras cores
}

-- Tema Neon
local THEME_NEON = {
    Primary       = Color3.fromRGB(0,   255, 255),
    TextPrimary   = Color3.fromRGB(255, 255, 255),
    Border        = Color3.fromRGB(0,   255, 255),
    -- ... outras cores
}

-- Função para aplicar tema
local function applyTheme(themeName)
    local themes = {
        dark = THEME_DARK,
        light = THEME_LIGHT,
        neon = THEME_NEON,
    }
    THEME = themes[themeName] or THEME_DARK
end
```

### Cores Dinâmicas

```lua
-- Gerar cor baseada em hash
local function hashToColor(str)
    local hash = 0
    for i = 1, #str do
        hash = (hash * 31 + string.byte(str, i)) % 256
    end
    return Color3.fromRGB(hash, (hash * 7) % 256, (hash * 13) % 256)
end

-- Usar em entries
local entryColor = hashToColor(entry.Title)
```

---

## ⚡ Customização de Animações

### Alterar Velocidade de Animações

```lua
-- Animações mais rápidas
local FAST_TWEEN = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local MED_TWEEN  = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Animações mais lentas
local FAST_TWEEN = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local MED_TWEEN  = TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
```

### Alterar Estilo de Easing

```lua
-- Easing suave (padrão)
TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Easing elástico
TweenInfo.new(0.12, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)

-- Easing de volta
TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- Easing de bounce
TweenInfo.new(0.12, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

-- Easing linear
TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
```

### Adicionar Animações Customizadas

```lua
-- Animação de entrada
local function animateEntryIn(entry)
    entry.BackgroundTransparency = 1
    entry.Position = UDim2.new(entry.Position.X.Scale, entry.Position.X.Offset - 20, 
                               entry.Position.Y.Scale, entry.Position.Y.Offset)
    
    tw(entry, MED_TWEEN, {
        BackgroundTransparency = 0,
        Position = UDim2.new(entry.Position.X.Scale, entry.Position.X.Offset + 20,
                            entry.Position.Y.Scale, entry.Position.Y.Offset)
    })
end

-- Animação de saída
local function animateEntryOut(entry)
    tw(entry, FAST_TWEEN, {
        BackgroundTransparency = 1,
        Position = UDim2.new(entry.Position.X.Scale, entry.Position.X.Offset - 20,
                            entry.Position.Y.Scale, entry.Position.Y.Offset)
    })
end
```

---

## 🔤 Customização de Tipografia

### Alterar Fontes

```lua
-- Fontes disponíveis no Roblox
local FONTS = {
    title = Enum.Font.GothamBold,
    subtitle = Enum.Font.GothamMedium,
    body = Enum.Font.Gotham,
    mono = Enum.Font.RobotoMono,
}

-- Usar em elementos
inst("TextLabel", {
    Font = FONTS.title,
    TextSize = 16,
    -- ...
})
```

### Alterar Tamanhos de Texto

```lua
local TEXT_SIZES = {
    h1 = 18,  -- Títulos principais
    h2 = 16,  -- Subtítulos
    h3 = 14,  -- Títulos de seção
    body = 12, -- Texto do corpo
    small = 10, -- Texto pequeno
    tiny = 8,  -- Texto muito pequeno
}
```

### Alterar Alinhamento de Texto

```lua
-- Alinhamento horizontal
TextXAlignment = Enum.TextXAlignment.Left    -- Esquerda
TextXAlignment = Enum.TextXAlignment.Center  -- Centro
TextXAlignment = Enum.TextXAlignment.Right   -- Direita

-- Alinhamento vertical
TextYAlignment = Enum.TextYAlignment.Top     -- Topo
TextYAlignment = Enum.TextYAlignment.Center  -- Centro
TextYAlignment = Enum.TextYAlignment.Bottom  -- Fundo
```

---

## 📐 Customização de Layout

### Alterar Tamanho do Changelog

```lua
-- Changelog mais largo
local clPanel = inst("ScrollingFrame", {
    Size = UDim2.new(0.75, -4, 1, 0),  -- 75% da largura
    -- ...
})

-- Changelog mais estreito
local clPanel = inst("ScrollingFrame", {
    Size = UDim2.new(0.45, -4, 1, 0),  -- 45% da largura
    -- ...
})
```

### Alterar Padding

```lua
-- Padding maior
mkPad(clInner, 20, 20, 20, 20)  -- 20px em todos os lados

-- Padding menor
mkPad(clInner, 5, 5, 5, 5)      -- 5px em todos os lados

-- Padding customizado
mkPad(clInner, 10, 20, 10, 20)  -- Top: 10, Right: 20, Bottom: 10, Left: 20
```

### Alterar Espaçamento entre Entries

```lua
-- Mais espaço entre entries
inst("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding   = UDim.new(0, 20),  -- 20px entre entries
    Parent    = clInner,
})

-- Menos espaço entre entries
inst("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding   = UDim.new(0, 5),   -- 5px entre entries
    Parent    = clInner,
})
```

### Alterar Cantos Arredondados

```lua
-- Cantos mais arredondados
corner(clPanel, 12)  -- 12px

-- Cantos menos arredondados
corner(clPanel, 3)   -- 3px

-- Sem cantos arredondados
corner(clPanel, 0)   -- 0px
```

---

## 🔧 Extensão de Funcionalidades

### Adicionar Filtro de Entries

```lua
-- Filtrar entries por data
function changelogManager:filterByDate(startDate, endDate)
    local filtered = {}
    for _, entry in ipairs(self.entries) do
        if entry.Date >= startDate and entry.Date <= endDate then
            table.insert(filtered, entry)
        end
    end
    return filtered
end

-- Usar
local recentEntries = changelogManager:filterByDate("20/02/2026", "22/02/2026")
```

### Adicionar Busca de Entries

```lua
-- Buscar entries por título
function changelogManager:search(query)
    local results = {}
    for _, entry in ipairs(self.entries) do
        if entry.Title:lower():find(query:lower()) then
            table.insert(results, entry)
        end
    end
    return results
end

-- Usar
local results = changelogManager:search("Notificações")
```

### Adicionar Ordenação Customizada

```lua
-- Ordenar por data (mais recente primeiro)
function changelogManager:sortByDate()
    table.sort(self.entries, function(a, b)
        return a.Date > b.Date
    end)
    self:refresh()
end

-- Ordenar por título (alfabético)
function changelogManager:sortByTitle()
    table.sort(self.entries, function(a, b)
        return a.Title < b.Title
    end)
    self:refresh()
end
```

### Adicionar Exportação de Dados

```lua
-- Exportar como JSON
function changelogManager:exportJSON()
    local json = "["
    for i, entry in ipairs(self.entries) do
        json = json .. '{"title":"' .. entry.Title .. '","date":"' .. entry.Date .. '"}'
        if i < #self.entries then json = json .. "," end
    end
    json = json .. "]"
    return json
end

-- Exportar como CSV
function changelogManager:exportCSV()
    local csv = "Title,Description,Date\n"
    for _, entry in ipairs(self.entries) do
        csv = csv .. entry.Title .. "," .. entry.Description .. "," .. entry.Date .. "\n"
    end
    return csv
end
```

---

## 🎭 Temas Personalizados

### Criar Sistema de Temas

```lua
local ThemeManager = {}

-- Definir temas
ThemeManager.themes = {
    default = {
        Primary = Color3.fromRGB(207, 100, 54),
        TextPrimary = Color3.fromRGB(232, 232, 232),
        -- ...
    },
    cyberpunk = {
        Primary = Color3.fromRGB(255, 0, 255),
        TextPrimary = Color3.fromRGB(0, 255, 255),
        -- ...
    },
    nature = {
        Primary = Color3.fromRGB(76, 175, 80),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        -- ...
    },
}

-- Aplicar tema
function ThemeManager:apply(themeName)
    local theme = self.themes[themeName]
    if theme then
        THEME = theme
        return true
    end
    return false
end

-- Criar tema customizado
function ThemeManager:create(name, colors)
    self.themes[name] = colors
end
```

### Tema com Gradiente

```lua
-- Adicionar gradiente ao background
local function addGradient(frame)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40)),
    })
    gradient.Rotation = 45
    gradient.Parent = frame
    return gradient
end
```

---

## 🔗 Integração com Sistemas Externos

### Integração com Banco de Dados

```lua
-- Carregar changelog do servidor
local function loadChangelogFromServer()
    local success, data = pcall(function()
        return game:HttpGet("https://seu-servidor.com/changelog")
    end)
    
    if success then
        local entries = game:GetService("HttpService"):JSONDecode(data)
        return entries
    end
    return {}
end

-- Usar
local entries = loadChangelogFromServer()
local changelogManager = HomeTab.createChangelogManager(entries)
```

### Integração com Discord

```lua
-- Enviar changelog para Discord
local function sendToDiscord(entry)
    local webhook = "https://discord.com/api/webhooks/seu-webhook"
    local message = {
        content = "**" .. entry.Title .. "**\n" .. entry.Description .. "\n*" .. entry.Date .. "*"
    }
    
    game:HttpGet(webhook, {
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode(message)
    })
end
```

### Integração com Analytics

```lua
-- Rastrear visualizações de changelog
local function trackView(entryTitle)
    local analytics = {
        event = "changelog_view",
        entry = entryTitle,
        timestamp = os.time(),
    }
    
    -- Enviar para servidor de analytics
    game:HttpGet("https://seu-analytics.com/track", {
        Method = "POST",
        Body = game:GetService("HttpService"):JSONEncode(analytics)
    })
end
```

---

## 📋 Checklist de Customização

- [ ] Cores customizadas
- [ ] Animações ajustadas
- [ ] Tipografia personalizada
- [ ] Layout modificado
- [ ] Funcionalidades estendidas
- [ ] Tema criado
- [ ] Integração com sistemas externos
- [ ] Testes realizados
- [ ] Documentação atualizada

---

## 🎓 Boas Práticas

1. **Sempre fazer backup** - Guarde uma cópia do arquivo original
2. **Testar mudanças** - Teste cada customização antes de usar em produção
3. **Documentar mudanças** - Mantenha registro das customizações realizadas
4. **Manter consistência** - Mantenha o design consistente em toda a aplicação
5. **Otimizar performance** - Evite customizações que possam impactar a performance

---

## 🐛 Troubleshooting

### Cores não aparecem corretamente

- Verifique se os valores RGB estão entre 0-255
- Limpe o cache do Roblox Studio
- Reinicie o Studio

### Animações não funcionam

- Verifique se TweenService está disponível
- Certifique-se de que os objetos não foram destruídos
- Verifique se as propriedades animadas existem

### Layout quebrado

- Verifique os valores de UDim2
- Certifique-se de que o padding está correto
- Teste em diferentes resoluções

---

**Última atualização:** 22/02/2026  
**Versão:** 1.0.0
