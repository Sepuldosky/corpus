-- corpus_ui.lua — UI shell del menú Q (CLIENT)
-- Primitiva 4 de la API de Corpus (CORPUS_Architecture.md §3): una sola
-- categoría "Corpus" (menú Q → Utilities), una entrada por módulo registrado,
-- en vez de cinco menús sueltos. El buildFn recibe el panel de la entrada y lo
-- puebla con layout manual (DPanel/DLabel/DSlider/DTextEntry), patrón ya
-- validado en ADS.
--
-- Los tabs deben registrarse durante la carga (autorun): el spawnmenu se
-- construye una sola vez, después de InitPostEntity, con lo registrado hasta ahí.

Corpus = Corpus or {}
Corpus.UI = Corpus.UI or {}
Corpus.UI._tabs = Corpus.UI._tabs or {}

function Corpus.UI.RegisterTab(module, label, buildFn)
    if not isstring(module) or module == "" then
        error("Corpus.UI.RegisterTab: 'module' debe ser un string no vacío", 2)
    end
    if not isstring(label) or label == "" then
        error("Corpus.UI.RegisterTab: 'label' debe ser un string no vacío", 2)
    end
    if not isfunction(buildFn) then
        error("Corpus.UI.RegisterTab: 'buildFn' debe ser una función", 2)
    end

    if Corpus.UI._tabs[module] ~= nil then
        Corpus.Log(module, "UI.RegisterTab: tab re-registrado; se reemplaza el anterior")
    end
    Corpus.UI._tabs[module] = { label = label, buildFn = buildFn }
end

hook.Add("AddToolMenuCategories", "corpus_ui_categoria", function()
    spawnmenu.AddToolCategory("Utilities", "Corpus", "Corpus")
end)

hook.Add("PopulateToolMenu", "corpus_ui_poblar", function()
    -- orden alfabético por módulo: entradas estables entre sesiones
    local nombres = {}
    for name in pairs(Corpus.UI._tabs) do
        nombres[#nombres + 1] = name
    end
    table.sort(nombres)

    for _, name in ipairs(nombres) do
        local tab = Corpus.UI._tabs[name]
        spawnmenu.AddToolMenuOption("Utilities", "Corpus", "corpus_ui_" .. name, tab.label, "", "", function(panel)
            panel:Clear()
            -- pcall: un buildFn roto no debe tumbar el spawnmenu entero
            local ok, err = pcall(tab.buildFn, panel)
            if not ok then
                Corpus.Log(name, "error construyendo su tab de UI: " .. tostring(err))
            end
        end)
    end
end)
