-- corpus_ready.lua — Ready barrier (SHARED)
-- Primitiva 5 de la API de Corpus (CORPUS_Architecture.md §3). Los módulos se
-- registran en autorun, que en Gmod corre siempre antes de InitPostEntity — por
-- eso, cuando la barrera dispara, todos los módulos presentes ya están en el
-- registro: punto seguro para wiring de soft-deps que corre UNA sola vez.

Corpus = Corpus or {}
Corpus._readyFired = Corpus._readyFired or false
Corpus._readyQueue = Corpus._readyQueue or {}

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

hook.Add("InitPostEntity", "corpus_ready_barrier", function()
    Corpus._readyFired = true

    for _, fn in ipairs(Corpus._readyQueue) do
        -- pcall: un callback roto de un módulo no debe frenar el wiring del resto
        local ok, err = pcall(fn)
        if not ok then
            Corpus.Log("corpus", "error en callback de OnReady: " .. tostring(err))
        end
    end

    Corpus._readyQueue = {}
end)
