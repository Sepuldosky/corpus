-- corpus_ready.lua — Ready barrier (SHARED)
-- Primitiva 5 de la API de Corpus (CORPUS_Architecture.md §3). Los módulos se
-- registran en autorun, que en Gmod corre siempre antes de InitPostEntity — por
-- eso, cuando la barrera dispara, todos los módulos presentes ya están en el
-- registro: punto seguro para wiring de soft-deps que corre UNA sola vez.
--
-- LA BARRERA NO CUELGA DE UN SOLO HOOK, y no es defensa especulativa: es COR-5
-- (detección, nunca asunción) aplicada al propio framework. Hasta el 2026-08-08
-- esto era `hook.Add("InitPostEntity", ...)` a secas y **ese callback no corría
-- en el realm CLIENTE** — medido tres veces en juego
-- (dev/VEREDICTO_ready_barrier_cliente.md): `corpus_selftest_cl` daba
-- readyFired=false, y en dos arranques enteros ninguna de las líneas
-- `(…, client)` de los cross-registros salió en el console.log.
-- Se perdían 4.413 defs (4 médicas, 15 de comida, 4.394 de attachments ARC9) y
-- las 3 barras del StatusPanel, **sin un solo error de Lua**: un wiring que no
-- corre no se parece a una falla, se parece a un módulo que no registró nada.
-- En el mismo realm cliente `Initialize` SÍ dispara (de ahí salen los `cargado
-- (client)` de los cuatro módulos), así que no era orden de carga ni archivo
-- faltante: el archivo cargó, el hook quedó puesto, y el callback no corrió.
--
-- EL HALLAZGO — CORREGIDO EL 2026-08-09, Y LA CORRECCIÓN ES LO QUE HAY QUE LEER.
-- Del 2026-08-08 al 2026-08-09 este header afirmó, en negrita, que **el evento no
-- se dispara en el realm CLIENTE**. Está **REFUTADO, midiendo**: se dispara. Lo
-- que no corre es NUESTRO CALLBACK. Los dos enunciados producen exactamente la
-- misma lectura del selftest y NO son la misma afirmación.
--
-- POR QUÉ EL INSTRUMENTO NO PODÍA DECIRLO, que es la lección cara:
-- `_initPostEntitySeen` la escribe **este mismo hook**, tres líneas más abajo.
-- Una bandera que sólo puede ponerse en `true` desde adentro del callback mide
-- **si el callback corrió**, jamás si el evento ocurrió. El detalle la imprimía
-- como `initPostEntity=NO llegó`: **el NOMBRE del instrumento contrabandeó la
-- conclusión**, y `mundoAlCargar` —que midió bien lo suyo— sólo cerró la puerta
-- de al lado (el hook estaba puesto a tiempo), lo cual es cierto y sigue siendo
-- cierto. No hay medición que respalde el salto de «no corrió» a «no ocurrió».
--
-- LA MEDICIÓN QUE LO DA VUELTA (`garrysmod/console.log`, 61.397 líneas, NUEVE
-- arranques de mapa; el bloque decisivo es el que rodea a la 2.ª lectura del
-- selftest, líneas 18024-18231). En el realm CLIENTE, en ESE MISMO arranque:
--   1. los cuatro `cargado (client)` de los módulos (boot diferido a `Initialize`)
--   2. `[Quick Loadouts] Generating weapon table...`  ← su callback de
--      `InitPostEntity`, realm CLIENTE (`cl_loadoutmenu.lua:1822`; el archivo se
--      `include`a sólo en la rama CLIENT de `chensquickloadout.lua:8`)
--   3. `ready barrier: 9 wiring(s) disparados por fallback (client)`
--   4. `ready: dispara una vez — ... initPostEntity=NO llegó mundoAlCargar=no`
-- El paso 2 aparece en los NUEVE arranques, siempre 11-12 líneas antes del paso 3.
--
-- Y NO PUEDE SER LA OTRA RUTA. `GenerateWeaponTable()` tiene tres llamadores:
-- ese hook, el armado del menú y un concommand. El menú exige una tecla, y una
-- tecla exige un `LocalPlayer()` válido — que es la condición del paso 3, POSTERIOR.
-- El concommand no aparece ni una vez en el log. Queda el hook.
-- ⇒ **El evento se dispara en el realm cliente, y nuestro callback no corre.**
--
-- EL MECANISMO, y no es una teoría del engine: está en su fuente, en disco.
-- `garrysmod/lua/includes/modules/hook.lua`, función `Call`:
--     for k, v in pairs( HookTable ) do
--         a, b, c, d, e, f = v( ... )
--         if ( a != nil ) then return a, b, c, d, e, f end   -- ← ABORTA LA CADENA
-- Un tercero que devuelva cualquier valor no-nil en `InitPostEntity` **deja sin
-- evento a todos los oyentes que caigan después de él** en el orden de `pairs()`
-- sobre una tabla hash: sin conocer nuestro nombre, sin desengancharnos y **sin
-- un solo error de Lua**. Explica lo único que las hipótesis viejas no explicaban:
-- por qué Quick Loadouts corre y nosotros no, en el mismo evento y el mismo realm.
-- Nótese que esto TUMBA el argumento de «da igual quién sea, tendría que matarlo
-- para todos»: el corte no es para todos, es para los de más abajo en la fila.
--
-- QUIÉN CORTA: **SIN IDENTIFICAR.** Barrido de `dev/other/` (2026-08-09): de los
-- 41 `hook.Add("InitPostEntity", ...)` que hay, ninguno devuelve un valor al nivel
-- del handler. **Descartado NO es probado**: `dev/other/` no tiene los 380 addons
-- suscritos (misma lección que `leer-el-gma-del-tercero-en-vez-de-inferirlo`).
-- Lo separa una sola medición que hoy no existe: si nuestro hook ESTÁ en
-- `hook.GetTable()["InitPostEntity"]` en runtime, nadie nos desenganchó y el corte
-- es por retorno; si NO está, un tercero nos borró por nombre.
--
-- TESTIGO AJENO ÚTIL: Quick Loadouts, por lo de arriba. **Better Movement NO
-- sirve** aunque su `bm_init` CLIENT (`sh_bm_main.lua:226`) cuelgue del mismo
-- evento: sólo escribe NW2 vars que el SERVER reescribe en cada `PlayerSpawn`
-- (`:219-223`) y replica, así que en listen server su ausencia no produce ningún
-- síntoma. Un testigo cuyo fracaso es invisible no atestigua.
--
-- POR ESO EL RESPALDO NO ES UN PARCHE, y ahora menos que antes: no rodea una
-- rareza de esta instalación sino una propiedad ESTRUCTURAL de `hook.Call` —
-- cualquier tercero puede cortar la cadena, en cualquier realm, en cualquier
-- momento. Colgar una primitiva de un solo `hook.Add` nunca fue una garantía.
-- `fuente=fallback` en el cliente es lo ESPERADO; si algún día dijera
-- `InitPostEntity`, quiere decir que el que cortaba se fue.

