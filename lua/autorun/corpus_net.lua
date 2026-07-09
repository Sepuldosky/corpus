-- corpus_net.lua — Namespacing de mensajes de red (SHARED)
-- Primitiva 3 de la API de Corpus (CORPUS_Architecture.md §3). El namespace de
-- net.Receive es global en Gmod; el prefijo corpus_<module>_ evita colisión
-- entre los cinco módulos. util.AddNetworkString solo existe en server; el
-- cliente igual necesita esta función para construir el mismo nombre completo
-- en su net.Receive.

Corpus = Corpus or {}
Corpus.Net = Corpus.Net or {}

function Corpus.Net.Register(module, msgName)
    if not isstring(module) or module == "" then
        error("Corpus.Net.Register: 'module' debe ser un string no vacío", 2)
    end
    if not isstring(msgName) or msgName == "" then
        error("Corpus.Net.Register: 'msgName' debe ser un string no vacío", 2)
    end

    local fullName = "corpus_" .. module .. "_" .. msgName
    if SERVER then
        -- idempotente: repetir el mismo string no es error ni duplica el pool
        util.AddNetworkString(fullName)
    end
    return fullName
end
