-- corpus_data.lua — Persistencia namespaced (SHARED)
-- Primitiva 2 de la API de Corpus (CORPUS_Architecture.md §3).
-- Superficie: Save · Load · List · Delete, las cuatro con `opts` opcional.
-- Ruta resultante: data/corpus/<module>/<key>.json — un módulo nunca escribe
-- fuera de su propio namespace (contrato 3 del CLAUDE.md, COR-3).
--
-- SCOPE (COR-19) — `opts = { scope = "config" | "save" }`. "config" es config de
-- SERVIDOR: catálogos y overrides que sobreviven a borrar una partida. "save" es
-- ESTADO DE PARTIDA: muere con ella. HOY los dos resuelven a la MISMA carpeta a
-- propósito (ver RutaDe): el gancho existe para que el ecosistema declare su
-- scope sin que se mueva un solo archivo. El layout de perfiles llega después y
-- solo toca esa función.
-- Ausente significa "save" porque el estado de partida es la mayoría de los call
-- sites y es el que se MUEVE: un módulo que nunca se enteró de este parámetro
-- queda del lado correcto solo. Un scope desconocido es un error(), no un
-- silencio — es la clase de typo que mandaría un archivo a la carpeta equivocada
-- el día que las dos rutas dejen de coincidir.
--
-- Contrato DISTINTO al del registro: acá NO hay garantía by-ref ni identidad en
-- el round-trip. Load devuelve una tabla NUEVA parseada del JSON, con la
-- normalización propia de util.JSONToTable (p.ej. claves numéricas en string
-- pueden volver como number). El módulo que necesite tipos de clave exactos
-- re-normaliza al cargar.

Corpus = Corpus or {}
Corpus.Data = Corpus.Data or {}

local SCOPES = { config = true, save = true }

-- charset seguro de nombre de archivo: bloquea separadores y path traversal.
-- Se fuerza minúscula porque el filesystem de data/ no distingue mayúsculas.
local function sanear(valor, quien, campo)
    if not isstring(valor) or not valor:match("^[%w_%-]+$") then
        error(quien .. ": '" .. campo .. "' debe ser un string no vacío de [a-z0-9_-]", 3)
    end
    return valor:lower()
end

-- scope pedido en opts, validado. Ausente = "save" (ver el header).
local function saneaScope(opts, quien)
    if opts == nil then return "save" end
    if not istable(opts) then
        error(quien .. ": 'opts' debe ser una tabla { scope = ... }", 3)
    end
    if opts.scope == nil then return "save" end
    if not SCOPES[opts.scope] then
        error(quien .. ": scope desconocido '" .. tostring(opts.scope)
            .. "' — los válidos son \"config\" y \"save\"", 3)
    end
    return opts.scope
end

local function RutaDe(module, scope)
    -- Los dos scopes resuelven a la MISMA carpeta a propósito. El gancho de
    -- perfil se activa más adelante y solo toca esta función: por eso el resto
    -- del ecosistema puede declarar su scope hoy sin que se mueva un archivo.
    return "corpus/" .. module
end

function Corpus.Data.Save(module, key, tbl, opts)
    module = sanear(module, "Corpus.Data.Save", "module")
    key = sanear(key, "Corpus.Data.Save", "key")
    local scope = saneaScope(opts, "Corpus.Data.Save")
    if not istable(tbl) then
        error("Corpus.Data.Save: 'tbl' debe ser una tabla (" .. module .. "/" .. key .. ")", 2)
    end

    local dir = RutaDe(module, scope)
    file.CreateDir(dir)
    file.Write(dir .. "/" .. key .. ".json", util.TableToJSON(tbl, true))
end

function Corpus.Data.Load(module, key, opts)
    module = sanear(module, "Corpus.Data.Load", "module")
    key = sanear(key, "Corpus.Data.Load", "key")
    local scope = saneaScope(opts, "Corpus.Data.Load")

    local ruta = RutaDe(module, scope) .. "/" .. key .. ".json"
    local crudo = file.Read(ruta, "DATA")
    if crudo == nil then return nil end

    local tbl = util.JSONToTable(crudo)
    if tbl == nil then
        Corpus.Log(module, "Data.Load: JSON corrupto en data/" .. ruta .. " — se devuelve nil")
    end
    return tbl
end

-- Claves del namespace (sin la extensión), ordenadas alfabéticamente. Sin
-- carpeta o sin archivos devuelve {}, JAMÁS nil: quien la llame va a iterarla.
function Corpus.Data.List(module, opts)
    module = sanear(module, "Corpus.Data.List", "module")
    local scope = saneaScope(opts, "Corpus.Data.List")

    local keys = {}
    local archivos = file.Find(RutaDe(module, scope) .. "/*.json", "DATA")
    if archivos == nil then return keys end

    for _, nombre in ipairs(archivos) do
        local key = nombre:match("^(.+)%.json$")
        if key ~= nil then keys[#keys + 1] = key end
    end
    table.sort(keys)
    return keys
end

-- Borra la clave; devuelve true si el archivo existía y false si no. Sanea con
-- el MISMO `sanear` que Save y Load: es lo que bloquea el path traversal, y una
-- primitiva de borrado sin ese saneo es un agujero, no una comodidad.
function Corpus.Data.Delete(module, key, opts)
    module = sanear(module, "Corpus.Data.Delete", "module")
    key = sanear(key, "Corpus.Data.Delete", "key")
    local scope = saneaScope(opts, "Corpus.Data.Delete")

    local ruta = RutaDe(module, scope) .. "/" .. key .. ".json"
    if not file.Exists(ruta, "DATA") then return false end
    file.Delete(ruta)
    return true
end
