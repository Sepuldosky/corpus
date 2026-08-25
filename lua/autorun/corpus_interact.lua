-- corpus_interact.lua — Registro de acciones contextuales (SHARED)
-- Primitiva 7 de la API de Corpus. Su diseño NO vive acá: la sede es
-- docs/Corpus_Interaccion_Arquitectura.md — §3 la API y sus campos, §4 los
-- realms, §5 las tres ramas, §6.bis los regímenes de rama, §7 las perillas.
-- Este archivo la BAJA; si el archivo y el doc divergen, manda el archivo
-- (§7.1 del flujo) y el doc se corrige.
--
-- QUÉ SUBE ACÁ Y QUÉ NO (COR-1, COR-10). Sube el PROTOCOLO por el que un módulo
-- cuelga una acción; jamás una acción. El framework transporta `id`, `label`,
-- `condition`, `range` y `run` y no sabe qué significa ninguno — es COR-12 una
-- capa más arriba, y hereda su criterio de reapertura textual (§2 del doc): el
-- día que esta API mencione un ítem, un peso, una herida, un vehículo o un
-- contenedor, bajó dominio al framework y el voto se reabre.
--
-- LO QUE ESTA TANDA ES, Y LO QUE NO ES. Es el registro PELADO: valida un spec,
-- resuelve el árbol por `parent`, ordena hermanos, reparte por régimen de rama y
-- crea la perilla de cada acción. NO dibuja, NO manda net y NO ejecuta nada. El
-- commit y las tres puertas del server (§4 del doc) son la tanda siguiente, y
-- por eso acá no hay un solo `net.` ni un solo `hook.Add`.
--
-- COR-9: `Corpus = Corpus or {}` al tope; este archivo no asume orden de carga
-- dentro de lua/autorun/. Lo único que necesita de sus hermanos es `Corpus.Log`,
-- y sólo en tiempo de LLAMADA (nunca en file-scope), que es cuando ya cargaron.

Corpus = Corpus or {}
Corpus.Interact = Corpus.Interact or {}

