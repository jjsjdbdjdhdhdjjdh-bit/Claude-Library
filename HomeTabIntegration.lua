-- ╔══════════════════════════════════════════════════════╗
-- ║    INTEGRAÇÃO DA HOME TAB COM CLAUDEUI              ║
-- ║  Exemplo de uso e extensão do CreateHomeTab()      ║
-- ╚══════════════════════════════════════════════════════╝

local HomeTab = require(script.Parent:WaitForChild("components"):WaitForChild("HomeTab"))

-- ════════════════════════════════════════════════════════
--   EXEMPLO DE CHANGELOG CUSTOMIZÁVEL
-- ════════════════════════════════════════════════════════

-- Define os entries do changelog
-- Cada entry tem: Title, Description, Date
-- O primeiro entry é destacado (colorido)
local CHANGELOG_ENTRIES = {
    {
        Title = "Sistema de Changelog Implementado",
        Description = "Novo sistema modular e escalável para gerenciar atualizações. Suporta adição, remoção e atualização de entries em tempo real.",
        Date = "22/02/2026"
    },
    {
        Title = "Melhorias na UI",
        Description = "Refinamento de animações e transições. Melhor responsividade em diferentes resoluções.",
        Date = "20/02/2026"
    },
    {
        Title = "Novo Design de Componentes",
        Description = "Redesign completo dos botões, toggles e dropdowns com foco em acessibilidade.",
        Date = "18/02/2026"
    },
    {
        Title = "Versão Inicial",
        Description = "Lançamento da primeira versão da biblioteca ClaudeUI com suporte a temas customizáveis.",
        Date = "15/02/2026"
    },
}

-- ════════════════════════════════════════════════════════
--   EXTENSÃO DO CLAUDEUI PARA HOME TAB AVANÇADA
-- ════════════════════════════════════════════════════════

-- Estende a função CreateHomeTab do ClaudeUI
-- Adiciona suporte a changelog manager e customizações avançadas
local function extendCreateHomeTab(ClaudeUIInstance)
    local originalCreateHomeTab = ClaudeUIInstance.CreateHomeTab
    
    -- Nova versão de CreateHomeTab com suporte a changelog manager
    function ClaudeUIInstance:CreateHomeTabAdvanced(config)
        config = config or {}
        
        -- Chama a função original
        originalCreateHomeTab(self, config)
        
        -- Cria o changelog manager
        local changelogManager = HomeTab.createChangelogManager(config.Changelog or CHANGELOG_ENTRIES)
        
        -- Armazena o manager na instância para acesso posterior
        self._changelogManager = changelogManager
        
        return changelogManager
    end
    
    -- Método para adicionar entry ao changelog
    function ClaudeUIInstance:AddChangelogEntry(title, description, date)
        if self._changelogManager then
            self._changelogManager:addEntry(title, description, date)
        end
    end
    
    -- Método para remover entry do changelog
    function ClaudeUIInstance:RemoveChangelogEntry(index)
        if self._changelogManager then
            self._changelogManager:removeEntry(index)
        end
    end
    
    -- Método para atualizar entry do changelog
    function ClaudeUIInstance:UpdateChangelogEntry(index, newData)
        if self._changelogManager then
            self._changelogManager:updateEntry(index, newData)
        end
    end
    
    -- Método para obter todos os entries
    function ClaudeUIInstance:GetChangelogEntries()
        if self._changelogManager then
            return self._changelogManager:getEntries()
        end
        return {}
    end
end

-- ════════════════════════════════════════════════════════
--   EXEMPLO DE USO
-- ════════════════════════════════════════════════════════

-- Carrega o ClaudeUI original
local ClaudeUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/seu-repo/OriginalOne-FileUI.lua"))()

-- Estende com a nova funcionalidade
extendCreateHomeTab(ClaudeUI)

-- Cria a janela
local window = ClaudeUI.new({
    Title = "Minha Aplicação",
    Width = 760,
    Height = 520,
    Acrylic = true,
    Icon = "settings",
    Changelog = CHANGELOG_ENTRIES,
})

-- Cria a Home Tab com changelog manager
local changelogManager = window:CreateHomeTabAdvanced({
    Changelog = CHANGELOG_ENTRIES,
    DiscordInvite = "seu-convite-aqui",
})

-- ════════════════════════════════════════════════════════
--   EXEMPLOS DE MANIPULAÇÃO DO CHANGELOG
-- ════════════════════════════════════════════════════════

-- Adicionar um novo entry
task.delay(5, function()
    window:AddChangelogEntry(
        "Nova Feature Adicionada",
        "Implementação de sistema de notificações em tempo real.",
        os.date("%d/%m/%Y")
    )
end)

-- Remover um entry (índice 4)
task.delay(10, function()
    window:RemoveChangelogEntry(4)
end)

-- Atualizar um entry (índice 2)
task.delay(15, function()
    window:UpdateChangelogEntry(2, {
        Title = "Melhorias na UI - Atualizado",
        Description = "Refinamento completo com novas animações e transições suaves.",
        Date = "20/02/2026"
    })
end)

-- Obter todos os entries
task.delay(20, function()
    local entries = window:GetChangelogEntries()
    print("Total de entries:", #entries)
    for i, entry in ipairs(entries) do
        print(i .. ". " .. entry.Title .. " (" .. entry.Date .. ")")
    end
end)

return window
