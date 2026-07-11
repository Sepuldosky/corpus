# .claude/desktop-sync/ — bundle de re-sincronización Code→Desktop

Destino físico del **seam Code↔Desktop** descrito en
[`docs/corpus_flujo_trabajo.txt §6`](../../docs/corpus_flujo_trabajo.txt).

## Qué es

El diseño de un módulo se autora en **Claude Desktop** (RAG, recall amplio sobre los
docs del ecosistema); **Claude Code** en VSCode verifica contra el árbol real y aplica.
Desktop trabaja sobre una copia read-only del proyecto: razona sobre lo que tenga cargado
en su Project. Para que no razone sobre docs stale, la sesión de Code deposita acá un
snapshot de los docs del ecosistema; el autor (Matías) los arrastra al Project
**"Corpus Framework"** en Claude Desktop para refrescar el RAG.

Dos usos del mismo seam (§6.1):

- **Sembrar** una sesión de diseño nueva — p.ej. abrir el Block 4 de **Cargo** (inventario
  grid + framework de ítems, ver `CORPUS_Architecture.md §5`). El bundle lleva todo el
  contexto de framework que Desktop necesita para autorar.
- **Re-sincronizar** tras una tanda que tocó docs publicados o cerró un bloque. El bundle
  lleva la foto ya reconciliada.

## Contenido esperado del bundle

- Docs vivos del framework: `corpus_estado.md`, `corpus_roadmap.txt`, `CHANGELOG.md`,
  `corpus_flujo_trabajo.txt`, `CORPUS_Architecture.md`, `corpus_convenciones_commits.txt`
- `CLAUDE.md` — contratos no-negociables del framework
- Si la tanda cruzó a un repo hermano: sus docs vivos también
- `_SYNC_INDEX.md` — generado, con el **SHA de main** que refleja + fecha + lista de
  archivos + qué se bumpeó desde el último sync

## Reglas

- **Snapshot regenerable, no fuente de verdad.** La verdad vive en el repo; esto es una
  copia anclada a un SHA. Se **sobrescribe** en cada tanda.
- **Gitignoreado** salvo este README (ver `.gitignore`): los snapshots NO se commitean.
- **Multi-repo:** por defecto el bundle refleja `corpus/`. Al sembrar/reconciliar el
  diseño de un módulo, incluí también los docs vivos de su repo hermano cuando existan.

## Regenerar el bundle

El helper [`sync.ps1`](sync.ps1) hace todo de un tiro: copia los docs vivos del framework
y regenera el `_SYNC_INDEX.md` con el HEAD real, la fecha, la lista de archivos y los
deltas sin commitear que detecta (compara working tree vs. HEAD).

```powershell
# desde la raíz del repo corpus/
.\.claude\desktop-sync\sync.ps1 -Purpose "sembrar la sesion de diseno de Cargo (Block 4)"

# sin -Purpose usa un texto genérico de re-sincronización
.\.claude\desktop-sync\sync.ps1
```

Es idempotente: sobrescribe los snapshots en cada corrida. `sync.ps1` y este README son lo
único versionado de la carpeta; el resto (docs + `_SYNC_INDEX.md`) queda gitignoreado.
