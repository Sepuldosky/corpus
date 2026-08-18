-- corpus_ui.lua — UI shell del menú Q (CLIENT)
-- Primitiva 4 de la API de Corpus (CORPUS_Architecture.md §3): una sola
-- categoría "Corpus" (menú Q → Utilities), una entrada por módulo registrado,
-- en vez de cinco menús sueltos. El buildFn recibe el panel de la entrada y lo
-- puebla con layout manual (DPanel/DLabel/DSlider/DTextEntry), patrón ya
-- validado en ADS.
--
-- CUÁNDO se construye el spawnmenu, medido en la fuente del gamemode y NO
-- asumido (este comentario decía "después de InitPostEntity" y era falso; la
-- creencia costó una sesión de bug con la categoría vacía). Sandbox lo cuelga de
-- `OnGamemodeLoaded` (gamemodes/sandbox/gamemode/spawnmenu/spawnmenu.lua:236) y
-- ahí adentro corre `AddToolMenuCategories` (:217) y después `PopulateToolMenu`
-- (:221). Ese evento llega ANTES de que los módulos booteen en `Initialize`, así
-- que la categoría aparecía —la agrega un hook nuestro que no depende de nadie—
-- pero las entradas salían de una tabla todavía vacía.
--
-- Y no alcanza con registrar tarde y confiar: `ToolMenu:Init()` llama a
-- `LoadTools()`, que lee `spawnmenu.GetTools()` UNA vez al crear el panel
-- (spawnmenu/toolmenu.lua:13). Un `AddToolMenuOption` posterior entra a la tabla
-- y no se dibuja nunca. La única salida es reconstruir el menú, que es lo que
-- hace `spawnmenu_reload` (mismo archivo, :237) — el comando con el que el autor
-- confirmó el diagnóstico a mano.
--
-- Por eso el contrato de esta primitiva es "registrá cuando quieras": si un tab
-- llega después de que el menú ya se pobló, se agenda UN rebuild diferido.

Corpus = Corpus or {}
Corpus.UI = Corpus.UI or {}
Corpus.UI._tabs = Corpus.UI._tabs or {}
-- `_poblado`: ya corrió nuestro PopulateToolMenu, o sea que el ToolMenu ya leyó
-- la tabla y un registro nuevo no se vería. `_rebuild`: hay uno agendado, para
-- que los cuatro módulos registrando en el mismo frame paguen UN solo rebuild.
Corpus.UI._poblado = Corpus.UI._poblado or false
Corpus.UI._rebuild = Corpus.UI._rebuild or false

-- Diferido a timer.Simple(0) a propósito: agrupa el lote de registros del mismo
-- frame. No hay recursión — el rebuild vuelve a correr PopulateToolMenu, que
-- solo re-lee la tabla; sin un registro NUEVO después de eso, nadie agenda otro.
local function AgendarRebuild()
    if Corpus.UI._rebuild then return end
    Corpus.UI._rebuild = true
    timer.Simple(0, function()
        Corpus.UI._rebuild = false
        RunConsoleCommand("spawnmenu_reload")
    end)
end

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

    -- Llegó después de que el menú se pobló: sin esto, el tab existe en la tabla
    -- y no se dibuja jamás. Es el caso NORMAL, no el raro — los módulos bootean
    -- en `Initialize` y el spawnmenu se arma antes (ver el header).
    if Corpus.UI._poblado then AgendarRebuild() end
end

hook.Add("AddToolMenuCategories", "corpus_ui_categoria", function()
    spawnmenu.AddToolCategory("Utilities", "Corpus", "Corpus")
end)

hook.Add("PopulateToolMenu", "corpus_ui_poblar", function()
    -- desde acá, cualquier registro nuevo necesita un rebuild para verse
    Corpus.UI._poblado = true

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
