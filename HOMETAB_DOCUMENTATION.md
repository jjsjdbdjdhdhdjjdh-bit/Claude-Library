# Home Tab - Sistema de Changelog Customizável

## 📋 Visão Geral

A **Home Tab** é um componente modular e escalável que fornece uma interface elegante para exibir um changelog (histórico de atualizações) com design fiel ao estilo original do ClaudeUI.

### Características Principais

✅ **Design Fiel ao Original** - Cores, cantos arredondados, animações e tipografia idênticas  
✅ **Sistema de Changelog Customizável** - Adicione, remova e atualize entries em tempo real  
✅ **Modular e Escalável** - Fácil de estender e personalizar  
✅ **Timeline Visual** - Visualização elegante com dots conectados  
✅ **Responsivo** - Adapta-se a diferentes tamanhos de tela  

---

## 🎨 Design e Estilo

### Paleta de Cores

```lua
Primary       = Color3.fromRGB(207, 100, 54)   -- Laranja principal
TextPrimary   = Color3.fromRGB(232, 232, 232)  -- Texto principal
TextSecondary = Color3.fromRGB(148, 148, 148)  -- Texto secundário
Border        = Color3.fromRGB(55,  55,  55)   -- Bordas
Surface       = Color3.fromRGB(40,  40,  40)   -- Superfícies
```

### Elementos Visuais

- **Cantos Arredondados**: 6-8px para consistência
- **Animações**: Transições suaves de 0.12s (rápido) e 0.20s (médio)
- **Tipografia**: Gotham (Regular, Medium, Bold)
- **Ícones**: Lucide Icons com tint customizável

---

## 📦 Estrutura de Arquivos

```
components/
├── HomeTab.lua                 # Componente principal
├── ...outros componentes
HomeTabIntegration.lua          # Exemplo de integração
HOMETAB_DOCUMENTATION.md        # Esta documentação
```

---

## 🚀 Como Usar

### 1. Importar o Módulo

```lua
local HomeTab = require(script.Parent:WaitForChild("components"):WaitForChild("HomeTab"))
```

### 2. Criar um Changelog Manager

```lua
-- Define os entries do changelog
local entries = {
    {
        Title = "Primeira Atualização",
        Description = "Descrição da atualização",
        Date = "22/02/2026"
    },
    {
        Title = "Segunda Atualização",
        Description = "Mais detalhes aqui",
        Date = "20/02/2026"
    },
}

-- Cria o manager
local changelogManager = HomeTab.createChangelogManager(entries)
```

### 3. Manipular o Changelog

```lua
-- Adicionar um novo entry
changelogManager:addEntry(
    "Nova Feature",
    "Descrição da nova feature",
    "22/02/2026"
)

-- Remover um entry (por índice)
changelogManager:removeEntry(1)

-- Atualizar um entry
changelogManager:updateEntry(2, {
    Title = "Título Atualizado",
    Description = "Nova descrição",
    Date = "22/02/2026"
})

-- Obter todos os entries
local allEntries = changelogManager:getEntries()

-- Limpar todos os entries
changelogManager:clear()
```

---

## 📝 Estrutura de um Entry

Cada entry do changelog é uma tabela Lua com a seguinte estrutura:

```lua
{
    Title = "Título da Atualização",           -- Obrigatório
    Description = "Descrição detalhada",       -- Opcional
    Date = "22/02/2026"                        -- Opcional (padrão: data atual)
}
```

### Exemplos de Entries

```lua
-- Entry simples
{
    Title = "Bug Fix",
    Date = "22/02/2026"
}

-- Entry completo
{
    Title = "Nova Feature: Sistema de Notificações",
    Description = "Implementação de notificações em tempo real com suporte a diferentes tipos (info, warning, error).",
    Date = "22/02/2026"
}

-- Entry com descrição multilinha
{
    Title = "Refatoração de Código",
    Description = "Melhorias significativas na performance:\n• Redução de 40% no uso de memória\n• Otimização de renderização\n• Melhor responsividade",
    Date = "20/02/2026"
}
```

---

## 🎯 Funcionalidades Detalhadas

### Changelog Manager

O `ChangelogManager` é o objeto retornado por `createChangelogManager()` e fornece os seguintes métodos:

#### `addEntry(title, description, date)`

Adiciona um novo entry ao topo do changelog.

```lua
changelogManager:addEntry(
    "Nova Atualização",
    "Descrição da atualização",
    "22/02/2026"
)
```

**Parâmetros:**
- `title` (string): Título do entry
- `description` (string, opcional): Descrição detalhada
- `date` (string, opcional): Data no formato "DD/MM/YYYY"

---

#### `removeEntry(index)`

Remove um entry pelo índice.

```lua
changelogManager:removeEntry(1)  -- Remove o primeiro entry
```

**Parâmetros:**
- `index` (number): Índice do entry a remover

---

#### `updateEntry(index, newData)`

Atualiza um entry existente.

```lua
changelogManager:updateEntry(1, {
    Title = "Novo Título",
    Description = "Nova descrição",
    Date = "22/02/2026"
})
```

