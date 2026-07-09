-- corpus_selftest.lua — Validación en consola de las primitivas (SHARED)
-- Comando de validación estilo auto-test de ADS (ads_armor.lua): cubre el PASO 4
-- del flujo de trabajo sin armar el escenario a mano. Uso:
--   consola del server dedicado (o rcon):  corpus_selftest
--   consola del cliente:                   corpus_selftest   (corre el realm CLIENT)
--   listen server, realm SERVER:           lua_run Corpus._SelfTest()
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

    -- 3) Net: nombre namespaced; se registra DOS veces para confirmar que
    -- repetir el registro no tira error de red duplicada
    local full = Corpus.Net.Register("selftest", "ping")
    Corpus.Net.Register("selftest", "ping")
    check(r, "net: namespacing", full == "corpus_selftest_ping", full)

    -- 4) Ready: post-InitPostEntity la suscripción corre inmediata, una sola vez
    local corridas = 0
    Corpus.OnReady(function() corridas = corridas + 1 end)
    check(r, "ready: dispara una vez", Corpus._readyFired == true and corridas == 1,
        "readyFired=" .. tostring(Corpus._readyFired) .. " corridas=" .. tostring(corridas))

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
