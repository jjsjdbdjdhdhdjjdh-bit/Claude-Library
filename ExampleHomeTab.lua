-- ╔══════════════════════════════════════════════════════╗
-- ║         EXEMPLO PRÁTICO - HOME TAB COMPLETA         ║
-- ║    Demonstra todas as funcionalidades disponíveis   ║
-- ╚══════════════════════════════════════════════════════╝

local HomeTab = require(script.Parent:WaitForChild("components"):WaitForChild("HomeTab"))

-- ════════════════════════════════════════════════════════
--   CONFIGURAÇÃO INICIAL
-- ════════════════════════════════════════════════════════

-- Define o changelog com múltiplos entries
-- O primeiro entry é destacado automaticamente
local CHANGELOG = {
    {
        Title = "v2.5.0 - Sistema de Changelog Completo",
        Description = "Implementação de um sistema modular e escalável para gerenciar atualizações. Suporta adição, remoção e atualização de entries em tempo real com animações suaves.",
        Date = "22/02/2026"
    },
    {
        Title = "v2.4.0 - Melhorias de Performance",
        Description = "Otimização de renderização e redução de uso de memória em 40%. Melhor responsividade em dispositivos com especificações mais baixas.",
        Date = "20/02/2026"
    },
    {
        Title = "v2.3.0 - Novo Design de Componentes",
        Description = "Redesign completo de botões, toggles e dropdowns. Foco em acessibilidade e consistência visual em toda a interface.",
        Date = "18/02/2026"
    },
    {
        Title = "v2.2.0 - Sistema de Temas",
        Description = "Suporte a múltiplos temas customizáveis. Usuários podem agora escolher entre temas claros e escuros.",
        Date = "15/02/2026"
    },
    {
        Title = "v2.1.0 - Animações Aprimoradas",
        Description = "Novas transições e efeitos visuais. Melhor feedback visual para interações do usuário.",
        Date = "12/02/2026"
    },
    {
        Title = "v2.0.0 - Lançamento Oficial",
        Description = "Primeira versão estável da biblioteca ClaudeUI com suporte completo a componentes interativos.",
        Date = "10/02/2026"
    },
}

-- ════════════════════════════════════════════════════════
--   CRIAR CHANGELOG MANAGER
-- ════════════════════════════════════════════════════════

-- Cria o gerenciador com os entries iniciais
local changelogManager = HomeTab.createChangelogManager(CHANGELOG)

