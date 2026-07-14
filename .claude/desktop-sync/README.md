# .claude/desktop-sync/ — espejo Code→Desktop (Project "Corpus Framework")

Destino físico del **seam Code↔Desktop** descrito en
[`docs/corpus_flujo_trabajo.txt §6`](../../docs/corpus_flujo_trabajo.txt).

## Qué es

El diseño de los módulos de Corpus se autora en el Project **"Corpus Framework"** de Claude
Desktop (RAG, recall amplio); Claude Code en VSCode verifica contra el árbol real y aplica.
Desktop razona sobre lo que tenga cargado en su Project — si queda stale, razona sobre una
foto vieja.

Esta carpeta es el **espejo completo** de ese contexto: la foto actual de **todos** los docs
del ecosistema que el Project debe contener. No es un bundle-delta (lo que cambió en una
tanda) sino un mirror autosuficiente. El flujo del autor es **borrar y reemplazar**: vaciar
el Project en Desktop y soltar el contenido de esta carpeta.

## Convención de nombres — prefijo de origen

Al aplanar siete repos en una sola carpeta, los nombres genéricos chocan (cada repo tiene su
`CHANGELOG.md` y su `CLAUDE.md`). Para evitarlo y declarar procedencia, **cada archivo lleva
prefijo `<Módulo>_`**:

- `Corpus_CHANGELOG.md`, `Cargo_CHANGELOG.md`, `Caliber_CHANGELOG.md`
- `Corpus_CLAUDE.md`, `Cargo_CLAUDE.md`, ...
- `Corpus_estado.md`, `Cargo_estado.md`, `Corpus_Architecture.md`, `Cargo_Architecture.md`

Los docs que ya nacen con el nombre del módulo se normalizan a esa forma sin duplicar el
prefijo. La metodología canónica `corpus_flujo_trabajo.txt` viaja como `Corpus_flujo_trabajo.txt`.

## Cobertura

Agrega todos los repos que ya tienen docs. El único que aún no (**Cortex**) se suma **solo**
cuando reciba su Block de diseño — el helper recorre las **siete** raíces de repo del
ecosistema (`corpus` + los cinco módulos + `corpus-stalker`, el addon de contenido de la Zona)
y saltea las vacías, no hay que editarlo. Cada repo es un git independiente y se estampa con
su propio SHA (+ estado dirty) en el índice.

`corpus-stalker` entra al espejo aunque **no sea un módulo**: Desktop necesita su manifiesto de
assets y sus contratos para diseñar defs de ítem y sonidos contra la Zona.

Las subcarpetas de `docs/` (p.ej. `mockups/` en Cargo) **no** se aplanan automáticamente; el
`_SYNC_INDEX.md` las lista para arrastrarlas aparte si hacen falta.

## Regenerar

```powershell
# desde la raíz del repo corpus/
.\.claude\desktop-sync\sync.ps1
.\.claude\desktop-sync\sync.ps1 -Purpose "..."   # nota opcional de la tanda
```

Limpia el espejo, copia todos los docs con su prefijo y regenera `_SYNC_INDEX.md` con el SHA
y el estado de cada repo. `README.md` y `sync.ps1` son lo único versionado de la carpeta; el
resto queda gitignoreado.

## Reglas

- **Espejo regenerable, no fuente de verdad.** La verdad vive en cada repo; esto se
  **sobrescribe entero** en cada corrida.
- **Borrar y reemplazar en Desktop:** en el Project "Corpus Framework", vaciá el contenido
  actual y sustituilo por los archivos `<Módulo>_*` de esta carpeta (podés omitir `README.md`
  y `sync.ps1`, que son tooling).
