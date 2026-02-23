-- ╔══════════════════════════════════════════════════════╗
-- ║         TESTES - HOME TAB CHANGELOG SYSTEM          ║
-- ║    Valida todas as funcionalidades do componente    ║
-- ╚══════════════════════════════════════════════════════╝

local HomeTab = require(script.Parent:WaitForChild("components"):WaitForChild("HomeTab"))

-- ════════════════════════════════════════════════════════
--   SISTEMA DE TESTES
-- ════════════════════════════════════════════════════════

local TestSuite = {}
TestSuite.passed = 0
TestSuite.failed = 0
TestSuite.tests = {}

-- Função para registrar um teste
function TestSuite:test(name, fn)
    table.insert(self.tests, {name = name, fn = fn})
end

-- Função para executar todos os testes
function TestSuite:run()
    print("\n" .. string.rep("═", 60))
    print("INICIANDO TESTES - HOME TAB CHANGELOG SYSTEM")
    print(string.rep("═", 60) .. "\n")
    
    for i, test in ipairs(self.tests) do
        local success, err = pcall(test.fn)
        if success then
            print("✓ [" .. i .. "] " .. test.name)
            self.passed = self.passed + 1
        else
            print("✗ [" .. i .. "] " .. test.name)
            print("  Erro: " .. tostring(err))
            self.failed = self.failed + 1
        end
    end
    
    print("\n" .. string.rep("═", 60))
    print("RESULTADO DOS TESTES")
    print(string.rep("═", 60))
    print("Testes Passados: " .. self.passed)
    print("Testes Falhados: " .. self.failed)
    print("Total: " .. (self.passed + self.failed))
    print("Taxa de Sucesso: " .. string.format("%.1f%%", (self.passed / (self.passed + self.failed)) * 100))
    print(string.rep("═", 60) .. "\n")
end

-- ════════════════════════════════════════════════════════
--   TESTES - CRIAÇÃO E INICIALIZAÇÃO
-- ════════════════════════════════════════════════════════

TestSuite:test("Criar ChangelogManager vazio", function()
    local manager = HomeTab.createChangelogManager()
    assert(manager ~= nil, "Manager não foi criado")
    assert(type(manager) == "table", "Manager não é uma tabela")
    assert(#manager:getEntries() == 0, "Manager não está vazio")
end)

TestSuite:test("Criar ChangelogManager com entries iniciais", function()
    local entries = {
        {Title = "Entry 1", Date = "22/02/2026"},
        {Title = "Entry 2", Date = "20/02/2026"},
    }
    local manager = HomeTab.createChangelogManager(entries)
    assert(#manager:getEntries() == 2, "Número de entries incorreto")
end)

TestSuite:test("ChangelogManager tem todos os métodos", function()
    local manager = HomeTab.createChangelogManager()
    assert(type(manager.addEntry) == "function", "Método addEntry não existe")
    assert(type(manager.removeEntry) == "function", "Método removeEntry não existe")
    assert(type(manager.updateEntry) == "function", "Método updateEntry não existe")
    assert(type(manager.getEntries) == "function", "Método getEntries não existe")
    assert(type(manager.clear) == "function", "Método clear não existe")
    assert(type(manager.refresh) == "function", "Método refresh não existe")
end)

-- ════════════════════════════════════════════════════════
--   TESTES - ADICIONAR ENTRIES
-- ════════════════════════════════════════════════════════

TestSuite:test("Adicionar um entry simples", function()
    local manager = HomeTab.createChangelogManager()
    manager:addEntry("Novo Entry", "", "22/02/2026")
    assert(#manager:getEntries() == 1, "Entry não foi adicionado")
end)

TestSuite:test("Adicionar entry com descrição", function()
    local manager = HomeTab.createChangelogManager()
    manager:addEntry("Entry", "Descrição", "22/02/2026")
    local entries = manager:getEntries()
    assert(entries[1].Description == "Descrição", "Descrição não foi salva")
end)

TestSuite:test("Adicionar entry sem data (usa data atual)", function()
    local manager = HomeTab.createChangelogManager()
    manager:addEntry("Entry", "Descrição")
    local entries = manager:getEntries()
    assert(entries[1].Date ~= nil, "Data não foi definida")
    assert(entries[1].Date ~= "", "Data está vazia")
end)

TestSuite:test("Adicionar múltiplos entries", function()
    local manager = HomeTab.createChangelogManager()
    for i = 1, 5 do
        manager:addEntry("Entry " .. i, "Descrição " .. i, "22/02/2026")
    end
    assert(#manager:getEntries() == 5, "Nem todos os entries foram adicionados")
end)

TestSuite:test("Novo entry é adicionado no topo", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Date = "22/02/2026"},
    })
    manager:addEntry("Entry 2", "", "20/02/2026")
    local entries = manager:getEntries()
    assert(entries[1].Title == "Entry 2", "Novo entry não está no topo")
    assert(entries[2].Title == "Entry 1", "Entry antigo não foi movido")
end)

-- ════════════════════════════════════════════════════════
--   TESTES - REMOVER ENTRIES
-- ════════════════════════════════════════════════════════

TestSuite:test("Remover um entry", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Date = "22/02/2026"},
        {Title = "Entry 2", Date = "20/02/2026"},
    })
    manager:removeEntry(1)
    assert(#manager:getEntries() == 1, "Entry não foi removido")
    assert(manager:getEntries()[1].Title == "Entry 2", "Entry errado foi removido")
end)

