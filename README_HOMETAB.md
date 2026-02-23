# 🏠 Home Tab - Sistema de Changelog Customizável

Uma implementação modular, escalável e elegante de uma Home Tab com sistema de changelog para a biblioteca ClaudeUI.

## ✨ Características

- 🎨 **Design Fiel ao Original** - Cores, animações e tipografia idênticas ao ClaudeUI
- 📝 **Changelog Customizável** - Adicione, remova e atualize entries em tempo real
- 🔄 **Modular e Escalável** - Fácil de estender e personalizar
- ⚡ **Animações Suaves** - Transições elegantes com TweenService
- 📱 **Responsivo** - Adapta-se a diferentes resoluções
- 📚 **Bem Documentado** - Documentação completa e exemplos práticos

## 📁 Estrutura de Arquivos

```
projeto/
├── components/
│   ├── HomeTab.lua                 # Componente principal (modular)
│   ├── Button.lua
│   ├── Dialog.lua
│   └── ...outros componentes
├── HomeTabIntegration.lua          # Integração com ClaudeUI
├── ExampleHomeTab.lua              # Exemplos práticos de uso
├── HOMETAB_DOCUMENTATION.md        # Documentação detalhada
├── README_HOMETAB.md               # Este arquivo
└── OriginalOne-FileUI.lua          # ClaudeUI original
```

## 🚀 Início Rápido

### 1. Importar o Módulo

```lua
local HomeTab = require(script.Parent:WaitForChild("components"):WaitForChild("HomeTab"))
```

### 2. Criar um Changelog Manager

```lua
local changelogManager = HomeTab.createChangelogManager({
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
})
```

### 3. Manipular o Changelog

```lua
-- Adicionar um novo entry
changelogManager:addEntry("Nova Feature", "Descrição", "22/02/2026")

-- Remover um entry
changelogManager:removeEntry(1)

-- Atualizar um entry
changelogManager:updateEntry(1, {
    Title = "Título Atualizado",
    Description = "Nova descrição",
    Date = "22/02/2026"
})

-- Obter todos os entries
local entries = changelogManager:getEntries()
```

## 📖 Documentação Completa

Para documentação detalhada, consulte [HOMETAB_DOCUMENTATION.md](HOMETAB_DOCUMENTATION.md)

### Tópicos Cobertos

- 🎨 Design e Estilo
- 📦 Estrutura de Arquivos
- 🚀 Como Usar
- 📝 Estrutura de um Entry
- 🎯 Funcionalidades Detalhadas
- 🎨 Customização
- 🔧 Integração com ClaudeUI
- 📊 Exemplo Completo
- 🐛 Troubleshooting
- 📚 Referência de API
- 🎓 Boas Práticas

## 💡 Exemplos de Uso

### Exemplo 1: Changelog Simples

```lua
local changelogManager = HomeTab.createChangelogManager({
    {Title = "Update 1", Date = "22/02/2026"},
    {Title = "Update 2", Date = "20/02/2026"},
})
```

### Exemplo 2: Changelog com Descrições

```lua
local changelogManager = HomeTab.createChangelogManager({
    {
        Title = "v2.0.0 - Lançamento Oficial",
        Description = "Primeira versão estável com suporte completo a componentes interativos.",
        Date = "22/02/2026"
    },
    {
        Title = "v1.5.0 - Beta",
        Description = "Versão beta com funcionalidades principais.",
        Date = "20/02/2026"
    },
})
```

### Exemplo 3: Adicionar Entries Dinamicamente

```lua
-- Adicionar um novo entry
changelogManager:addEntry(
    "v2.1.0 - Novas Animações",
    "Transições mais suaves e efeitos visuais aprimorados.",
    os.date("%d/%m/%Y")
)

-- Adicionar outro entry
changelogManager:addEntry(
    "v2.2.0 - Sistema de Temas",
    "Suporte a múltiplos temas customizáveis."
)
```

### Exemplo 4: Atualizar Entries

```lua
-- Atualizar o primeiro entry
changelogManager:updateEntry(1, {
    Title = "v2.2.0 - Sistema de Temas [IMPORTANTE]",
    Description = "Suporte a múltiplos temas customizáveis com sincronização em tempo real.",
    Date = "22/02/2026"
})
```

