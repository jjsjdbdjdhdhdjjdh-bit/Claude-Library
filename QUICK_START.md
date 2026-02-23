# ⚡ Quick Start - Home Tab em 5 Minutos

Um guia super rápido para começar a usar a Home Tab.

---

## 🚀 Instalação (30 segundos)

1. Copie `components/HomeTab.lua` para sua pasta `components/`
2. Pronto! Você está pronto para usar.

---

## 💻 Código Mínimo (1 minuto)

```lua
-- Importar
local HomeTab = require(script.Parent:WaitForChild("components"):WaitForChild("HomeTab"))

-- Criar
local changelogManager = HomeTab.createChangelogManager({
    {Title = "Update 1", Date = "22/02/2026"},
    {Title = "Update 2", Date = "20/02/2026"},
})

-- Pronto!
```

---

## 📝 Adicionar Entries (1 minuto)

```lua
-- Adicionar um entry
changelogManager:addEntry(
    "Nova Feature",
    "Descrição da feature",
    "22/02/2026"
)

-- Adicionar outro
changelogManager:addEntry(
    "Bug Fix",
    "Corrigido erro de renderização"
)
```

---

## 🔄 Manipular Entries (1 minuto)

```lua
-- Remover
changelogManager:removeEntry(1)

-- Atualizar
changelogManager:updateEntry(1, {
    Title = "Novo Título",
    Description = "Nova descrição",
    Date = "22/02/2026"
})

-- Obter todos
local entries = changelogManager:getEntries()

-- Limpar
changelogManager:clear()
```

---

## 🎨 Customizar Cores (1 minuto)

Edite `components/HomeTab.lua`:

```lua
local THEME = {
    Primary = Color3.fromRGB(207, 100, 54),  -- Mude aqui
    TextPrimary = Color3.fromRGB(232, 232, 232),
    -- ... outras cores
}
```

---

## 📚 Estrutura de um Entry

```lua
{
    Title = "Título",           -- Obrigatório
    Description = "Descrição",  -- Opcional
    Date = "22/02/2026"         -- Opcional
}
```

---

## 🎯 Exemplos Rápidos

### Exemplo 1: Changelog Simples
```lua
local manager = HomeTab.createChangelogManager({
    {Title = "v1.0", Date = "22/02/2026"},
    {Title = "v0.9", Date = "20/02/2026"},
})
```

### Exemplo 2: Com Descrições
```lua
local manager = HomeTab.createChangelogManager({
    {
        Title = "v2.0 - Lançamento",
        Description = "Primeira versão estável",
        Date = "22/02/2026"
    },
})
```

### Exemplo 3: Adicionar Dinamicamente
```lua
local manager = HomeTab.createChangelogManager()
manager:addEntry("Update 1", "Descrição", "22/02/2026")
manager:addEntry("Update 2", "Descrição", "20/02/2026")
```

### Exemplo 4: Atualizar
```lua
manager:updateEntry(1, {
    Title = "Update 1 - Atualizado",
    Description = "Nova descrição",
    Date = "22/02/2026"
})
```

### Exemplo 5: Remover
```lua
manager:removeEntry(1)  -- Remove o primeiro
```

### Exemplo 6: Consultar
```lua
local entries = manager:getEntries()
for i, entry in ipairs(entries) do
    print(entry.Title)
end
```

---

## 🔗 Integração com ClaudeUI

```lua
local window = ClaudeUI.new({Title = "Minha App"})

window:CreateHomeTab({
    Changelog = {
        {Title = "Update 1", Date = "22/02/2026"},
        {Title = "Update 2", Date = "20/02/2026"},
    },
    DiscordInvite = "seu-convite"
})
```

---

## 🎓 Dicas Rápidas

1. **Sempre forneça um título** - É obrigatório
2. **Use datas no formato DD/MM/YYYY** - Mantém consistência
3. **Descrições são opcionais** - Mas recomendadas
4. **O primeiro entry é destacado** - Automaticamente
5. **Adicione entries no topo** - Novos aparecem primeiro

---

## 🐛 Problemas Comuns

### O changelog não aparece
- Verifique se importou corretamente
- Certifique-se de que tem pelo menos um entry

### As cores estão erradas
- Verifique os valores RGB (0-255)
- Limpe o cache do Studio

### As animações não funcionam
- Verifique se TweenService está disponível
- Reinicie o Studio

---

## 📚 Próximos Passos

1. Leia a [documentação completa](HOMETAB_DOCUMENTATION.md)
2. Veja os [exemplos práticos](ExampleHomeTab.lua)
3. Consulte o [guia de customização](CUSTOMIZATION_GUIDE.md)
4. Execute os [testes](HomeTabTests.lua)

---

## 🎉 Pronto!

Você agora sabe o básico. Explore a documentação para funcionalidades avançadas!

---

**Tempo total:** ~5 minutos ⏱️