print("✓ Changelog Manager criado com " .. #CHANGELOG .. " entries")

-- ════════════════════════════════════════════════════════
--   EXEMPLOS DE USO - ADICIONAR ENTRIES
-- ════════════════════════════════════════════════════════

-- Exemplo 1: Adicionar um entry simples
task.delay(2, function()
    print("\n[EXEMPLO 1] Adicionando entry simples...")
    changelogManager:addEntry(
        "v2.6.0 - Nova Feature: Notificações",
        "Sistema de notificações em tempo real com suporte a diferentes tipos.",
        os.date("%d/%m/%Y")
    )
    print("✓ Entry adicionado com sucesso")
end)

-- Exemplo 2: Adicionar um entry com descrição multilinha
task.delay(4, function()
    print("\n[EXEMPLO 2] Adicionando entry com descrição multilinha...")
    changelogManager:addEntry(
        "v2.7.0 - Refatoração de Código",
        "Melhorias significativas na arquitetura:\n• Código mais limpo e modular\n• Melhor performance\n• Documentação completa",
        "23/02/2026"
    )
    print("✓ Entry com múltiplas linhas adicionado")
end)

-- Exemplo 3: Adicionar entry sem data (usa data atual)
task.delay(6, function()
    print("\n[EXEMPLO 3] Adicionando entry sem data especificada...")
    changelogManager:addEntry(
        "v2.8.0 - Suporte a Novos Idiomas",
        "Agora com suporte a português, inglês, espanhol e francês"
    )
    print("✓ Entry com data automática adicionado")
end)

-- ════════════════════════════════════════════════════════
--   EXEMPLOS DE USO - ATUALIZAR ENTRIES
-- ════════════════════════════════════════════════════════

-- Exemplo 4: Atualizar um entry existente
task.delay(8, function()
    print("\n[EXEMPLO 4] Atualizando o primeiro entry...")
    changelogManager:updateEntry(1, {
        Title = "v2.8.0 - Suporte a Novos Idiomas [ATUALIZADO]",
        Description = "Agora com suporte a português, inglês, espanhol, francês e alemão. Melhor localização para usuários globais.",
        Date = "23/02/2026"
    })
    print("✓ Entry atualizado com sucesso")
end)

-- Exemplo 5: Atualizar apenas o título
task.delay(10, function()
    print("\n[EXEMPLO 5] Atualizando apenas o título de um entry...")
    local currentEntry = changelogManager:getEntries()[2]
    changelogManager:updateEntry(2, {
        Title = currentEntry.Title .. " [IMPORTANTE]",
        Description = currentEntry.Description,
        Date = currentEntry.Date
    })
    print("✓ Título atualizado")
end)

-- ════════════════════════════════════════════════════════
--   EXEMPLOS DE USO - REMOVER ENTRIES
-- ════════════════════════════════════════════════════════

-- Exemplo 6: Remover um entry específico
task.delay(12, function()
    print("\n[EXEMPLO 6] Removendo o último entry...")
    local entries = changelogManager:getEntries()
    if #entries > 0 then
        changelogManager:removeEntry(#entries)
        print("✓ Entry removido com sucesso")
    end
end)

-- ════════════════════════════════════════════════════════
--   EXEMPLOS DE USO - CONSULTAR ENTRIES
-- ════════════════════════════════════════════════════════

-- Exemplo 7: Listar todos os entries
task.delay(14, function()
    print("\n[EXEMPLO 7] Listando todos os entries...")
    local entries = changelogManager:getEntries()
    print("Total de entries: " .. #entries)
    for i, entry in ipairs(entries) do
        print(string.format("  %d. %s (%s)", i, entry.Title, entry.Date))
    end
end)

-- Exemplo 8: Buscar um entry específico
task.delay(16, function()
    print("\n[EXEMPLO 8] Buscando entries com 'Notificações'...")
    local entries = changelogManager:getEntries()
    local found = 0
    for i, entry in ipairs(entries) do
        if entry.Title:find("Notificações") then
            print(string.format("  Encontrado: %s", entry.Title))
            found = found + 1
        end
    end
    print("✓ Total encontrado: " .. found)
end)

-- ════════════════════════════════════════════════════════
--   EXEMPLOS DE USO - OPERAÇÕES EM LOTE
-- ════════════════════════════════════════════════════════

-- Exemplo 9: Adicionar múltiplos entries
task.delay(18, function()
    print("\n[EXEMPLO 9] Adicionando múltiplos entries em lote...")
    local newEntries = {
        {Title = "v3.0.0 - Versão Maior", Description = "Mudanças significativas na API", Date = "25/02/2026"},
        {Title = "v3.1.0 - Novos Componentes", Description = "Adição de 5 novos componentes", Date = "26/02/2026"},
        {Title = "v3.2.0 - Melhorias de UX", Description = "Melhor experiência do usuário", Date = "27/02/2026"},
    }
    for _, entry in ipairs(newEntries) do
        changelogManager:addEntry(entry.Title, entry.Description, entry.Date)
    end
    print("✓ " .. #newEntries .. " entries adicionados")
end)

-- Exemplo 10: Limpar todos os entries
task.delay(20, function()
    print("\n[EXEMPLO 10] Limpando todos os entries...")
    print("Entries antes: " .. #changelogManager:getEntries())
    changelogManager:clear()
    print("Entries depois: " .. #changelogManager:getEntries())
    print("✓ Todos os entries foram removidos")
end)

-- ════════════════════════════════════════════════════════
--   EXEMPLOS DE USO - RESTAURAR DADOS
-- ════════════════════════════════════════════════════════

-- Exemplo 11: Restaurar changelog original
task.delay(22, function()
    print("\n[EXEMPLO 11] Restaurando changelog original...")
    changelogManager:clear()
    for _, entry in ipairs(CHANGELOG) do
        changelogManager:addEntry(entry.Title, entry.Description, entry.Date)
    end
    print("✓ Changelog restaurado com " .. #CHANGELOG .. " entries")
end)

-- ════════════════════════════════════════════════════════
--   EXEMPLOS DE USO - CASOS DE USO REAIS
-- ════════════════════════════════════════════════════════

-- Exemplo 12: Simular atualização automática
task.delay(24, function()
    print("\n[EXEMPLO 12] Simulando atualização automática...")
    local updates = {
        {title = "Bug Fix: Corrigido erro de renderização", desc = "Problema ao renderizar em resoluções altas", date = "23/02/2026"},
        {title = "Performance: Otimizado carregamento", desc = "Redução de 30% no tempo de carregamento", date = "23/02/2026"},
        {title = "Feature: Novo sistema de cache", desc = "Melhor performance em conexões lentas", date = "23/02/2026"},
    }
    
    for i, update in ipairs(updates) do
        task.delay(i * 0.5, function()
            changelogManager:addEntry(update.title, update.desc, update.date)
            print("  ✓ Atualização " .. i .. " aplicada")
        end)
    end
end)

-- Exemplo 13: Monitorar mudanças
task.delay(26, function()
    print("\n[EXEMPLO 13] Estado final do changelog:")
    local entries = changelogManager:getEntries()
    print("Total de entries: " .. #entries)
    print("\nPrimeiros 3 entries:")
    for i = 1, math.min(3, #entries) do
        local entry = entries[i]
        print(string.format("  %d. %s", i, entry.Title))
        if entry.Description and entry.Description ~= "" then
            print(string.format("     └─ %s", entry.Description:sub(1, 50) .. "..."))
        end
    end
end)

-- ════════════════════════════════════════════════════════
--   RESUMO FINAL
-- ════════════════════════════════════════════════════════

task.delay(28, function()
    print("\n" .. string.rep("═", 50))
    print("RESUMO DOS EXEMPLOS")
    print(string.rep("═", 50))
    print("✓ Adição de entries")
    print("✓ Atualização de entries")
    print("✓ Remoção de entries")
    print("✓ Consulta de entries")
    print("✓ Operações em lote")
    print("✓ Limpeza de dados")
    print("✓ Restauração de dados")
    print("✓ Casos de uso reais")
    print(string.rep("═", 50))
    print("\nTodos os exemplos foram executados com sucesso!")
    print("Verifique o console para mais detalhes.")
end)

return changelogManager