-- Todos los nodos registrados, por `id`. Es el ÚNICO padrón: el árbol de §5 no
-- son tres tablas sino un campo `tree` por nodo, porque `parent` cruza niveles y
-- no ramas — un solo padrón deja la unicidad del `id` (que el doc pide "en TODO
-- el ecosistema") como una propiedad de la estructura y no de una convención.
Corpus.Interact._nodes = Corpus.Interact._nodes or {}

-- Ids ya avisados como huérfanos, para no repetir la línea en cada apertura del
-- menú. Es el patrón de reporte deduplicado del `pcall` de pintado del wheel de
-- Cargo (CRG-25), que §6 del doc manda reusar. ⚠ Lo deduplicado es el LOG, no la
-- cuenta: `Resolve` devuelve la lista de huérfanos SIEMPRE, porque si el silencio
-- de la segunda apertura fuera el único dato, "no hay huérfanos" y "ya lo dije"
-- se leerían igual.
Corpus.Interact._orphansLogged = Corpus.Interact._orphansLogged or {}

-- Las TRES ramas de §5. Es un set y no una lista porque lo único que el registro
-- hace con esto es validar el campo `tree`; el orden entre ramas no lo decide el
-- framework.
local TREES = { interaction = true, self = true, command = true }
Corpus.Interact.TREES = TREES

-- Los dos umbrales de §6.bis, y el 6 no es una preferencia: sale de la GEOMETRÍA
-- del chip del mock v2 (218 × 36 px alrededor de un punto, sin que dos etiquetas
-- se toquen). Si cambia el ancho del chip, cambia el techo.
-- ⚠ El 10 del cvar de filas visibles NO es un umbral y no está acá: los umbrales
-- son 6 y 12 (§6.bis, nota explícita).
local ARC_MAX = 6      -- 1-6   → arco alrededor del padre
local COLUMN_MAX = 12  -- 7-12  → columna con espina, sin paginar
                       -- 13+   → subcategorías obligatorias, cada una una columna
Corpus.Interact.ARC_MAX = ARC_MAX
Corpus.Interact.COLUMN_MAX = COLUMN_MAX

-- Tamaño de la tanda del reparto alfabético (el fallback de §6.bis.b para un
-- nodo de 13+ hijos cuyo módulo no declaró `category`). DERIVADO, no elegido:
-- cada subcategoría del régimen 13+ "es una columna", y una columna aguanta
-- COLUMN_MAX. Cualquier otro número fabricaría un tercer umbral que el diseño no
-- tiene. ⚠ Es la única cifra de este archivo que el doc no escribe con todas las
-- letras; si el autor quiere otra, se cambia acá y nada más se mueve.
local BATCH = COLUMN_MAX

-- ---------------------------------------------------------------------------
-- Perillas de admin (§7). Derivadas del roadmap #61 de Cargo, que resolvió este
-- problema exacto para las categorías de ítem — las seis reglas se heredan y el
-- código de allá transfiere casi línea por línea.
-- ---------------------------------------------------------------------------

-- ⭐ DOS ESPACIOS DE NOMBRES SEPARADOS, y la separación es el contrato (votado por
-- el autor el 2026-08-25, enmienda a §7 — que escribía `corpus_interact_<id>`):
--
--   corpus_interact_*          CONFIG DEL SUBSISTEMA. La escribe el framework.
--                              Hoy: `enabled` (la maestra). Presupuestadas: el
--                              cvar de filas visibles de §6.bis y el
--                              `corpus_interact_dump` de la tanda 2.
--   corpus_interact_action_*   UNA POR ACCIÓN. El `id` lo elige un módulo, o sea
--                              que es un conjunto ABIERTO y ajeno.
--
-- POR QUÉ SEPARADOS, y no es prolijidad: con un solo espacio, el prefijo por
-- acción CONTIENE al nombre de la maestra, así que la acción de id `enabled`
-- se llevaba el objeto de la maestra y apagarla apagaba el menú entero — sin
-- error, sin romper el registro, y visible sólo el día que un admin gira lo que
-- cree que es una perilla de acción. No era un caso: era una CLASE, y ya tenía
-- tres integrantes nombrables (`enabled`, el cvar de filas, `dump`).
--
-- Cargo no tiene el problema por ACCIDENTE (`cargo_value_mult` vs.
-- `cargo_value_mult_<cat>`: el guión bajo del prefijo lo salva). Acá está por
-- construcción, y por eso no hace falta ningún guard que alguien tenga que
-- acordarse de agregar cuando nazca la próxima convar de config.
local CONFIG_PREFIX = "corpus_interact_"
local KNOB_PREFIX = CONFIG_PREFIX .. "action_"
local MASTER_NAME = CONFIG_PREFIX .. "enabled"
Corpus.Interact.CONFIG_PREFIX = CONFIG_PREFIX
Corpus.Interact.KNOB_PREFIX = KNOB_PREFIX
Corpus.Interact.MASTER_NAME = MASTER_NAME

-- Perilla MAESTRA. En file-scope a propósito: existe aunque no se registre una
-- sola acción, que es lo que la vuelve utilizable por un admin el día 0.
-- FCVAR_REPLICATED no es opcional (§7 regla 6): el CLIENTE dibuja el árbol y el
-- SERVER ejecuta, así que una convar de sólo server deja al cliente pintando una
-- acción que el server va a rechazar.
-- ⚠⚠ Y NO SE VERIFICA LEYENDO EL FLAG: el stub de convars de los harness guarda
-- nombre y valor y no mira los flags, así que sacar el REPLICATED deja TODA la
-- pasada offline en verde. Va por comportamiento en juego o no va (§10 del doc).
local cvMaster = CreateConVar(MASTER_NAME, "1",
    bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
    "Master switch for the Corpus interaction menu (0 = the whole menu is off)", 0, 1)

-- La perilla de UNA acción, creada por el REGISTRO y no por una lista (§7 regla
-- 1): el conjunto de acciones es abierto, así que una tabla escrita a mano cubre
-- exactamente las acciones que existían el día que se escribió y el hueco
-- aparece lejos y sin un solo error.
--
-- Devuelve el OBJETO ConVar, nunca el nombre (§7 regla 3): `GetConVar` de un
-- nombre inexistente devuelve `nil`, y ese `nil` se lee igual que "la perilla no
-- aplica". Con el objeto, el string del nombre vive en un solo archivo.
--
-- Devuelve `nil` en el único caso en que la acción NO puede tener perilla, y se
-- dice en voz alta (§7 regla 4): una ausencia silenciosa se lee como "la perilla
-- está rota".
--
-- ⚠ Acá VIVÍA un segundo guard, contra la colisión del id `enabled` con la
-- maestra, y se BORRÓ al separar los dos espacios de nombres — porque un guard
-- que no puede dispararse no es una red, es código muerto que además vuelve
-- inejercitable al check que lo cubre. Lo que reemplaza a ese guard es la
-- propiedad estructural de arriba, y esa propiedad SÍ tiene un check que puede
-- fallar: que `KNOB_PREFIX` siga sin poder producir un nombre del espacio de
-- config. Acortar el prefijo lo pone rojo.
local function MakeKnob(module, id)
    -- Un id que la consola no puede tipear sería una perilla que nadie puede
    -- girar. El nodo se registra igual —esto no rechaza la acción, sólo la deja
    -- sin perilla, exactamente como la categoría de Cargo que multiplica x1.
    if id:find("[^%w_]") ~= nil then
        Corpus.Log(module, "Interact.Register: la accion '" .. id .. "' no puede tener"
            .. " perilla (un nombre de convar solo admite letras, numeros y guion bajo);"
            .. " queda gobernada solo por " .. MASTER_NAME)
        return nil
    end

    return CreateConVar(KNOB_PREFIX .. id, "1",
        bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
        "Enables the '" .. id .. "' interaction action (0 = hidden and refused)", 0, 1)
end

-- La composición maestra × acción vive EN UNA SOLA FUNCIÓN (§7 regla 2), del
-- mismo linaje que `Trade.ValueMult`. Un segundo sitio que componga a mano es
-- cómo un lector y un escritor se separan sin dar error.
--
-- Un id que no está registrado devuelve `false` y no `nil`: la pregunta que esta
-- función contesta es "¿puede correr esta acción?", y para una acción que no
-- existe la respuesta es no. Distinguir "apagada" de "inexistente" es trabajo de
-- quien llame, que tiene `_nodes` al lado.
function Corpus.Interact.Enabled(id)
    if not cvMaster:GetBool() then return false end

    local node = isstring(id) and Corpus.Interact._nodes[id] or nil
    if node == nil then return false end

    -- Sin perilla propia (un id que la consola no puede tipear) manda la maestra
    -- sola, que ya se leyó arriba.
    if node.cvEnabled == nil then return true end
    return node.cvEnabled:GetBool()
end

-- ---------------------------------------------------------------------------
-- El registro (§3)
-- ---------------------------------------------------------------------------

-- Un solo sitio arma el rechazo, para que el motivo que se DEVUELVE y el motivo
-- que se LOGUEA no puedan separarse. El segundo retorno existe para que un check
-- pueda comparar el motivo EXACTO en vez de "hubo un rechazo": en una fila de
-- guardas, un control que sólo mira el resultado agregado no prueba ninguna
-- guarda en particular — la prueba la firma la de al lado, y la de al lado
-- siempre está.
local function Rechazar(module, motivo)
    Corpus.Log(isstring(module) and module ~= "" and module or "corpus",
        "Interact.Register: spec rechazado — " .. motivo)
    return nil, motivo
end

-- Corpus.Interact.Register(module, spec) -> spec | nil, motivo
--
-- Devuelve el spec NORMALIZADO (la misma tabla que entró, con los defaults ya
-- escritos y `module` estampado), o `nil` más el motivo si fue rechazado — y
-- entonces LO DICE por Corpus.Log. Una ausencia silenciosa se lee como "el menú
-- no funciona": ése es el motivo escrito del retorno, no un gusto (§3).
--
-- ⚠ Rechaza devolviendo `nil`, no con `error()`, y ahí se aparta de sus cinco
-- hermanas a propósito: la firma del doc es `-> spec | nil`. Un módulo que
-- registra treinta acciones no debe caerse entero por una mal formada.
function Corpus.Interact.Register(module, spec)
    if not isstring(module) or module == "" then
        return Rechazar(module, "'module' debe ser un string no vacio")
    end
    if not istable(spec) then
        return Rechazar(module, "'spec' debe ser una tabla")
    end

    -- --- los tres obligatorios ---
    if not isstring(spec.id) or spec.id == "" then
        return Rechazar(module, "'id' debe ser un string no vacio")
    end
    if not isstring(spec.label) or spec.label == "" then
        return Rechazar(module, "'label' debe ser un string no vacio (id '"
            .. spec.id .. "')")
    end
    if not TREES[spec.tree] then
        return Rechazar(module, "'tree' debe ser \"interaction\", \"self\" o \"command\""
            .. " (id '" .. spec.id .. "' trajo '" .. tostring(spec.tree) .. "')")
    end
    -- `run` es obligatorio incluso en un nodo que es sólo estructura: ahí va una
    -- función que no hace nada (§3). El cliente lee `isfunction(run)` para saber
    -- que el nodo es accionable —la misma prueba que la UI de Cargo hace sobre
    -- `onUse`— así que la ausencia del campo y una rama muerta no son la misma
    -- cosa y no se pueden escribir igual.
    if not isfunction(spec.run) then
        return Rechazar(module, "'run' debe ser una funcion (id '" .. spec.id .. "')")
    end

    -- --- los opcionales: si vienen, vienen bien ---
    if spec.parent ~= nil and (not isstring(spec.parent) or spec.parent == "") then
        return Rechazar(module, "'parent' debe ser un id (string no vacio) o nil (id '"
            .. spec.id .. "')")
    end
    if spec.parent == spec.id then
        return Rechazar(module, "'parent' no puede ser el propio id ('" .. spec.id .. "')")
    end
    if spec.order ~= nil and not isnumber(spec.order) then
        return Rechazar(module, "'order' debe ser un numero o nil (id '" .. spec.id .. "')")
    end
    if spec.icon ~= nil and (not isstring(spec.icon) or spec.icon == "") then
        return Rechazar(module, "'icon' debe ser una ruta de material o nil (id '"
            .. spec.id .. "')")
    end
    if spec.category ~= nil and (not isstring(spec.category) or spec.category == "") then
        return Rechazar(module, "'category' debe ser un string no vacio o nil (id '"
            .. spec.id .. "')")
    end
    if spec.condition ~= nil and not isfunction(spec.condition) then
        return Rechazar(module, "'condition' debe ser una funcion o nil (id '"
            .. spec.id .. "')")
    end
    if spec.range ~= nil and not isnumber(spec.range) then
        return Rechazar(module, "'range' debe ser un numero o nil (id '" .. spec.id .. "')")
    end

    -- --- re-registro ---
    -- Las dos causas son distintas y por eso el log las separa: el MISMO módulo
    -- re-registrando es un `lua_refresh` y es esperable; OTRO módulo pisando el
    -- id es la colisión que el doc quiere impedir al pedir un id único en todo el
    -- ecosistema. Las dos reemplazan —igual que RegisterModule y UI.RegisterTab—
    -- pero un log que no las distinga vuelve invisible la segunda.
    local prev = Corpus.Interact._nodes[spec.id]
    if prev ~= nil then
        if prev.module == module then
            Corpus.Log(module, "Interact.Register: accion '" .. spec.id
                .. "' re-registrada; se reemplaza la anterior")
        else
            Corpus.Log(module, "Interact.Register: COLISION de id — '" .. spec.id
                .. "' ya estaba registrada por '" .. tostring(prev.module)
                .. "'; se reemplaza")
        end
    end

    -- --- normalización ---
    spec.module = module
    spec.order = spec.order or 100  -- default 100, como RegisterCategory (§3)

    -- Re-registrar REUSA el objeto ya construido (§7 regla 5): un `lua_refresh`
    -- no le puede borrar al operador el valor que puso. Ningún test offline
    -- distingue esta rama de volver a llamar a CreateConVar — y se escribe así
    -- por eso mismo, para que el resultado no dependa de qué devuelve
    -- CreateConVar sobre un nombre que ya existe.
    spec.cvEnabled = (prev ~= nil and prev.cvEnabled) or MakeKnob(module, spec.id)

    Corpus.Interact._nodes[spec.id] = spec

    -- El árbol cambió: un id que era huérfano puede haber dejado de serlo, así
    -- que la memoria de lo ya avisado se limpia. Sin esto, el nodo que se arregla
    -- queda callado para siempre y el que se rompe después nunca avisa.
    Corpus.Interact._orphansLogged = {}

    return spec
end

-- ---------------------------------------------------------------------------
-- Resolución del árbol (§3.a y §6.bis)
-- ---------------------------------------------------------------------------

-- Hermanos ordenados por `order`, y el `id` desempata. El desempate NO es
-- prolijidad: sin él, dos hermanos con el mismo `order` salen en el orden de
-- `pairs` sobre una tabla hash, que no se repite entre sesiones — o sea que el
-- menú se reacomodaría solo entre dos arranques y ningún check podría medirlo.
local function OrdenarHermanos(lista)
    table.sort(lista, function(a, b)
        if a.order ~= b.order then return a.order < b.order end
        return a.id < b.id
    end)
    return lista
end

-- Régimen por CUENTA DE HIJOS DIRECTOS (§6.bis). Es el número de hijos y no el de
-- hojas: el de hojas es lo que el nodo CANTA (ver ContarHojas), y son dos números
-- distintos — en Gestures el ámbar dice 34 y el régimen lo eligen sus hijos.
local function RegimenDe(n)
    if n <= ARC_MAX then return "arc" end
    if n <= COLUMN_MAX then return "column" end
    return "subcategories"
end

-- HOJAS ALCANZABLES bajo un nodo (§6.bis.a), que es lo que el número ámbar canta:
-- "en Gestures dice 34, no los 4 hijos que se ven", así que el jugador sabe si
-- vale la pena entrar.
--
-- `visitados` queda como RED, no como requisito: desde que un huérfano es todo lo
-- que no se alcanza desde una raíz, el árbol que llega hasta acá es acíclico por
-- construcción y esta recursión no puede encontrar un ciclo. Se deja porque la
-- función es pública para el resto del archivo y el costo es un `if` — pero
-- ⚠ **no es la defensa contra los ciclos**: la defensa es la alcanzabilidad de
-- `Resolve`, que además los DICE. Si esto fuera lo único, un ciclo no colgaría el
-- juego pero seguiría borrando nodos en silencio.
local function ContarHojas(id, hijosDe, visitados)
    local hijos = hijosDe[id]
    if hijos == nil or #hijos == 0 then return 1 end

    visitados[id] = true
    local n = 0
    for _, hijo in ipairs(hijos) do
        if not visitados[hijo.id] then
            n = n + ContarHojas(hijo.id, hijosDe, visitados)
        end
    end
    visitados[id] = nil

    -- Un nodo cuyos hijos son TODOS parte de un ciclo no alcanza ninguna hoja;
    -- se cuenta como hoja él mismo para que el ámbar nunca diga 0.
    if n == 0 then return 1 end
    return n
end

-- Reparto en subcategorías del régimen 13+. Las declara el módulo con `category`
-- (§6.bis.b); si NO la declara, el árbol reparte alfabéticamente en tandas.
-- Lo que el árbol nunca hace es dibujar 34 en arco.
--
-- El reparto es por nodo y no global: un nodo puede tener hijos con `category` y
-- hijos sin ella, y los segundos caen a tandas alfabéticas sin arrastrar a los
-- primeros. Cada grupo lleva su cuenta de hojas, porque "las subcategorías cantan
-- el suyo igual".
local function Agrupar(hijos, hijosDe)
    local declarados, sueltos = {}, {}
    for _, hijo in ipairs(hijos) do
        if hijo.category ~= nil then
            declarados[hijo.category] = declarados[hijo.category] or {}
            local g = declarados[hijo.category]
            g[#g + 1] = hijo
        else
            sueltos[#sueltos + 1] = hijo
        end
    end

    local grupos = {}
    local nombres = {}
    for cat in pairs(declarados) do nombres[#nombres + 1] = cat end
    table.sort(nombres)
    for _, cat in ipairs(nombres) do
        grupos[#grupos + 1] = { category = cat, declared = true, items = OrdenarHermanos(declarados[cat]) }
    end

    -- Las tandas alfabéticas. `sueltos` ya viene ordenado por `order`+id desde el
    -- llamador; el reparto es ALFABÉTICO, así que se reordena por label y recién
    -- ahí se corta — "reparto alfabético en tandas" nombra el criterio de corte,
    -- no el de dibujado dentro del grupo.
    table.sort(sueltos, function(a, b)
        if a.label ~= b.label then return a.label < b.label end
        return a.id < b.id
    end)
    -- REPARTO PAREJO Y NO CORTE FIJO (votado por el autor el 2026-08-25). La
    -- cantidad de tandas es la misma en los dos —`ceil(n/BATCH)` siempre—, así que
    -- repartir parejo NO cuesta un nivel más de navegación: cuesta cero y sólo
    -- cambia cómo se ve. Lo que compra es no fabricar una subcategoría de UN
    -- ítem justo al cruzar el umbral: cortando fijo, 13 hijos daban [12, 1] y 25
    -- daban [12, 12, 1]. Una subcategoría con un ítem adentro es exactamente la
    -- ilegibilidad que el régimen de 13+ existe para evitar.
    local n = #sueltos
    if n > 0 then
        local tandas = math.ceil(n / BATCH)
        local base = math.floor(n / tandas)
        local resto = n % tandas -- las primeras `resto` tandas llevan uno más
        local i = 1
        for t = 1, tandas do
            local cuantos = base + (t <= resto and 1 or 0)
            local lote = {}
            for k = i, i + cuantos - 1 do lote[#lote + 1] = sueltos[k] end
            i = i + cuantos
            grupos[#grupos + 1] = {
                category = lote[1].label:sub(1, 1):upper() .. "-"
                    .. lote[#lote].label:sub(1, 1):upper(),
                declared = false,
                items = lote,
            }
        end
    end

    for _, g in ipairs(grupos) do
        local hojas = 0
        for _, hijo in ipairs(g.items) do
            hojas = hojas + ContarHojas(hijo.id, hijosDe, {})
        end
        g.leaves = hojas
    end

    return grupos
end

-- Corpus.Interact.Resolve(tree) -> tabla del árbol resuelto
--
-- EL ÁRBOL SE RESUELVE AL ABRIRLO, NO AL REGISTRAR (§3.a): `parent` es un `id` y
-- no una referencia, justamente para que un módulo pueda colgar de un nodo que
-- todavía no se registró — el orden de mount entre addons no está garantizado y
-- COR-11 dice que todo salvo Corpus es soft-dep.
--
-- Devuelve SIEMPRE una tabla, también para una rama sin un solo nodo: un árbol
-- vacío tiene que ser una MEDICIÓN, y `#roots == 0` es un resultado distinto de
-- no haber evaluado nada. Es lo que hace que la rama `command`, que hoy nace
-- vacía porque su escuadra vive en Cortex, pruebe la forma sin comprometer nada.
function Corpus.Interact.Resolve(tree)
    local resuelto = {
        tree = tree,
        nodes = {},     -- [id] = spec, sólo los de esta rama
        roots = {},     -- ordenados
        children = {},  -- [id] = { spec, ... } ordenados
        orphans = {},   -- ordenados por id; `parent` que nunca apareció, o ciclo
        regime = {},    -- [id] = "arc" | "column" | "subcategories"
        leaves = {},    -- [id] = hojas alcanzables (el número ámbar)
        groups = {},    -- [id] = { { category, declared, items, leaves }, ... }
        count = 0,      -- nodos de la rama, huérfanos incluidos
    }
    if not TREES[tree] then return resuelto end

    for id, spec in pairs(Corpus.Interact._nodes) do
        if spec.tree == tree then
            resuelto.nodes[id] = spec
            resuelto.count = resuelto.count + 1
        end
    end

    -- Hijos PROVISIONALES: quién dice colgar de quién, sin saber todavía si el
    -- padre llega a alguna parte. Un `parent` que apunta a otra rama, o que no
    -- existe, no entra a ninguna lista y queda solo desde acá.
    local hijosDe = {}
    local raices = {}
    for id, spec in pairs(resuelto.nodes) do
        if spec.parent == nil then
            raices[#raices + 1] = spec
        elseif resuelto.nodes[spec.parent] ~= nil then
            hijosDe[spec.parent] = hijosDe[spec.parent] or {}
            local c = hijosDe[spec.parent]
            c[#c + 1] = spec
        end
    end

    -- ⭐ ALCANZABILIDAD DESDE LAS RAÍCES, Y ES LA ÚNICA DEFINICIÓN DE HUÉRFANO
    -- (votado por el autor el 2026-08-25). Una sola regla cubre los cuatro casos
    -- que antes necesitaban dos y dejaban uno afuera:
    --   · `parent` que no existe          → no se llega    → huérfano
    --   · `parent` de otra rama           → no se llega    → huérfano
    --   · CICLO (A cuelga de B, B de A)   → no se llega    → huérfano
    --   · `parent` = el propio id         → ya lo rechaza Register
    -- El ciclo era el que se escapaba: los nodos existían en `children`, no
    -- estaban en `roots`, **no los alcanzaba ninguna raíz** y `orphans` decía 0.
    -- O sea que desaparecían del menú **sin un solo aviso** —junto con todo nodo
    -- sano que colgara debajo, de un módulo que no tuvo nada que ver—, que es
    -- exactamente lo que §3.a existe para impedir.
    local alcanzable = {}
    local pila = {}
    for _, spec in ipairs(raices) do pila[#pila + 1] = spec.id end
    while #pila > 0 do
        local id = table.remove(pila)
        if not alcanzable[id] then
            alcanzable[id] = true
            for _, hijo in ipairs(hijosDe[id] or {}) do pila[#pila + 1] = hijo.id end
        end
    end

    -- El árbol que se dibuja es sólo lo alcanzable. Si un padre llega, sus hijos
    -- llegan (los puso ahí la propia recorrida), así que basta con filtrar por el
    -- padre: la lista de un padre inalcanzable se descarta entera y sus hijos
    -- caen a huérfanos por la misma regla.
    resuelto.roots = raices
    for pid, lista in pairs(hijosDe) do
        if alcanzable[pid] then resuelto.children[pid] = lista end
    end

    OrdenarHermanos(resuelto.roots)
    for _, lista in pairs(resuelto.children) do OrdenarHermanos(lista) end

    local huerfanos = {}
    for id, spec in pairs(resuelto.nodes) do
        if not alcanzable[id] then huerfanos[#huerfanos + 1] = spec end
    end
    table.sort(huerfanos, function(a, b) return a.id < b.id end)
    resuelto.orphans = huerfanos

    -- Un nodo huérfano NO SE DIBUJA, y eso se dice (§3.a): un nodo que no aparece
    -- y no avisa es indistinguible de uno cuya `condition` dio `false`. El log va
    -- deduplicado por id (ver `_orphansLogged`); la lista de arriba no.
    --
    -- ⚠ Y NOMBRA SU CAUSA, porque son dos y piden arreglos distintos: «el parent
    -- no existe» es un error del módulo que registró ESTE nodo, y «cuelga de algo
    -- que tampoco se alcanza» normalmente NO lo es —es la víctima de un ciclo que
    -- armaron más arriba—. Un log que las junte manda a auditar el módulo sano.
    for _, spec in ipairs(huerfanos) do
        if not Corpus.Interact._orphansLogged[spec.id] then
            Corpus.Interact._orphansLogged[spec.id] = true
            local causa
            if resuelto.nodes[spec.parent] == nil then
                causa = "su parent '" .. tostring(spec.parent)
                    .. "' no existe en esta rama"
            else
                causa = "su parent '" .. tostring(spec.parent)
                    .. "' tampoco se alcanza desde ninguna raiz (cadena rota o ciclo)"
            end
            Corpus.Log(spec.module, "Interact: la accion '" .. spec.id
                .. "' no se alcanza en la rama '" .. tostring(tree) .. "': " .. causa
                .. "; queda huerfana y no se dibuja")
        end
    end

    -- Régimen y número ámbar, SÓLO para los alcanzables: un huérfano no se dibuja,
    -- así que no tiene régimen, y darle uno sería un dato que nadie puede usar.
    -- La cuenta de esta tabla es exactamente `count - #orphans`, y ése es el
    -- denominador con el que se audita que el reparto no perdió a nadie.
    for id in pairs(resuelto.nodes) do
        if alcanzable[id] then
            local hijos = resuelto.children[id]
            local n = hijos and #hijos or 0
            resuelto.regime[id] = RegimenDe(n)
            resuelto.leaves[id] = ContarHojas(id, resuelto.children, {})
            if resuelto.regime[id] == "subcategories" then
                resuelto.groups[id] = Agrupar(hijos, resuelto.children)
            end
        end
    end

    return resuelto
end

-- Vacía el padrón. Interno / off-contract: existe para los instrumentos (el
-- harness offline arma un árbol distinto por bloque de checks). No se usa desde
-- el juego.
function Corpus.Interact._Reset()
    Corpus.Interact._nodes = {}
    Corpus.Interact._orphansLogged = {}
end