**Parâmetros:**
- `index` (number): Índice do entry
- `newData` (table): Novos dados do entry

---

#### `getEntries()`

Retorna um array com todos os entries.

```lua
local entries = changelogManager:getEntries()
for i, entry in ipairs(entries) do
    print(entry.Title)
end
```

---

#### `clear()`

Remove todos os entries do changelog.

```lua
changelogManager:clear()
```

---

#### `refresh()`

Atualiza a visualização do changelog (chamado automaticamente).

```lua
changelogManager:refresh()
```

---

## 🎨 Customização

### Alterar Cores

Para customizar as cores, edite a tabela `THEME` em `components/HomeTab.lua`:

```lua
local THEME = {
    Primary       = Color3.fromRGB(207, 100, 54),
    TextPrimary   = Color3.fromRGB(232, 232, 232),
    -- ... outras cores
}
```

### Alterar Animações

Modifique as constantes de tween:

```lua
local FAST_TWEEN = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local MED_TWEEN  = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
```

### Alterar Tipografia

Edite as propriedades `Font` e `TextSize` nas funções de criação de elementos:

```lua
inst("TextLabel", {
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    -- ...
})
```

---

## 🔧 Integração com ClaudeUI

### Método 1: Usar CreateHomeTab Original

```lua
local window = ClaudeUI.new({
    Title = "Minha App",
    Changelog = {
        {Title = "Update 1", Date = "22/02/2026"},
        {Title = "Update 2", Date = "20/02/2026"},
    }
})

window:CreateHomeTab({
    Changelog = {...},
    DiscordInvite = "seu-convite"
})
```

### Método 2: Usar CreateHomeTabAdvanced

```lua
local changelogManager = window:CreateHomeTabAdvanced({
    Changelog = {...}
})

-- Agora você pode manipular o changelog
changelogManager:addEntry("Nova Update", "Descrição", "22/02/2026")
```

---

## 📊 Exemplo Completo

```lua
local HomeTab = require(script.Parent:WaitForChild("components"):WaitForChild("HomeTab"))

-- 1. Definir entries iniciais
local initialEntries = {
    {
        Title = "Sistema de Changelog Implementado",
        Description = "Novo sistema modular para gerenciar atualizações.",
        Date = "22/02/2026"
    },
    {
        Title = "Melhorias na UI",
        Description = "Refinamento de animações e transições.",
        Date = "20/02/2026"
    },
}

-- 2. Criar o manager
local changelogManager = HomeTab.createChangelogManager(initialEntries)

-- 3. Adicionar novos entries
changelogManager:addEntry(
    "Nova Feature: Notificações",
    "Sistema de notificações em tempo real",
    os.date("%d/%m/%Y")
)

-- 4. Atualizar um entry
changelogManager:updateEntry(1, {
    Title = "Sistema de Changelog - Versão 2.0",
    Description = "Melhorias significativas na performance e usabilidade.",
    Date = "22/02/2026"
})

-- 5. Obter todos os entries
local allEntries = changelogManager:getEntries()
print("Total de entries:", #allEntries)

-- 6. Remover um entry
changelogManager:removeEntry(3)
```

---

## 🐛 Troubleshooting

### O changelog não aparece

- Verifique se o `HomeTab.lua` está no caminho correto
- Certifique-se de que o `createChangelogManager()` foi chamado
- Verifique se os entries têm pelo menos um `Title`

### As cores não estão corretas

- Verifique a tabela `THEME` em `HomeTab.lua`
- Certifique-se de que as cores RGB estão no intervalo 0-255
- Limpe o cache do Roblox Studio

### As animações não funcionam

- Verifique se `TweenService` está disponível
- Certifique-se de que os objetos não foram destruídos
- Verifique se as propriedades animadas existem

---

## 📚 Referência de API

### HomeTab.createChangelogManager(initialEntries)

Cria um novo gerenciador de changelog.

**Retorna:** Objeto com métodos para gerenciar o changelog

**Métodos:**
- `addEntry(title, description, date)` - Adiciona um entry
- `removeEntry(index)` - Remove um entry
- `updateEntry(index, newData)` - Atualiza um entry
- `getEntries()` - Retorna todos os entries
- `clear()` - Remove todos os entries
- `refresh()` - Atualiza a visualização

---

## 🎓 Boas Práticas

1. **Sempre forneça um título** - O título é o elemento mais importante
2. **Use datas consistentes** - Mantenha o formato "DD/MM/YYYY"
3. **Descrições concisas** - Mantenha as descrições claras e objetivas
4. **Atualize regularmente** - Adicione novos entries conforme necessário
5. **Teste em diferentes resoluções** - Certifique-se de que funciona em todos os tamanhos

---

## 📄 Licença

Este componente segue a mesma licença do projeto ClaudeUI.

---

## 🤝 Contribuições

Para contribuir com melhorias, siga o padrão de código estabelecido e mantenha a fidelidade ao design original.

---

**Última atualização:** 22/02/2026  
**Versão:** 1.0.0
