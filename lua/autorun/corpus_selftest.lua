-- corpus_selftest.lua — Validación en consola de las primitivas (SHARED)
-- Comando de validación estilo auto-test de ADS (ads_armor.lua): cubre el PASO 4
-- del flujo de trabajo sin armar el escenario a mano. Uso:
--   consola del server dedicado (o rcon):  corpus_selftest
--   listen server, realm SERVER:           corpus_selftest, o lua_run Corpus._SelfTest()
--   listen server, realm CLIENT:           corpus_selftest_cl
-- POR QUÉ HAY DOS NOMBRES, y no es cosmético (pagado en juego el 2026-07-25,
-- planilla T4, dos rondas): este archivo es shared, así que `corpus_selftest`
-- queda registrado en los DOS realms y en un listen server gana el del SERVER —
-- tipearlo en la consola del host devuelve el bloque (SERVER) y jamás llega al
-- cliente. `lua_run_cl` tampoco es salida: lo gatea `sv_allowcslua`, que viene
-- en 0 y no se cambia por correr un test. Sin un nombre propio, el realm CLIENT
-- del framework era INVERIFICABLE en juego, que es como un check verde terminó
-- reportando dos veces el mismo realm.
-- El tab de UI (primitiva 4) se verifica visual: menú Q → Utilities → Corpus.

Corpus = Corpus or {}