Corpus = Corpus or {}
Corpus._readyFired = Corpus._readyFired or false
Corpus._readyQueue = Corpus._readyQueue or {}
-- Qué señal disparó la barrera, para que el log lo acredite en vez de que haya
-- que deducirlo: "InitPostEntity" | "fallback" | nil si todavía no disparó.
Corpus._readySource = Corpus._readySource or nil
-- ¿CORRIÓ NUESTRO CALLBACK de InitPostEntity, aunque no haya sido el que disparó
-- la barrera? Eso, y NADA MÁS, es lo que esta bandera puede medir: la escribe el
-- propio callback, así que en falso significa «no corrió» y **jamás** «el evento
-- no ocurrió». Sirve porque `fuente` sola no lo dice —`fallback` sólo acredita
-- quién ganó la carrera—, pero se leyó de más el 2026-08-08 y por eso el rótulo
-- del selftest se llama hoy `hookIPE=corrió | NO corrió` (ver el header).
Corpus._initPostEntitySeen = Corpus._initPostEntitySeen or false

-- ¿Ya existía el mundo cuando ESTE archivo cargó? Midió su pregunta y la cerró
-- bien: `no` ⇒ el evento todavía no había ocurrido cuando pusimos el hook, o sea
-- que **el hook estaba puesto a tiempo** (la inferencia es de ORDEN, no del
-- engine: `InitPostEntity` corre DESPUÉS de que las entidades existen). Lo que
-- NO autoriza —y fue el salto del 2026-08-08— es concluir de ahí que el evento
-- nunca ocurrió: «puesto a tiempo» + «no corrió» deja abierto que la cadena de
-- hooks se haya cortado antes de llegar a nosotros, que es lo que el console.log
-- terminó mostrando. Se mide UNA vez, en file-scope, que es el momento del que se
-- quiere hablar: leerlo más tarde contestaría otra pregunta.
if Corpus._worldAtLoad == nil then
    Corpus._worldAtLoad = isfunction(game and game.GetWorld) and IsValid(game.GetWorld()) or false