### Exemplo 5: Remover Entries

```lua
-- Remover o primeiro entry
changelogManager:removeEntry(1)

-- Remover o último entry
local entries = changelogManager:getEntries()
changelogManager:removeEntry(#entries)
```

### Exemplo 6: Consultar Entries

```lua
-- Obter todos os entries
local allEntries = changelogManager:getEntries()

-- Listar todos
for i, entry in ipairs(allEntries) do
    print(i .. ". " .. entry.Title .. " (" .. entry.Date .. ")")
end

-- Buscar um entry específico
for i, entry in ipairs(allEntries) do
    if entry.Title:find("Notificações") then
        print("Encontrado: " .. entry.Title)
    end
end
```

### Exemplo 7: Limpar Changelog

```lua
-- Remover todos os entries
changelogManager:clear()

-- Restaurar com novos entries
changelogManager:addEntry("Nova Update", "Descrição", "22/02/2026")
```

## 🎨 Customização

### Alterar Cores

Edite a tabela `THEME` em `components/HomeTab.lua`:

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

Edite as propriedades `Font` e `TextSize` nas funções de criação de elementos.

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

-- Manipular o changelog
changelogManager:addEntry("Nova Update", "Descrição", "22/02/2026")
```

## 📊 Estrutura de um Entry

```lua
{
    Title = "Título da Atualização",           -- Obrigatório
    Description = "Descrição detalhada",       -- Opcional
    Date = "22/02/2026"                        -- Opcional (padrão: data atual)
}
```

## 🎯 API Reference

### HomeTab.createChangelogManager(initialEntries)

Cria um novo gerenciador de changelog.

**Retorna:** Objeto com os seguintes métodos:

| Método | Descrição |
|--------|-----------|
| `addEntry(title, description, date)` | Adiciona um novo entry |
| `removeEntry(index)` | Remove um entry pelo índice |
| `updateEntry(index, newData)` | Atualiza um entry existente |
| `getEntries()` | Retorna todos os entries |
| `clear()` | Remove todos os entries |
| `refresh()` | Atualiza a visualização |

## 🎓 Boas Práticas

1. **Sempre forneça um título** - O título é o elemento mais importante
2. **Use datas consistentes** - Mantenha o formato "DD/MM/YYYY"
3. **Descrições concisas** - Mantenha as descrições claras e objetivas
4. **Atualize regularmente** - Adicione novos entries conforme necessário
5. **Teste em diferentes resoluções** - Certifique-se de que funciona em todos os tamanhos

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

## 📚 Arquivos Inclusos

| Arquivo | Descrição |
|---------|-----------|
| `components/HomeTab.lua` | Componente principal com toda a lógica |
| `HomeTabIntegration.lua` | Exemplo de integração com ClaudeUI |
| `ExampleHomeTab.lua` | Exemplos práticos de uso |
| `HOMETAB_DOCUMENTATION.md` | Documentação detalhada |
| `README_HOMETAB.md` | Este arquivo |

## 🔄 Fluxo de Trabalho Típico

```
1. Importar HomeTab
   ↓
2. Criar ChangelogManager com entries iniciais
   ↓
3. Adicionar/Remover/Atualizar entries conforme necessário
   ↓
4. Consultar entries quando necessário
   ↓
5. Limpar ou restaurar dados conforme necessário
```

## 💻 Requisitos

- Roblox Studio ou Executor Lua
- Acesso a `TweenService`
- Acesso a `Instance.new()`
- Suporte a Lua 5.1+

## 📝 Notas Importantes

- O primeiro entry é sempre destacado (colorido)
- As datas são opcionais (padrão: data atual)
- As descrições suportam quebras de linha (`\n`)
- O changelog é renderizado em ordem (primeiro = topo)
- As animações são suaves e responsivas

## 🎉 Conclusão

A Home Tab é um componente completo e pronto para uso que oferece uma forma elegante e modular de gerenciar um changelog. Com sua API simples e bem documentada, é fácil integrar e customizar conforme necessário.

Para mais informações, consulte a [documentação completa](HOMETAB_DOCUMENTATION.md) ou os [exemplos práticos](ExampleHomeTab.lua).

---

**Versão:** 1.0.0  
**Última atualização:** 22/02/2026  
**Autor:** ClaudeUI Team