TestSuite:test("Remover o último entry", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Date = "22/02/2026"},
        {Title = "Entry 2", Date = "20/02/2026"},
    })
    local entries = manager:getEntries()
    manager:removeEntry(#entries)
    assert(#manager:getEntries() == 1, "Último entry não foi removido")
end)

TestSuite:test("Remover todos os entries um por um", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Date = "22/02/2026"},
        {Title = "Entry 2", Date = "20/02/2026"},
        {Title = "Entry 3", Date = "18/02/2026"},
    })
    while #manager:getEntries() > 0 do
        manager:removeEntry(1)
    end
    assert(#manager:getEntries() == 0, "Nem todos os entries foram removidos")
end)

-- ════════════════════════════════════════════════════════
--   TESTES - ATUALIZAR ENTRIES
-- ════════════════════════════════════════════════════════

TestSuite:test("Atualizar um entry", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Description = "Desc 1", Date = "22/02/2026"},
    })
    manager:updateEntry(1, {
        Title = "Entry Atualizado",
        Description = "Descrição Atualizada",
        Date = "22/02/2026"
    })
    local entry = manager:getEntries()[1]
    assert(entry.Title == "Entry Atualizado", "Título não foi atualizado")
    assert(entry.Description == "Descrição Atualizada", "Descrição não foi atualizada")
end)

TestSuite:test("Atualizar apenas o título", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Description = "Desc 1", Date = "22/02/2026"},
    })
    local oldEntry = manager:getEntries()[1]
    manager:updateEntry(1, {
        Title = "Novo Título",
        Description = oldEntry.Description,
        Date = oldEntry.Date
    })
    local entry = manager:getEntries()[1]
    assert(entry.Title == "Novo Título", "Título não foi atualizado")
    assert(entry.Description == "Desc 1", "Descrição foi alterada")
end)

TestSuite:test("Atualizar entry inexistente não causa erro", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Date = "22/02/2026"},
    })
    manager:updateEntry(999, {Title = "Novo", Date = "22/02/2026"})
    assert(#manager:getEntries() == 1, "Número de entries foi alterado")
end)

-- ════════════════════════════════════════════════════════
--   TESTES - CONSULTAR ENTRIES
-- ════════════════════════════════════════════════════════

TestSuite:test("Obter todos os entries", function()
    local entries = {
        {Title = "Entry 1", Date = "22/02/2026"},
        {Title = "Entry 2", Date = "20/02/2026"},
        {Title = "Entry 3", Date = "18/02/2026"},
    }
    local manager = HomeTab.createChangelogManager(entries)
    local retrieved = manager:getEntries()
    assert(#retrieved == 3, "Número de entries incorreto")
end)

TestSuite:test("Entries retornam com todos os campos", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Description = "Desc", Date = "22/02/2026"},
    })
    local entry = manager:getEntries()[1]
    assert(entry.Title ~= nil, "Campo Title não existe")
    assert(entry.Description ~= nil, "Campo Description não existe")
    assert(entry.Date ~= nil, "Campo Date não existe")
end)

TestSuite:test("Entries mantêm a ordem", function()
    local manager = HomeTab.createChangelogManager()
    for i = 1, 5 do
        manager:addEntry("Entry " .. i, "", "22/02/2026")
    end
    local entries = manager:getEntries()
    for i = 1, 5 do
        assert(entries[i].Title == "Entry " .. (6 - i), "Ordem dos entries está incorreta")
    end
end)

