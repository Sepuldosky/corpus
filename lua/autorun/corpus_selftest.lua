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

    -- 6) Interact (primitiva 7). Es la MITAD DE MOTOR de §10 del doc de
    -- interacción: la lógica pura la cubre dev/harness_corpus.py con 440 checks, y
    -- lo que sólo se puede ver acá es que el archivo cargue de verdad en el
    -- engine, que las convars EXISTAN en la consola del jugador y que el registro
    -- las cree al vuelo.
    --
    -- ⚠⚠ CORRE SOBRE UN PADRÓN PRESTADO Y RESTAURA EL REAL. Sin esto, tipear
    -- `corpus_selftest` con módulos ya cargados les BORRARÍA sus acciones — un
    -- test que rompe el juego para medirlo. Se guarda por referencia y se
    -- devuelve al terminar, pase lo que pase con los checks de abajo.
    local padronReal = Corpus.Interact._nodes
    local logueadosReal = Corpus.Interact._orphansLogged
    local accionesDeModulos = 0
    for _ in pairs(padronReal) do accionesDeModulos = accionesDeModulos + 1 end
    Corpus.Interact._nodes = {}
    Corpus.Interact._orphansLogged = {}

    local okInteract, errInteract = pcall(function()
        -- (a) la fila de guardas rechaza con MOTIVO, no con un nil pelado. Los
        -- rechazos son además lo BARATO de probar en juego: no llegan a crear una
        -- convar, así que no dejan nada atrás.
        local nodo, motivo = Corpus.Interact.Register("selftest",
            { id = "x", label = "X", tree = "no_existe", run = function() end })
        check(r, "interact: un tree invalido se rechaza CON motivo",
            nodo == nil and isstring(motivo) and motivo:find("'tree'", 1, true) ~= nil,
            "motivo=" .. tostring(motivo))
        check(r, "interact: un run ausente se rechaza",
            select(1, Corpus.Interact.Register("selftest",
                { id = "y", label = "Y", tree = "self" })) == nil)

        -- (b) el árbol, CONTADO contra un esperado. Un árbol vacío tiene que ser
        -- una medición: preguntar "¿resolvió?" saldría verde con cero nodos.
        Corpus.Interact.Register("selftest", { id = "selftest_root", label = "Root",
            tree = "interaction", run = function() end })
        Corpus.Interact.Register("selftest", { id = "selftest_a", label = "A",
            tree = "interaction", parent = "selftest_root", order = 20, run = function() end })
        Corpus.Interact.Register("selftest", { id = "selftest_b", label = "B",
            tree = "interaction", parent = "selftest_root", order = 10, run = function() end })
        Corpus.Interact.Register("selftest", { id = "selftest_orphan", label = "Orphan",
            tree = "interaction", parent = "no_existe_jamas", run = function() end })

        local t = Corpus.Interact.Resolve("interaction")
        check(r, "interact: el arbol resuelve 4 nodos, 1 raiz, 2 hijos y 1 huerfano",
            t.count == 4 and #t.roots == 1 and t.children["selftest_root"] ~= nil
                and #t.children["selftest_root"] == 2 and #t.orphans == 1,
            "count=" .. t.count .. " roots=" .. #t.roots
                .. " hijos=" .. (t.children["selftest_root"] and #t.children["selftest_root"] or 0)
                .. " huerfanos=" .. #t.orphans)
        check(r, "interact: los hermanos salen ordenados por order",
            t.children["selftest_root"][1].id == "selftest_b",
            "primero=" .. tostring(t.children["selftest_root"][1].id) .. " (esperado selftest_b)")
        check(r, "interact: el huerfano es el que cuelga de la nada",
            t.orphans[1] ~= nil and t.orphans[1].id == "selftest_orphan")
        check(r, "interact: 2 hijos ⇒ regimen de arco",
            t.regime["selftest_root"] == "arc", "regimen=" .. tostring(t.regime["selftest_root"]))
        check(r, "interact: la rama command nace VACIA y lo dice con un numero",
            Corpus.Interact.Resolve("command").count == 0)

        -- (c) LAS PERILLAS, y esto es lo que SÓLO se puede acreditar acá. El
        -- harness offline guarda nombre y valor y no mira los flags, así que el
        -- FCVAR_REPLICATED le es invisible por construcción. Lo que esta pasada
        -- prueba es lo de al lado y no es poco: que las convars EXISTEN en la
        -- consola de verdad y que las crea el REGISTRO — las cuatro
        -- `corpus_interact_action_selftest_*` no están escritas en ninguna lista.
        local maestra = GetConVar("corpus_interact_enabled")
        check(r, "interact: la perilla maestra existe en la consola",
            maestra ~= nil, "corpus_interact_enabled")
        local propia = GetConVar("corpus_interact_action_selftest_a")
        check(r, "interact: el REGISTRO creo la perilla de la accion",
            propia ~= nil, "corpus_interact_action_selftest_a")
        check(r, "interact: Enabled compone maestra x accion",
            Corpus.Interact.Enabled("selftest_a") == true
                and Corpus.Interact.Enabled("no_registrada") == false)
    end)
    if not okInteract then
        check(r, "interact: el bloque reventó", false, tostring(errInteract))
    end

    -- Restaurar SIEMPRE, haya reventado o no: el padrón de los módulos no puede
    -- quedar como daño colateral de un test.
    Corpus.Interact._nodes = padronReal
    Corpus.Interact._orphansLogged = logueadosReal
    check(r, "interact: el selftest devolvio el padron real intacto",
        Corpus.Interact._nodes == padronReal)

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

    -- DATO y no criterio, a propósito: hoy tiene que dar CERO porque ningún módulo
    -- cablea acciones hasta la tanda 4 (COR-1: las acciones son de cada módulo, no
    -- del framework). Un cero acá no es una falla, y ponerlo como check lo
    -- volvería un rojo permanente sobre un mecanismo sano. El día que un módulo
    -- registre la primera, esta línea es lo que lo delata sin tocar nada.
    print("[Corpus]  [--] interact: " .. accionesDeModulos
        .. " accion(es) registradas por módulos (0 es lo esperado hasta la tanda 4)")

    print("[Corpus] ===== " .. (fallas == 0 and "todo OK" or (fallas .. " falla(s)")) .. " =====")

    -- DEVUELVE EL VEREDICTO, y no es cosmético: sin retorno, un instrumento que
    -- llame a esta función sólo puede preguntar "¿corrió?" —que es lo que contesta
    -- el primer valor de un pcall— y jamás "¿salió bien?". Son la misma palabra en
    -- castellano y dos preguntas distintas, y la barata es la que el código
    -- termina haciendo. Es lo que hacen los tres módulos hermanos.
    return fallas == 0
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
