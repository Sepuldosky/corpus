-- corpus_log.lua — Log con prefijo por módulo (SHARED)
-- Primitiva 6 de la API de Corpus (CORPUS_Architecture.md §3): identifica el
-- origen de un mensaje sin adivinar, con los cinco módulos montados a la vez.

Corpus = Corpus or {}

function Corpus.Log(module, ...)
    print("[Corpus:" .. tostring(module) .. "] ", ...)
end