-- ════════════════════════════════════════════════════════
--   TESTES - LIMPAR ENTRIES
-- ════════════════════════════════════════════════════════

TestSuite:test("Limpar todos os entries", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Date = "22/02/2026"},
        {Title = "Entry 2", Date = "20/02/2026"},
        {Title = "Entry 3", Date = "18/02/2026"},
    })
    manager:clear()
    assert(#manager:getEntries() == 0, "Entries não foram limpos")
end)

TestSuite:test("Limpar manager vazio não causa erro", function()
    local manager = HomeTab.createChangelogManager()
    manager:clear()
    assert(#manager:getEntries() == 0, "Manager não está vazio")
end)

TestSuite:test("Adicionar entries após limpar", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Date = "22/02/2026"},
    })
    manager:clear()
    manager:addEntry("Novo Entry", "", "22/02/2026")
    assert(#manager:getEntries() == 1, "Novo entry não foi adicionado")
    assert(manager:getEntries()[1].Title == "Novo Entry", "Entry incorreto foi adicionado")
end)

-- ════════════════════════════════════════════════════════
--   TESTES - CASOS DE USO COMPLEXOS
-- ════════════════════════════════════════════════════════

TestSuite:test("Operações em lote", function()
    local manager = HomeTab.createChangelogManager()
    for i = 1, 10 do
        manager:addEntry("Entry " .. i, "Descrição " .. i, "22/02/2026")
    end
    assert(#manager:getEntries() == 10, "Operações em lote falharam")
end)

TestSuite:test("Adicionar, remover e atualizar", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry 1", Date = "22/02/2026"},
    })
    manager:addEntry("Entry 2", "", "20/02/2026")
    manager:removeEntry(2)
    manager:updateEntry(1, {Title = "Entry Atualizado", Date = "22/02/2026"})
    local entries = manager:getEntries()
    assert(#entries == 1, "Número de entries incorreto")
    assert(entries[1].Title == "Entry Atualizado", "Entry não foi atualizado")
end)

TestSuite:test("Manter integridade após múltiplas operações", function()
    local manager = HomeTab.createChangelogManager()
    for i = 1, 5 do
        manager:addEntry("Entry " .. i, "", "22/02/2026")
    end
    manager:removeEntry(2)
    manager:removeEntry(3)
    manager:addEntry("Novo Entry", "", "22/02/2026")
    local entries = manager:getEntries()
    assert(#entries == 4, "Integridade dos dados foi comprometida")
end)

TestSuite:test("Descrições com quebras de linha", function()
    local manager = HomeTab.createChangelogManager()
    manager:addEntry("Entry", "Linha 1\nLinha 2\nLinha 3", "22/02/2026")
    local entry = manager:getEntries()[1]
    assert(entry.Description:find("\n") ~= nil, "Quebras de linha não foram preservadas")
end)

TestSuite:test("Títulos e descrições vazios", function()
    local manager = HomeTab.createChangelogManager()
    manager:addEntry("", "", "22/02/2026")
    local entry = manager:getEntries()[1]
    assert(entry.Title == "", "Título vazio não foi preservado")
    assert(entry.Description == "", "Descrição vazia não foi preservada")
end)

-- ════════════════════════════════════════════════════════
--   TESTES - VALIDAÇÃO DE DADOS
-- ════════════════════════════════════════════════════════

TestSuite:test("Validar tipos de dados", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry", Date = "22/02/2026"},
    })
    local entry = manager:getEntries()[1]
    assert(type(entry.Title) == "string", "Title não é string")
    assert(type(entry.Date) == "string", "Date não é string")
end)

TestSuite:test("Validar que entries são tabelas", function()
    local manager = HomeTab.createChangelogManager({
        {Title = "Entry", Date = "22/02/2026"},
    })
    local entries = manager:getEntries()
    assert(type(entries) == "table", "Entries não é tabela")
    assert(type(entries[1]) == "table", "Entry não é tabela")
end)

-- ════════════════════════════════════════════════════════
--   EXECUTAR TESTES
-- ════════════════════════════════════════════════════════

TestSuite:run()

-- ════════════════════════════════════════════════════════
--   RESUMO
-- ════════════════════════════════════════════════════════

if TestSuite.failed == 0 then
    print("🎉 TODOS OS TESTES PASSARAM COM SUCESSO!")
else
    print("⚠️  ALGUNS TESTES FALHARAM - VERIFIQUE OS ERROS ACIMA")
end

return TestSuite
