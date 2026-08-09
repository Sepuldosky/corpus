-- corpus_ready.lua — Ready barrier (SHARED)
-- Primitiva 5 de la API de Corpus (CORPUS_Architecture.md §3). Los módulos se
-- registran en autorun, que en Gmod corre siempre antes de InitPostEntity — por
-- eso, cuando la barrera dispara, todos los módulos presentes ya están en el
-- registro: punto seguro para wiring de soft-deps que corre UNA sola vez.
--
-- LA BARRERA NO CUELGA DE UN SOLO HOOK, y no es defensa especulativa: es COR-5
-- (detección, nunca asunción) aplicada al propio framework. Hasta el 2026-08-08
-- esto era `hook.Add("InitPostEntity", ...)` a secas y **ese hook no llega al
-- realm CLIENTE** — medido tres veces en juego (dev/VEREDICTO_ready_barrier_cliente.md):
-- `corpus_selftest_cl` daba readyFired=false, y en dos arranques enteros ninguna
-- de las líneas `(…, client)` de los cross-registros salió en el console.log.
-- Se perdían 4.413 defs (4 médicas, 15 de comida, 4.394 de attachments ARC9) y
-- las 3 barras del StatusPanel, **sin un solo error de Lua**: un wiring que no
-- corre no se parece a una falla, se parece a un módulo que no registró nada.
-- En el mismo realm cliente `Initialize` SÍ dispara (de ahí salen los `cargado
-- (client)` de los cuatro módulos), así que no era orden de carga ni archivo
-- faltante: el archivo cargó, el hook quedó puesto, el evento no llegó.
--
-- EL HALLAZGO (2026-08-08, MEDIDO — ya no es una hipótesis). Dos lecturas del
-- selftest en el realm cliente, la segunda en un mapa recién cargado:
--     initPostEntity=NO llegó    mundoAlCargar=no
-- Leídas juntas cierran la pregunta que este header tuvo abierta:
--   · `mundoAlCargar=no` ⇒ cuando ESTE archivo cargó, el mundo todavía no
--     existía. `InitPostEntity` corre DESPUÉS de que las entidades existen, así
--     que en ese momento el evento no había ocurrido: **el hook quedó puesto a
--     tiempo.** (De paso: la premisa de la línea 3 de este header —autorun corre
--     antes que InitPostEntity— pasó de asunción a medición en el realm cliente.)
--   · `initPostEntity=NO llegó`, leído mucho después de conectar ⇒ desde
--     entonces **el evento no llegó nunca**.
-- ⇒ **El evento NO SE DISPARA en el realm CLIENTE de esta instalación.** Las dos
-- hipótesis que el arco B llevaba abiertas quedan resueltas: «llega tarde, el
-- respaldo le ganó» está DESCARTADA (la línea `llegó TARDE` nunca salió), y
-- **H1 —«el evento pasó antes de que registráramos el hook»— está MUERTA**, que
-- es justo lo que `mundoAlCargar` fue a medir.
--
-- LO QUE SIGUE SIN IDENTIFICAR, y es más chico que antes: si esto es conducta de
-- GMod en listen server o un tercero de los montados. Del barrido de `dev/other/`
-- (2026-08-08): **ningún** addon hace `hook.Remove("InitPostEntity", ...)`,
-- ninguno pisa `hook.Add/Remove/Call/Run` ni el método `GAMEMODE.InitPostEntity`,
-- y los cuatro `hook.GetTable()[...]` que hay leen otros eventos (`CalcView`,
-- `PostPlayerDraw`, `Think`) sin mutar nada. **Descartado NO es probado**:
-- `dev/other/` no tiene los 380 addons suscritos (misma lección que
-- `leer-el-gma-del-tercero-en-vez-de-inferirlo`). Pero ojo con el tamaño de lo
-- que quedaría: nadie nos desengancha POR NOMBRE, así que un tercero tendría que
-- estar matando el evento para TODOS — y entonces da igual quién sea, porque el
-- hecho medido (no llega) es el mismo y el remedio también.
--
-- TESTIGOS AJENOS, gratis y sin escribir código: si el evento no llega al realm
-- cliente, el `bm_init` CLIENT de Better Movement (`sh_bm_main.lua:226`) y el
-- `NetworkLoadout()` de arranque de Quick Loadouts (`cl_loadoutmenu.lua:1822`)
-- están muertos por la misma causa. Verlos fallar confirmaría que esto no es
-- nuestro; no hace falta para operar.
--
-- POR ESO EL RESPALDO NO ES UN PARCHE: es la ruta normal de este realm. La
-- barrera no está rodeando un defecto sospechado sino **una ausencia medida**,
-- y eso es COR-5 con evidencia en vez de con prudencia. `fuente=fallback` en el
-- cliente es lo ESPERADO; si algún día dijera `InitPostEntity`, es noticia.

Corpus = Corpus or {}
Corpus._readyFired = Corpus._readyFired or false
Corpus._readyQueue = Corpus._readyQueue or {}
-- Qué señal disparó la barrera, para que el log lo acredite en vez de que haya
-- que deducirlo: "InitPostEntity" | "fallback" | nil si todavía no disparó.
Corpus._readySource = Corpus._readySource or nil
-- ¿El evento LLEGÓ a este realm, aunque no haya sido el que disparó? `fuente`
-- sola no lo dice: `fallback` solo acredita quién ganó la carrera, y por lo
-- tanto NO distingue «InitPostEntity nunca llega a este realm» de «llega, pero
-- después del primer Think». Esa distinción ES la pregunta abierta del arco B
-- (dev/PROMPT_quickslots_x0_e_initpostentity.txt §5), y sin esta bandera no hay
-- con qué contestarla: el respaldo la tapaba.
Corpus._initPostEntitySeen = Corpus._initPostEntitySeen or false

-- ¿Ya existía el mundo cuando ESTE archivo cargó? Es lo único que separa las dos
-- causas que siguen empatadas después de medir `initPostEntity=NO llegó` el
-- 2026-08-08 — porque en las DOS la bandera de arriba queda en falso:
--   (H1) el evento pasó ANTES de que registráramos el hook, o
--        el evento no dispara nunca en este realm.
-- La inferencia es del orden, no del engine: `InitPostEntity` corre DESPUÉS de
-- que las entidades existen. Si el mundo ya existe acá, el evento pudo haber
-- pasado y H1 queda viva; si NO existe, el evento todavía no había ocurrido
-- cuando pusimos el hook — o sea que el hook estaba puesto a tiempo y el evento
-- simplemente nunca llegó. Se mide UNA vez, en file-scope, que es el momento del
-- que se quiere hablar: leerlo más tarde contestaría otra pregunta.
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