end

function Corpus.OnReady(fn)
    if not isfunction(fn) then
        error("Corpus.OnReady: 'fn' debe ser una función", 2)
    end

    if Corpus._readyFired then
        -- suscripción tardía (o lua refresh): la barrera ya pasó, corre ahora
        fn()
        return
    end

    table.insert(Corpus._readyQueue, fn)
end

-- Dispara la barrera. IDEMPOTENTE por `_readyFired`: la llaman varias señales y
-- solo la primera hace algo — la segunda es un no-op, no un error.
local function Fire(source)
    if Corpus._readyFired then return end
    Corpus._readyFired = true
    Corpus._readySource = source

    local pendientes = #Corpus._readyQueue
    for _, fn in ipairs(Corpus._readyQueue) do
        -- pcall: un callback roto de un módulo no debe frenar el wiring del resto
        local ok, err = pcall(fn)
        if not ok then
            Corpus.Log("corpus", "error en callback de OnReady: " .. tostring(err))
        end
    end

    Corpus._readyQueue = {}

    -- Habla SIEMPRE, no solo cuando algo sale mal: la ruta que se usó y cuántos
    -- wirings se soltaron son el instrumento que faltaba. Con esta línea en el
    -- log, "la barrera no disparó en este realm" se ve leyendo, sin correr un
    -- selftest — que es como el defecto del 2026-08-08 pasó dos arranques.
    Corpus.Log("corpus", "ready barrier: " .. pendientes .. " wiring(s) disparados por "
        .. source .. " (" .. (SERVER and "server" or "client") .. ")")
end
Corpus._FireReady = Fire  -- interno / off-contract: lo usa el selftest

-- El hook queda puesto SIEMPRE y no se desengancha aunque el respaldo haya
-- disparado antes: su segundo trabajo es ser el testigo del evento. Si llega
-- tarde, `Fire` es un no-op —correcto— pero la llegada se anota igual y se
-- dice, porque un evento que llega tarde y otro que no llega nunca producen
-- hoy exactamente el mismo log, y son causas distintas.
hook.Add("InitPostEntity", "corpus_ready_barrier", function()
    Corpus._initPostEntitySeen = true
    if Corpus._readyFired and Corpus._readySource ~= "InitPostEntity" then
        Corpus.Log("corpus", "InitPostEntity llegó TARDE: la barrera ya había disparado por "
            .. tostring(Corpus._readySource) .. " (" .. (SERVER and "server" or "client") .. ")")
    end
    Fire("InitPostEntity")
end)

-- RESPALDO, solo CLIENT y solo porque está medido que hace falta (ver el header).
-- El primer Think con LocalPlayer() válido es tardío a propósito: `Initialize` ya
-- corrió —o sea que todo autorun cargó y los módulos ya bootearon—, así que la
-- garantía que la barrera promete (todos los módulos presentes ya registrados)
-- se sostiene igual por esta ruta. Se desengancha en cuanto sirve; si en esta
-- instalación InitPostEntity SÍ llegara, dispara primero y este Fire es un no-op.
if CLIENT then
    hook.Add("Think", "corpus_ready_fallback", function()
        if not IsValid(LocalPlayer()) then return end
        hook.Remove("Think", "corpus_ready_fallback")
        Fire("fallback")
    end)
end
