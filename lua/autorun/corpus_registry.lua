-- corpus_registry.lua — Registro de módulos (SHARED)
-- Primitiva 1 de la API de Corpus (CORPUS_Architecture.md §3): linchpin de las
-- soft-deps — es a la vez el mecanismo de detección de presencia y la ruta de
-- acceso al módulo (§6). Cada archivo del framework crea el global si no existe:
-- ninguno asume orden de carga dentro de lua/autorun/.

Corpus = Corpus or {}
Corpus._modules = Corpus._modules or {}

-- INVARIANTE (contrato duro — CORPUS_Architecture.md §3, Caliber_Architecture.md §11):
-- RegisterModule guarda y GetModule devuelve la MISMA tabla por referencia, sin
-- deep-copy ni normalización de ningún tipo. El patrón "tabla única poblada por
-- side-effect" de los módulos (todos sus archivos cachean la referencia y le
-- cuelgan funciones) se cae en silencio si esto alguna vez copia.
function Corpus.RegisterModule(name, iface)
    if not isstring(name) or name == "" then
        error("Corpus.RegisterModule: 'name' debe ser un string no vacío", 2)
    end
    if not istable(iface) then
        error("Corpus.RegisterModule: 'iface' debe ser una tabla (módulo '" .. name .. "')", 2)
    end

    if Corpus._modules[name] ~= nil and Corpus._modules[name] ~= iface then
        -- re-registro con tabla nueva: esperable en lua refresh; se reemplaza para
        -- que los archivos del módulo pueblen la tabla vigente, no una huérfana
        Corpus.Log(name, "módulo re-registrado; se reemplaza la interfaz anterior")
    end

    Corpus._modules[name] = iface
end

function Corpus.HasModule(name)
    return Corpus._modules[name] ~= nil
end

function Corpus.GetModule(name)
    return Corpus._modules[name]
end
