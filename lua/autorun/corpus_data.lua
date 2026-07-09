-- corpus_data.lua — Persistencia namespaced (SHARED)
-- Primitiva 2 de la API de Corpus (CORPUS_Architecture.md §3).
-- Ruta resultante: data/corpus/<module>/<key>.json — un módulo nunca escribe
-- fuera de su propio namespace (contrato 3 del CLAUDE.md).
--
-- Contrato DISTINTO al del registro: acá NO hay garantía by-ref ni identidad en
-- el round-trip. Load devuelve una tabla NUEVA parseada del JSON, con la
-- normalización propia de util.JSONToTable (p.ej. claves numéricas en string
-- pueden volver como number). El módulo que necesite tipos de clave exactos
-- re-normaliza al cargar.

Corpus = Corpus or {}
Corpus.Data = Corpus.Data or {}

-- charset seguro de nombre de archivo: bloquea separadores y path traversal.
-- Se fuerza minúscula porque el filesystem de data/ no distingue mayúsculas.
local function sanear(valor, quien, campo)
    if not isstring(valor) or not valor:match("^[%w_%-]+$") then
        error(quien .. ": '" .. campo .. "' debe ser un string no vacío de [a-z0-9_-]", 3)
    end
    return valor:lower()
end

function Corpus.Data.Save(module, key, tbl)
    module = sanear(module, "Corpus.Data.Save", "module")
    key = sanear(key, "Corpus.Data.Save", "key")
    if not istable(tbl) then
        error("Corpus.Data.Save: 'tbl' debe ser una tabla (" .. module .. "/" .. key .. ")", 2)
    end

    file.CreateDir("corpus/" .. module)
    file.Write("corpus/" .. module .. "/" .. key .. ".json", util.TableToJSON(tbl, true))
end

function Corpus.Data.Load(module, key)
    module = sanear(module, "Corpus.Data.Load", "module")
    key = sanear(key, "Corpus.Data.Load", "key")

    local ruta = "corpus/" .. module .. "/" .. key .. ".json"
    local crudo = file.Read(ruta, "DATA")
    if crudo == nil then return nil end

    local tbl = util.JSONToTable(crudo)
    if tbl == nil then
        Corpus.Log(module, "Data.Load: JSON corrupto en data/" .. ruta .. " — se devuelve nil")
    end
    return tbl
end