local function check(resultados, nombre, ok, detalle)
    resultados[#resultados + 1] = { nombre = nombre, ok = ok, detalle = detalle }
end

-- interno / off-contract: existe solo para poder invocarlo vía lua_run
function Corpus._SelfTest()
    local realm = SERVER and "SERVER" or "CLIENT"
    local r = {}

    -- 1) Registro: invariante by-ref — se muta la tabla DESPUÉS de registrar y
    -- el cambio debe leerse desde la referencia que devuelve GetModule
    local dummy = {}
    Corpus.RegisterModule("selftest", dummy)
    dummy.marca = 123
    local ref = Corpus.GetModule("selftest")
    check(r, "registry: invariante by-ref", ref == dummy and ref.marca == 123,
        "GetModule debe devolver la MISMA tabla registrada")
    check(r, "registry: HasModule",
        Corpus.HasModule("selftest") == true and Corpus.HasModule("no_existe") == false)
    Corpus._modules["selftest"] = nil -- limpieza: el dummy no queda registrado

    -- 2) Persistencia: round-trip + archivo en la ruta del contrato
    Corpus.Data.Save("selftest", "prueba", { hola = "mundo", n = 42 })
    local cargado = Corpus.Data.Load("selftest", "prueba")
    check(r, "data: round-trip",
        istable(cargado) and cargado.hola == "mundo" and cargado.n == 42)
    check(r, "data: ruta", file.Exists("corpus/selftest/prueba.json", "DATA"),
        "data/corpus/selftest/prueba.json")

    -- 2b) List y Delete. El bloque deja el namespace `selftest` LIMPIO al
    -- terminar: un selftest que ensucia el disco del autor es un defecto.
    local claves = Corpus.Data.List("selftest")
    local vista = false
    for _, k in ipairs(claves) do
        if k == "prueba" then vista = true end
    end
    check(r, "data: List encuentra la clave escrita", vista,
        "claves: " .. table.concat(claves, ", "))
    check(r, "data: Delete devuelve true si existía",
        Corpus.Data.Delete("selftest", "prueba") == true)
    check(r, "data: Delete devuelve false si no existía",
        Corpus.Data.Delete("selftest", "prueba") == false)
    check(r, "data: Load post-Delete devuelve nil",
        Corpus.Data.Load("selftest", "prueba") == nil)

    -- 2c) Scope (COR-19): round-trip declarando config, y la constatación de que
    -- HOY los dos scopes resuelven a la misma ruta a propósito — el gancho de
    -- perfil está puesto, no activado.
    Corpus.Data.Save("selftest", "scoped", { s = 1 }, { scope = "config" })
    check(r, "data: scope config round-trip",
        istable(Corpus.Data.Load("selftest", "scoped", { scope = "config" })))
    check(r, "data: los dos scopes resuelven igual por ahora",
        istable(Corpus.Data.Load("selftest", "scoped")))
    check(r, "data: scope desconocido tira error",
        pcall(Corpus.Data.Load, "selftest", "scoped", { scope = "partida" }) == false)
    Corpus.Data.Delete("selftest", "scoped", { scope = "config" })

    -- 3) Net: nombre namespaced; se registra DOS veces para confirmar que
    -- repetir el registro no tira error de red duplicada
    local full = Corpus.Net.Register("selftest", "ping")
    Corpus.Net.Register("selftest", "ping")
    check(r, "net: namespacing", full == "corpus_selftest_ping", full)

    -- 4) Ready: pasada la barrera, la suscripción corre inmediata y una sola vez
    local corridas = 0
    Corpus.OnReady(function() corridas = corridas + 1 end)
    -- `hookIPE=` NO es un criterio: es el dato del arco B viajando en el
    -- detalle de un check que ya se corre. Un check propio sería o un verde que
    -- no mide (si siempre pasa) o un rojo que reprueba a la barrera por
    -- funcionar por su respaldo, que es exactamente lo que se diseñó. `fuente`
    -- dice quién ganó la carrera; esto dice si el otro corredor arrancó.
    --
    -- EL RÓTULO SE LLAMABA `initPostEntity=llegó | NO llegó` Y ESE NOMBRE COSTÓ
    -- UNA RONDA (renombrado el 2026-08-09). La bandera la escribe el propio
    -- callback de la barrera, así que sólo puede medir **si NUESTRO hook corrió**;
    -- nombrarla por el EVENTO invitaba a leer «no llegó» como «el evento no se
    -- disparó», y así se cerró el arco B el 2026-08-08 — mal: el `console.log`
    -- muestra a un tercero corriendo su callback de `InitPostEntity` en el mismo
    -- realm y el mismo arranque (ver el header de `corpus_ready.lua`). Un
    -- instrumento se nombra por lo que TOCA, no por lo que uno querría concluir.
    check(r, "ready: dispara una vez", Corpus._readyFired == true and corridas == 1,
        "readyFired=" .. tostring(Corpus._readyFired) .. " corridas=" .. tostring(corridas)
            .. " fuente=" .. tostring(Corpus._readySource)
            .. " hookIPE=" .. (Corpus._initPostEntitySeen and "corrió" or "NO corrió")
            .. " mundoAlCargar=" .. (Corpus._worldAtLoad and "sí" or "no"))

    -- La cola colgada mide el DAÑO, no solo el hecho. El check de arriba decía
    -- "la barrera no disparó" y nada más; el 2026-08-08 lo que había detrás eran
    -- 4.413 defs y 3 barras que nunca se registraron en el realm que dibuja
    -- (dev/VEREDICTO_ready_barrier_cliente.md). Disparada la barrera, OnReady
    -- corre por el fast-path y la cola queda vacía para siempre: un número
    -- distinto de cero acá es trabajo de módulo perdido, contado.
    check(r, "ready: no quedan wirings colgados", #Corpus._readyQueue == 0,
        "_readyQueue=" .. #Corpus._readyQueue)

    -- 5) Log: check visual del prefijo en la línea siguiente
    Corpus.Log("selftest", "línea de prueba — el prefijo [Corpus:selftest] es el contrato")

    local fallas = 0
    print("[Corpus] ===== selftest (" .. realm .. ") =====")
    for _, res in ipairs(r) do
        if not res.ok then fallas = fallas + 1 end
        print(string.format("[Corpus]  [%s] %s%s", res.ok and "OK" or "FALLO",
            res.nombre, res.detalle and (" — " .. tostring(res.detalle)) or ""))
    end
    if CLIENT then
        print("[Corpus]  [--] ui: check visual — menú Q → Utilities → categoría Corpus")
    end
    print("[Corpus] ===== " .. (fallas == 0 and "todo OK" or (fallas .. " falla(s)")) .. " =====")
end

concommand.Add("corpus_selftest", function(ply)
    -- en server, solo consola/superadmin: escribe en data/ y toca el pool de red
    if SERVER and IsValid(ply) and not ply:IsSuperAdmin() then return end
    Corpus._SelfTest()
end)

-- Alias CLIENT-only. Nombre propio a propósito: es lo único que no colisiona con
-- el registro del server en un listen server (ver el header). Sin gate de
-- superadmin porque no hay a quién proteger — corre en la máquina del que lo
-- tipea, escribe en SU data/ y limpia lo que escribió.
if CLIENT then
    concommand.Add("corpus_selftest_cl", function()
        Corpus._SelfTest()
    end)
end
