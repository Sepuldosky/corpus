# Corpus — CHANGELOG de parches (repo: corpus/)

> Registro de parches al código y a la documentación, por sesión de diseño.
> **Disciplina (heredada de Kontrol vía ADS 2.0):**
> - Un parche nace `[PENDIENTE]` y pasa a `[APLICADO YYYY-MM-DD]` cuando se aplica y
>   verifica. Para código de addon GMod, "verificado" = confirmado en juego (ver
>   [`corpus_flujo_trabajo.txt`](corpus_flujo_trabajo.txt)).
> - **Nunca** se borra una entrada. **Nunca** se renumera un parche existente.
> - Cada sesión de diseño abre su **propia subsección**, con numeración de parches
>   independiente de otras sesiones.
> - Estado vivo del proyecto → [`corpus_estado.md`](corpus_estado.md). Lo
>   `[PENDIENTE]` acá debe coincidir con lo pendiente allá.
> - Este CHANGELOG es de **este repo** (`corpus/`). Cada repo hermano abre el suyo
>   propio cuando empieza a recibir código.

---

## PARCHES DE sesión Bootstrap del workspace + metodología — 2026-07-08

Sesión de arranque del ecosistema: cierre de Block 1 (framework Corpus + grafo de
dependencias + workspace multi-root, diseño ya validado en sesión previa de
planificación), creación del workspace VSCode de seis raíces, y portación del flujo
de trabajo (planificación por bloques, vertical slice, convenciones de commit,
changelog) desde ADS 2.0 / Kontrol a Corpus.

- PARCHE 1 — Documento de arquitectura: `CORPUS_Architecture.md` (§1-§9) — framework,
  grafo de dependencias, superficie de API, fronteras de módulo, contrato de ítems,
  orden de carga, migración ADS→Caliber, workspace multi-root. **[APLICADO
  2026-07-08]**

- PARCHE 2 — Workspace multi-root: `corpus.code-workspace` + seis carpetas raíz
  (`corpus`, `corpus-cortex`, `corpus-caliber`, `corpus-coagulant`, `corpus-craving`,
  `corpus-cargo`) + carpeta `dev/` fuera de todo repo git, para mods de referencia y
  código que no se publica. **[APLICADO 2026-07-08]**

- PARCHE 3 — Docs de metodología: `CLAUDE.md`, `corpus_flujo_trabajo.txt`,
  `corpus_convenciones_commits.txt`, `corpus_estado.md`, `corpus_roadmap.txt`, este
  `CHANGELOG.md` — adaptados desde el equivalente de ADS 2.0
  (`ads_flujo_trabajo.txt` / `ads_convenciones_commits.txt` / etc., a su vez
  portados de Kontrol), generalizados para el workspace multi-repo de Corpus.
  **[APLICADO 2026-07-08]**

- PARCHE 4 — Legacy ADS 2.0 + VMT Editor movidos a `dev/legacy/` como material de
  referencia: mod antiguo a revisar/mejorar dentro de Corpus (ver §7 de la
  arquitectura, migración ADS→Caliber), junto con los mods de terceros que ya traía
  en su propio `dev/` interno. **[APLICADO 2026-07-08]**

- PARCHE 5 — Reorganización de `dev/`: los mods de terceros (VJ Base, ARC9 EFT,
  zbase, drgbase, halo energy shield, visceral dynamic blood, etc.) que vivían
  anidados en `dev/legacy/AdvancedDamageSystem 2.0/dev/` se subieron a `dev/other/`,
  al nivel del resto del workspace. **[APLICADO 2026-07-08]**

- PARCHE 6 — `git init` corrido en los seis repos del workspace (`corpus` + los
  cinco hermanos). `corpus/` suma `.gitignore` y su primer commit con los docs de
  bootstrap; los cinco repos hermanos quedan inicializados sin commits, a la espera
  de su Block de diseño. Ningún repo tiene remote todavía. **[APLICADO 2026-07-08]**

- PARCHE 7 — Metodología: `corpus_flujo_trabajo.txt` y `CLAUDE.md` reconocen ahora
  el patrón doc de arquitectura GENERAL vs. PARTICULAR (precedente: en ADS,
  `ADS_2_0_Architecture_updated.md` + `ADS_EnergyShields_Arquitectura.md`, patrón que
  nunca quedó escrito en su propio `ads_flujo_trabajo.txt`). Se agrega
  `<modulo>_Architecture.md` a la plantilla de docs que recibe un repo hermano al
  cerrar su primer Block (antes faltaba), y se documenta el criterio para desprender
  un doc particular autocontenido cuando un subsistema lo amerita. **[APLICADO
  2026-07-08]**

- PARCHE 8 — Publicación en GitHub: los seis repos creados como públicos bajo
  `github.com/Sepuldosky/`. `corpus/` con remote `origin` y push de sus dos commits a
  `main`; los cinco repos hermanos creados vacíos en GitHub con `origin` cableado
  localmente, sin push (no tienen commits todavía). **[APLICADO 2026-07-08]**

Nota: sesión puramente de documentación y estructura de carpetas — cero código Lua
escrito. Ver [`corpus_estado.md`](corpus_estado.md) "Próximo paso" para la decisión
abierta sobre cuándo empieza la implementación.

---

## PARCHES DE sesión Implementación de las 6 primitivas — 2026-07-09

Block 1 baja a código (CC Prompt #1): las 6 primitivas de la API
(`CORPUS_Architecture.md` §3) implementadas en `lua/autorun/` — primera sesión de
código Lua del ecosistema. Realm: todo shared salvo la UI (client); nada resultó
exclusivamente server (el cliente necesita registro/net/ready/log para sus propios
archivos). Cada archivo es autosuficiente (`Corpus = Corpus or {}`), sin asumir orden
de carga. La migración ADS→Caliber (CC Prompt #2) consume estas primitivas.

Los parches de código nacieron `[PENDIENTE]` hasta la verificación en juego del autor
(PASO 4 del flujo). El código pasó primero un harness offline con stubs de GMod
(fengari, 46 checks en ambos realms: invariante by-ref, round-trip de Data,
namespacing de Net, disparo único de OnReady, prefijo de Log, UI shell) — validación
de lógica, no de juego. El 2026-07-09 el autor corrió `corpus_selftest` en juego
(realm SERVER, todo OK): parches 1-3 y 5-7 verificados. El parche 4 (UI, client-only)
cerró su check visual el 2026-07-09 con el primer tab real: el autor confirmó en juego
menú Q → Utilities → Corpus → Caliber (verificación de paridad del Block 2 de Caliber).

- PARCHE 1 — feat(registry): `corpus_registry.lua` (shared) —
  `Corpus.RegisterModule/HasModule/GetModule` con el **invariante by-ref** (misma
  tabla por referencia, sin deep-copy ni normalización — requerido por
  `Caliber_Architecture.md` §11). **[APLICADO 2026-07-09]**

- PARCHE 2 — feat(data): `corpus_data.lua` (shared) — `Corpus.Data.Save/Load` →
  `data/corpus/<module>/<key>.json`; saneo de module/key ([a-z0-9_-], sin traversal);
  Load devuelve tabla nueva (contrato distinto al registro: el round-trip JSON
  normaliza). **[APLICADO 2026-07-09]**

- PARCHE 3 — feat(net): `corpus_net.lua` (shared) — `Corpus.Net.Register(module,
  msgName)` → `"corpus_<module>_<msgName>"`; `util.AddNetworkString` solo en server
  (idempotente); el cliente usa la misma función para construir el nombre simétrico.
  **[APLICADO 2026-07-09]**

- PARCHE 4 — feat(ui): `client/corpus_ui.lua` (client) — `Corpus.UI.RegisterTab`;
  categoría única "Corpus" en menú Q → Utilities, una entrada por módulo (orden
  alfabético estable); buildFn en pcall para que un tab roto no tumbe el spawnmenu.
  **[APLICADO 2026-07-09]**

- PARCHE 5 — feat(ready): `corpus_ready.lua` (shared) — `Corpus.OnReady(fn)`,
  dispara una vez tras `InitPostEntity` (autorun corre antes, así que todos los
  módulos presentes ya están registrados); suscripción tardía corre inmediata;
  callbacks en pcall. **[APLICADO 2026-07-09]**

- PARCHE 6 — feat(log): `corpus_log.lua` (shared) — `Corpus.Log(module, ...)` con
  prefijo `[Corpus:<module>]`. **[APLICADO 2026-07-09]**

- PARCHE 7 — test(registry): `corpus_selftest.lua` (shared) — comando
  `corpus_selftest` (y `Corpus._SelfTest()` para el realm server de un listen
  server): auto-test en consola de las primitivas 1-3, 5 y 6, estilo el auto-test de
  `ads_armor.lua`; cubre el PASO 4 sin armar el escenario a mano. La UI queda como
  check visual. **[APLICADO 2026-07-09]**

- PARCHE 8 — Docs: nota del invariante by-ref agregada a `CORPUS_Architecture.md` §3
  (adición requerida por `Caliber_Architecture.md` §11); `CLAUDE.md` con el mapa de
  archivos real y la verificación por `corpus_selftest`; `corpus_estado.md`
  refrescado en sitio. **[APLICADO 2026-07-09]**

---

## PARCHES DE sesión Planilla de verificación — formato canónico — 2026-07-14

El autor lo pidió varias veces y nunca se formalizó: cada ronda de verificación en
juego terminaba con él redactando el reporte a mano y pidiendo que se re-corrigiera el
artefacto. La causa raíz es de proceso, no de una planilla en particular — el formato
vivía solo en la memoria del asistente, no en un doc del repo, así que se perdía.

- PARCHE 1 — docs(docs): `corpus_flujo_trabajo.txt` §1 PASO 4 gana la sección **"LA
  PLANILLA DE VERIFICACIÓN — formato canónico"**, obligatoria para todo el ecosistema:
  un módulo tiene UNA planilla (Artifact, actualizada por su URL, nunca una nueva); IDs
  de check estables que no se reciclan entre rondas; cada check con acción + esperado +
  comandos copiables (concommands cortos, nunca lua_run); **tres estados de respuesta**
  (✓ pasa / ✗ falla / — no corrido) y **campo de notas por check siempre visible** —
  la mayoría de los hallazgos del proyecto fueron un ✓ CON NOTA, no un ✗, y una planilla
  de solo-tick los tira a la basura; la planilla **emite el reporte** con un botón, en
  un formato de pegado fijo que es el contrato de entrada del ejecutor; y el estado se
  persiste en localStorage (el autor alt-tabea desde el juego). **[APLICADO 2026-07-14]**

---

## PARCHES DE sesión Pasada de veracidad de docs — 2026-07-14

Auditoría de los docs del ecosistema contra el árbol real (los siete repos), previa a
regenerar el espejo a Desktop: si el espejo manda docs que mienten, Desktop razona sobre
un ecosistema que no existe. 51 hallazgos confirmados (29 contradicciones duras), cada uno
verificado contra el código antes de aplicarse. Tres derivas de fondo: la **cardinalidad**
del ecosistema quedó congelada en el Block 1 (seis raíces privadas → hoy siete repos
públicos MIT + `dev/`, y el grafo de §2 era topológicamente falso: Cargo dejó de ser hoja);
la arquitectura **publicaba el patrón de boot que falla en juego** (`error()` en file-scope,
justo lo que impide que el módulo se registre); y los docs vivos del framework **no tenían
dueño en el PASO 5**, así que cada Block que cerraba en un módulo los dejaba un poco más
viejos. Parches de documentación: sin superficie de runtime, nacen `[APLICADO]`.

- PARCHE 1 — docs(docs): `CORPUS_Architecture.md` reconciliado con el árbol real. §2: el
  grafo deja de declarar hoja a Cargo — consume Coagulant (`OnEncumbrance`, en producción)
  y Cortex (`GetFactionInfo`, mock-first). §4: las columnas "Expone" de Coagulant, Cargo y
  Caliber pasan del diseño a la superficie pública real. §5: el ejemplo de ítem **no
  compilaba** (global `Cargo` inexistente, y faltaba `class`, que es obligatorio) — se
  reescribe contra el contrato real y se documentan las dos reglas que costaron juego: def y
  `onUse` en **ambos realms**, y el retorno de `onUse` gobernando el consumo. §6: el init
  publicado era el que **falla** (autorun ordena el módulo antes que el framework) — se
  sustituye por el patrón real, sonda + boot diferido a `Initialize`. §7: la migración ADS →
  Caliber pasa a pasado (ejecutada y verificada el 2026-07-09; el legacy quedó en `dev/legacy/`,
  no en un repo privado). §8: seis raíces → ocho (siete repos + `dev/`), con `corpus-stalker`
  descrito como addon de contenido. §9: Blocks 2 y 3 dejan de figurar como "Pendiente".
  **[APLICADO 2026-07-14]**

- PARCHE 2 — fix(sync): `.claude/desktop-sync/sync.ps1` sumaba solo seis repos y **omitía
  `corpus-stalker` entero**, mientras su propio docstring prometía "TODOS los docs de todos
  los repos del ecosistema". Se agrega la séptima raíz al array `$Repos`, se corrige la
  `.DESCRIPTION` (recorre una lista, no "escanea"; son raíces, no todas módulos) y se hace
  dinámico el literal "los seis repos tienen docs" del índice. **[APLICADO 2026-07-14]**

- PARCHE 3 — docs(docs): `corpus_flujo_trabajo.txt` — el **PASO 5 gana el inciso que faltaba**:
  cerrar o mover un Block obliga además a refrescar `corpus_estado.md`, la fila del Block en
  `CORPUS_Architecture.md` §9, el tramo del roadmap y a regenerar el espejo. Ese hueco es la
  causa raíz de 20 de los 51 hallazgos: los docs del módulo quedaban al día y los del
  framework se pudrían porque nadie era su dueño. Además: cabecera y §6.2/§6.3 pasan a siete
  raíces, alineados con el helper ya corregido. **[APLICADO 2026-07-14]**

- PARCHE 4 — docs(docs): `corpus_estado.md` y `corpus_roadmap.txt` al día — el roadmap daba
  a Coagulant y Craving por "módulos sin empezar" (falta uno: Cortex); el estado dejaba a
  Coagulant en el slice 3 y a Cargo "en diseño de Workbench en Desktop". `CLAUDE.md`: prefijo
  por addon (siete, no seis) y el estado de git real — los siete repos al día con `origin/main`,
  no "varios con commits locales sin pushear". **[APLICADO 2026-07-14]**

- PARCHE 5 — docs(docs): `README.md` — **el doc que ve cualquiera que entre al repo en GitHub, y
  que ninguna auditoría previa había mirado.** Su tabla del ecosistema daba a **Coagulant y
  Craving por "Sin empezar"** cuando el primero lleva 46 commits con tres slices verificados en
  juego y el segundo cerró su Block; omitía a `corpus-stalker` entero; y llamaba a la metodología
  "canónica para los seis repos". La puerta de entrada del proyecto describía un ecosistema de
  hace una semana. **[APLICADO 2026-07-14]**

Nota de alcance: esta pasada **cruzó los siete repos**, no solo el framework — cada repo hermano
registra sus propios parches en su CHANGELOG. Salió en cinco rondas porque cada verificación
destapaba una capa más profunda: primero los docs de arquitectura, después los roadmaps y las
convenciones de commit, y al final los **README públicos**, que estaban congelados en la era
semilla. Lección de proceso, ya incorporada al PASO 5 del flujo (parche 3): **el README y los
docs vivos del framework no tenían dueño** — cada Block que cerraba en un módulo los dejaba un
poco más viejos, y nadie los tocaba nunca.

---

## PARCHES DE sesión Anti-drift: constitución + registro de IDs — 2026-07-16

Portación a Corpus de la maquinaria anti-drift del sistema SDD de Kontrol (§10-11 de su
`kontrol_workflow_parches.txt`), según el plan de `dev/HANDOFF_corpus_sdd_workflow.md`.
**Bloques A y B del plan; C (checker), D (template de PROMPT) y E (gate LLM) NO se
aplicaron** — el alcance lo fijó el autor al abrir la sesión.

El diagnóstico ya estaba hecho: el ecosistema enuncia sus hechos en muchos lugares a la
vez (siete CLAUDE.md, siete estados, el roadmap, la tabla §9, el espejo) y lo único que
los mantenía coherentes era la disciplina del PASO 5 — memoria, no mecanismo. Es lo que
la pasada de veracidad del 2026-07-14 tuvo que limpiar.

- PARCHE 1 — **Constitución** (Bloque A): sección nueva `§7 COHERENCIA DEL CORPUS` en
  `corpus_flujo_trabajo.txt` — jerarquía de autoridad (§7.1: el código Lua manda sobre el
  doc; el espejo y el registro quedan FUERA de la jerarquía), regla de normalización
  (§7.2: toda norma define o cita un ID), barrido de ratificación (§7.3, cableado como
  sub-paso del PASO 5), el registro y sus cuatro tipos de evidencia (§7.4), conducta
  `DETENTE` (§7.5) y el alcance de lo que §7 **no** es (§7.6). **[APLICADO 2026-07-16]**

- PARCHE 2 — **Reparación de §0 y §6** del mismo doc, detectada al mapear: el doc canónico
  de metodología decía que *"el diseño de un módulo se autora en Claude Desktop"* cuando el
  autor planifica y diseña en Claude Code, y a Desktop solo le remite preguntas puntuales o
  de investigación. `corpus_estado.md` ya lo decía de refilón. Drift real del tipo exacto
  que §7 existe para matar. **[APLICADO 2026-07-16]**

- PARCHE 3 — **Acuñación de los IDs del framework en su sede**: los seis "Contratos que no
  debes romper" del `CLAUDE.md` pasan a ser `COR-1..6`, más `COR-9` (autosuficiencia de
  archivo, que estaba enunciada dos veces — se colapsó a una sede y una cita). En
  `CORPUS_Architecture.md`: `COR-7` (invariante by-ref), `COR-8` (la normalización del
  round-trip de `Corpus.Data`, que **no tenía enunciado propio** pese a citarse como
  contrato distinto), `COR-10`, `COR-11`. **[APLICADO 2026-07-16]**

- PARCHE 4 — **El registro** (Bloque B): `docs/ids.yaml`, único para las siete raíces.
  **178 IDs** en 9 familias (COR 14, FLU 32, GIT 7, CAL 22, COA 31, CRV 16, CRG 48, STK 8,
  CTX 0 — su repo sigue vacío), acuñados por barrido de las normas que **ya existían en
  prosa**: no se creó ninguna norma nueva. Cada entrada lleva `titulo` (≤1 frase), `sede`,
  `fuerza`, `estado` y `evidencia`. **Métrica de salud: 25% de INTENCION** (44/178), contra
  el 74% con que arrancó Kontrol — la diferencia es que este ecosistema ya tenía tres capas
  de evidencia (selftest, harness offline, planilla en juego) y lo que le faltaba era poder
  citarlas. **[APLICADO 2026-07-16]**

Nota de alcance: la pasada **leyó los siete repos pero solo escribió en `corpus/`**. Los
IDs de módulo están registrados por ubicación, no etiquetados en la prosa de su sede: cada
repo lo hará en su próxima pasada (deuda D-7 del registro) — etiquetar seis repos en la
misma tanda mezclaba modos temáticos (§2).

El barrido dejó **nueve deudas declaradas** en el propio `ids.yaml`, que son hallazgos, no
tareas hechas. Las tres que importan: **D-1** — la regla de las defs en ambos realms
(`COR-12`) tiene seis copias en tres repos consumidores y **cero en Cargo**, que es el
dueño de la API y el que impone el gate; y el único texto que Cargo ofrece sobre `onUse`
lo anota `(SERVER)`, que induce el bug. **D-2** — solo Coagulant usó IDs de check en sus
planillas; Caliber, Cargo y Craving verificaron en juego sin dejar nada citable, así que
la evidencia mejor calibrada del ecosistema (§7.4) no se puede citar desde el registro en
tres de cuatro módulos. **D-9** — `CRG-38`, la notación alto×ancho del autor, tiene su
única sede en una entry de CHANGELOG (que por disciplina nunca se reescribe) mientras el
doc que se declara dueño del footprint lista pares sin aclarar la notación: la trampa
sigue armada.

Sin superficie de runtime: no hay nada que verificar en juego. La verificación de esta
tanda es documental — el registro parsea, no tiene prefijos sin declarar, sedes vacías ni
huérfanos.

---

## PARCHES DE sesión Anti-drift: el checker de IDs — 2026-07-16

Bloque C del plan `dev/HANDOFF_corpus_sdd_workflow.md`, confirmado por el autor. Cierra el
anillo barato: la parte MECÁNICA de la coherencia deja de depender de que alguien se
acuerde de greppear antes de cerrar (§7.2) y pasa a correr sola en cada commit.

- PARCHE 1 — **El checker**: `.claude/check-ids/corpus_check_ids.ps1`. Recorre las siete
  raíces y valida `YAML_INVALIDO` (incluidas claves repetidas = bicéfalo exacto),
  `FAMILIA_NO_REGISTRADA`, `PREFIJO_EXCLUIDO`, `DUPLICADO` (canónico: `COR-1` ≡ `COR-01`),
  `SEDE_ROTA`, `EVIDENCIA_ROTA` y `HUERFANO_DOC`/`HUERFANO_CODIGO`. Reporta la métrica de
  salud en cada corrida. **[APLICADO 2026-07-16]**

  Desvío del plan, decidido con el autor: el handoff pedía "PowerShell sin toolchain", pero
  **PS 5.1 no parsea YAML** — no trae `ConvertFrom-Yaml` y `powershell-yaml` no está
  instalado. El script usa **python solo para el parse** (yaml → JSON) y sigue nativo
  (`ConvertFrom-Json` + `Select-String`). Única dependencia: `pyyaml`. Si falta, **falla
  ruidoso con la línea de instalación** — jamás fail-open: un "limpio" que no corrió no es
  un limpio (§7.6 desde el otro lado). El loader de python además rechaza claves duplicadas,
  que `yaml.safe_load` aceptaría en silencio quedándose con la última.

- PARCHE 2 — **Los tests**: `.claude/check-ids/test/run_tests.ps1` + 10 fixtures, uno por
  categoría, con **su propio árbol falso** para ser herméticos. Existen porque un checker
  que nadie vio en ROJO no es evidencia de nada — y no alcanza con exigir exit≠0, porque un
  script roto también sale 1: cada fixture exige **su** categoría. **10/10 en verde.**
  **[APLICADO 2026-07-16]**

- PARCHE 3 — **El enganche**: `.githooks/pre-commit` + `core.hooksPath` cableado en las
  siete raíces (las seis hermanas apuntan a `../corpus/.githooks`: un solo hook, sin
  duplicarlo siete veces). Dispara **solo si el commit toca superficie normativa** —
  `docs/`, `CLAUDE.md`, `ids.yaml`—: un commit de puro Lua no puede crear drift de prosa.
  Verificado de punta a punta: saltea lo no-normativo, pasa el registro sano, **bloquea**
  uno con un huérfano inyectado, y dispara desde un repo hermano (probado en Caliber).
  **[APLICADO 2026-07-16]**

- PARCHE 4 — **Barrido de ratificación** (§7.3) del propio parche: cinco docs declaraban
  que el checker "NO EXISTE". Corregidos §7.2, §7.6, la cabecera del `ids.yaml`, su bloque
  de salud y la deuda D-2. Sección nueva **§7.7** con qué valida, cómo corre, su límite
  presencial y sus tests. **[APLICADO 2026-07-16]**

- PARCHE 5 — **Tres normas dejan de ser INTENCION**: `FLU-25`, `FLU-30` y `FLU-31` pasan a
  citar al checker como evidencia — es literalmente el mecanismo que las ejerce. La métrica
  baja de **44/178 (25%) a 43/178 (24%)**, y bajó porque una norma ganó mecanismo, no
  porque se haya redefinido nada. **[APLICADO 2026-07-16]**

Sin superficie de runtime en juego: no hay nada que cargar en un mapa. La verificación es
la suite (10/10) + las tres corridas del hook + el checker en verde sobre el registro real.

Dos bugs propios que el trabajo destapó, y valen como precedente. **(a)** La primera versión
del `familias_excluidas` listaba `J/K/L/M`, copiados del EJEMPLO del handoff ("planilla
Caliber, check J4"): esas letras **no existen en ningún repo** — las reales son `A/E/G/H/I`.
Es exactamente el error que `FLU-27` nombra ("una norma que enumera se deriva del código, no
de la prosa"), cometido en la misma tanda que acuñó la norma; la nota quedó en el yaml a
propósito. **(b)** `Get-ChildItem -Include` con `-LiteralPath -Recurse` coló `ids.yaml` en el
escaneo y **el registro se auditaba a sí mismo**, inventando huérfanos. El filtro va por
`Where-Object`. Los dos aparecieron por CORRER el script, no por leerlo.

---

## PARCHES DE sesión Anti-drift: el PROMPT como spec ejecutable — 2026-07-16

Bloque D del plan `dev/HANDOFF_corpus_sdd_workflow.md`. Solo prosa: cierra el loop con el
flujo actual sin cambiarlo. Faltaba el artefacto del medio — §1 dice en qué ORDEN se aplica
un parche y §2/§3 cómo se DISEÑA, pero qué se le entrega al ejecutor era prosa libre: los
cinco `dev/HANDOFF_*.md` son PROMPTs de facto, cada uno con su forma.

- PARCHE 1 — **§8 del flujo**: el esqueleto de spec ejecutable (encabezado con
  PRERREQUISITOS re-chequeables + §0 no-negociables / §1 objetivo / §2 lecturas ordenadas /
  §3..N pasos / §5 ALCANCE SÍ|NO / §6 cierre), su ciclo de vida, qué hacer cuando la tanda
  cruza repos, y qué NO es. **[APLICADO 2026-07-16]**

- PARCHE 2 — **Seis IDs nuevos**, acuñados y registrados en el mismo parche (FLU-30, que
  ahora es mecanismo): `FLU-33` alcance negativo explícito, `FLU-34` texto literal no
  descripción, `FLU-35` una tanda = un slice vertical, `FLU-36` la entrada de `ids.yaml` es
  parte del paso, `FLU-37` el cierre declara sus checks de planilla, `FLU-38` el PROMPT no
  es autoridad. Registro: **184 IDs**, checker en verde. **[APLICADO 2026-07-16]**

Tres desvíos del plan, los tres con razón en el árbol:

**(a) La sede.** El handoff pedía `docs/dev/` gitignoreado **por repo**. Se descartó, con el
autor: el workspace YA tiene `dev/` fuera de los siete git —verificado: cero archivos `dev/`
trackeados en cualquiera de ellos— y los cinco HANDOFF ya viven ahí. Además `docs/dev/` no
resuelve la tanda que **cruza repos**, que hoy son **dos de cinco**: no tendría casa en el
`docs/dev/` de ninguno. Kontrol usa `docs/dev/` porque es un **monorepo**; ahí es la única
opción. Costo del desvío: **cero** `.gitignore` tocados.

**(b) La unidad de trabajo (FLU-35).** Kontrol dice "una task = un PR". Acá no hay PRs: se
commitea a `main` y el ledger es el CHANGELOG. La unidad es el **slice vertical** de §3, y
cada paso es una entrada de CHANGELOG.

**(c) La verificación (FLU-37).** Kontrol cierra con tests y CI. Acá el §6 CIERRE declara
**qué checks de planilla nacen de la tanda**, con su letra de sección nueva (FLU-07). Es la
norma que ataca la **deuda D-2 en su origen**: sin ese inciso la tanda se verifica en juego
y no deja rastro citable — que es exactamente por qué tres de los cuatro módulos verificados
no tienen un solo ID de check hoy.

Decisión menor de nombre: el artefacto se llama `PROMPT_<slug>.txt` de acá en más. Los cinco
`HANDOFF_*.md` son el mismo artefacto con el nombre viejo y **no se renombran** — sus
punteros ya están citados en docs y en memoria (es la misma razón por la que una v2 conserva
el nombre del archivo, FLU-38).

Sin superficie de runtime: no hay nada que cargar en un mapa. La verificación es documental —
el checker en verde sobre 184 IDs, sin huérfanos ni sedes rotas.

---

## PARCHES DE sesión Anti-drift: el gate de coherencia — 2026-07-16

Bloque E, el último del plan `dev/HANDOFF_corpus_sdd_workflow.md`. El anillo caro: caza la
contradicción SEMÁNTICA entre prosa, que es lo único que un script no puede ver.

- PARCHE 1 — **El gate**: `.claude/workflows/auditoria-coherencia-docs.js`. Seis fases
  (Glosario → Lectura → Cruce → Adjudicación → Completitud → Síntesis), tres verificadores
  adversariales por candidata (refutador / árbitro-código / árbitro-historia) con
  supervivencia por mayoría ≥2/3. Las tres reglas duras de Kontrol intactas: READ-ONLY
  estricto, jerarquía inyectada literal, rechazo de falsos positivos. **[APLICADO 2026-07-16]**

- PARCHE 2 — **§7.8 del flujo** (el gate, sus modos, su cadencia, su triage A/B/C/CADUCO) y
  **§7.6 reescrita** como "los dos anillos, y por qué son dos". Familia **`AUD-1..5`**:
  cadencia SCOPED/COMPLETO, el diferimiento por contexto degradado, el READ-ONLY y el
  triage. Registro: **189 IDs**. **[APLICADO 2026-07-16]**

- PARCHE 3 — **`docs/auditorias/`** + su README como tracker de cobertura. Actas inmutables:
  son la foto del estado AL MOMENTO DE AUDITAR, no la de hoy. **[APLICADO 2026-07-16]**

- PARCHE 4 — **El piloto SCOPED**, corrido: acta en
  `docs/auditorias/2026-07-16_coherencia_docs_PILOTO.md`. **[APLICADO 2026-07-16]**

**Costo real, que era el objetivo de la corrida:** 41 agentes / **1,69M tokens** / ~23 min
para 4 docs y 1.188 líneas. Kontrol: ~216 agentes / ~11M tokens / ~84 min para 3 docs. Es
**~6,5× más barato**, y la mayor parte del ahorro es de diseño: el gate LEE `ids.yaml` como
glosario en vez de re-derivar el índice a grep (tres agentes menos), porque el checker de
§7.7 ya prueba huérfanos y bicéfalos mecánicamente. Es el "P-19" de Kontrol hecho desde el
día uno.

**LA CORRIDA SALIÓ DEGRADADA — y el resultado se lee como hipótesis, no como cierre (AUD-3).**
Dos agentes de cruce (`namespacing`, `dano-limbs`) fueron bloqueados por un error transitorio
del clasificador de seguridad, y otros doce corrieron sin revisión. `namespacing` es un tema
del framework: **no está limpio, está sin auditar**. El "cero BLOQUEANTES" vale para lo que sí
se cruzó.

**Resultado:** 285 afirmaciones, 218 normativas, **7 contradicciones confirmadas** (3 MEDIA,
3 BAJA, cero BLOQUEANTE), 1 divergencia yaml-vs-sede, **49 normativas sin ID** (violan FLU-25),
41 afirmaciones con alcance no declarado. Los parches están PROPUESTOS en el acta; ninguno
aplicado. `AUD-4` verificado en la práctica: el gate escribió **solo su acta** — cero cambios
en los seis repos hermanos.

- PARCHE 5 — **Dos defectos del port, encontrados POR el piloto y corregidos**:
  **(a)** los `CLAUDE.md` quedaban fuera del corpus por ser árbitros (nivel 4) — pero son la
  **sede de 32 IDs** del ecosistema, y el valor único del gate es contrastar el título del
  yaml contra la prosa de su sede. Los omití justo donde más servía. Ahora son **sujetos
  obligatorios en todo modo**. Kontrol los excluye y tiene el mismo punto ciego.
  **(b)** un agente muerto se caía con `filter(Boolean)` y el acta reportaba cobertura que no
  tuvo: un falso-limpio por omisión, el modo de falla del §10.8 **cometido por el gate que
  existe para prevenirlo**. Ahora la cobertura perdida se cuenta, se loguea, viaja al acta y
  marca el resultado como `degradada`. **[APLICADO 2026-07-16]**

- PARCHE 6 — **Reparación de dos hallazgos propios** (bucket A, ganador decidido por el árbol;
  es higiene del PASO 5 de esta tanda, no aplicación unilateral de hallazgos del gate):
  **(a)** hallazgo #3 — `corpus_estado.md` decía *"El gate LLM (E) no existe"* mientras el
  gate corría esa misma auditoría. El estado es el doc que el CLAUDE.md manda leer PRIMERO:
  la línea falsa se pagaba cada sesión nueva. **El gate cazó el drift de su propio autor, el
  mismo día.**
  **(b)** el bloque `salud` del `ids.yaml` tenía **cuatro cifras distintas** para el mismo
  hecho (178 / 43-de-178 / 184 / 189 real) porque se editaba a mano en cada tanda. Se derivó
  del checker y se quitó `por_familia`, que era otra lista a mano desincronizándose sola.
  **[APLICADO 2026-07-16]**

Lo que el piloto dejó abierto, y es del autor: el hallazgo **#2 / la divergencia de `FLU-31`**
(el registro opera con CINCO tipos de evidencia y §7.4 enumera CUATRO — `codigo` no existe en
la sede, y es el tipo **más usado**) va a **bucket B, voto**: formalmente el yaml no litiga
contra el doc, pero acá la reparación honesta es probablemente al revés. Y **COR-6 tiene el
alcance podrido**: dice `corpus_<addon>_*.lua` **en `lua/autorun/...`** cuando **70 de 74**
archivos Lua de los módulos viven fuera de autorun — el contrato quedó atado a una topología
que el código abandonó. Lo destapó el crítico de completitud, no el cruce, porque `CLAUDE.md`
no era sujeto.

Sin superficie de runtime: nada que cargar en un mapa. La verificación es el acta, el checker
en verde sobre 189 IDs, y los seis repos hermanos intactos.

---

## PARCHES DE sesión Etiquetado D-7 + reparación del gate — 2026-07-19

Cierra la deuda D-7 (recortándola, no cerrándola del todo) y repara tres defectos que el
piloto del gate encontró. La tanda cruzó los cinco repos de módulo: cada uno registra sus
propios parches en su CHANGELOG.

- PARCHE 1 — **`dev/PROMPT_d7_etiquetado_ids.txt`**: la tanda escrita como spec ejecutable,
  primera aplicación real del §8. Su columna **NO** fue la parte que más trabajó: declaró
  fuera de alcance las ~16 sedes que viven en `.lua`, CHANGELOG, estado o roadmap, porque
  etiquetar ahí volvería **definitorio** un comentario y rompería **FLU-26**. Los cuatro
  agentes la respetaron sin excepción — cero archivos fuera de alcance en 14 tocados.
  **[APLICADO 2026-07-19]**

- PARCHE 2 — **109 de 125 IDs de módulo etiquetados en su sede** (CAL 22/22, COA 27/31,
  CRV 15/16, CRG 38/48, STK 7/8). Los 16 restantes son exactamente la deuda **D-3**.
  El gate COMPLETO (AUD-2) ya puede correr sin ahogarse en `sinId` de módulo.
  **[APLICADO 2026-07-19]**

- PARCHE 3 — **Deuda D-1 reparada.** Cargo, el dueño de `Items.Register`, ya enuncia la regla
  de realms en `Cargo_Architecture.md` §3 **citando** `COR-12` con su causa; y las seis copias
  de los módulos pasaron de re-enunciar a **citar**. Era el hallazgo más caro del barrido
  original. Sigue abierta su mitad fea: el comentario de `corpus_cargo_items.lua` que anota
  `onUse ... (SERVER)` e induce el bug — es `.lua`, va con D-3. **[APLICADO 2026-07-19]**

- PARCHE 4 — **El checker escaneaba `docs/auditorias/`**, y las actas *nombran* IDs
  hipotéticos —del tipo "esperando a que alguien acuñe el primer ID de Cortex"—. El checker los leía como citas
  huérfanas y se puso rojo por un ID que nadie acuñó. Kontrol excluye esa carpeta por lo
  mismo — ahí nacieron sus 11 bicéfalos. Porté el gate y me olvidé de portar la exclusión.
  **[APLICADO 2026-07-19]**

- PARCHE 5 — **El checker nunca validaba la sede de una FAMILIA**, solo la de cada ID. La
  familia `CTX` declaraba sede en `corpus-cortex/CLAUDE.md`, **que no existe**, y se salvaba
  del rojo porque CTX tiene 0 entradas: una trampa cargada para el día que alguien acuñe
  el primer ID de esa familia contra un archivo fantasma. Ahora se valida, con la excepción `pendiente: true` —
  reservar un prefijo (que FLU-30 exige ANTES de acuñar) no obliga a que su sede exista, pero
  sí en cuanto tenga entradas. Suite: **10 → 12 casos**, fixture por rama.
  **[APLICADO 2026-07-19]**

- PARCHE 6 — **El corpus del gate COMPLETO tenía 25 docs contra 29 reales.** Faltaban los
  cuatro `<modulo>_convenciones_commits.txt`, que son normativos por `GIT-6`. Un COMPLETO
  contra esa lista habría arrancado con cuatro docs **invisibles** y un ✅ sin valor — el
  §10.8 por la puerta de atrás. Lista re-derivada del árbol. Y el §7.8 dejó de enunciar "19
  docs" a mano: ahora apunta a la tabla del script, porque un número escrito en prosa se
  desincroniza del código — era **FLU-27 violada en el doc que la acuña**.
  **[APLICADO 2026-07-19]**

- PARCHE 7 — **Tres deudas nuevas registradas**, todas destapadas por el etiquetado:
  **D-10**, varios títulos del registro FUSIONAN dos enunciados que la prosa separa (COA-16,
  COA-19, COA-20, COA-27, CRV-5, CRV-9, CRG-6, CRG-10, CRG-24, CRG-48) — deuda mía del barrido
  inicial por comprimir para que entrara en "≤1 frase". Dos son peores: `COA-20` y `COA-27`
  afirman en el yaml algo que su sede **no dice**, que es la patología inversa a la que
  veníamos cazando: acá miente el índice.
  **D-11**, dos de las seis primitivas del framework —**UI shell y Log**— no tienen contrato
  `COR` acuñado; lo destapó Caliber, cuyos contratos 5 y 6 son normas del framework sin ID.
  **[APLICADO 2026-07-19]**

Verificación: checker en verde sobre 189 IDs y 121 archivos, suite 12/12, y los cinco repos
tocados solo en `CLAUDE.md` y docs de diseño. Sin superficie de runtime.

Nota de proceso: la corrida `_v2` del gate (2026-07-16b) gastó ~1,1M tokens probando un fix
que **no estaba en el script** — `Workflow({name:...})` resolvió una versión cacheada. Se
detectó solo porque `docsAuditados` dio 4 donde tenían que ser 5. Quedó documentado en
`docs/auditorias/README.md`: después de editar el workflow, se invoca por `scriptPath`.

---

## PARCHES DE sesión Anti-drift: cierre de votos + triaje de actas — 2026-07-19

La tanda de `dev/PROMPT_cierre_antidrift.txt`: el autor votó las once deudas del registro
(§3 del PROMPT) y se aplicó lo votado. Cada repo hermano registra sus parches en su propio
CHANGELOG; acá va lo del framework y lo transversal.

- PARCHE 1 — **D-11 cerrada: `COR-15` (UI shell) y `COR-16` (log) acuñados** como incisos 8
  y 9 de los contratos del `CLAUDE.md`. Las seis primitivas que COR-10 declara tienen ahora
  contrato citable; los contratos 5-6 de Caliber pasaron de definir a **citar**.
  **[APLICADO 2026-07-19]**
- PARCHE 2 — **D-6 cerrada: política git unificada en la estricta** (ni commit ni push sin
  pedido explícito) en los siete repos — voto del autor. `GIT-7` gana nota de unificación y
  el `CLAUDE.md` de corpus-stalker se corrige (era el único divergente). **[APLICADO 2026-07-19]**
- PARCHE 3 — **Curaduría D-10 del registro (cerrada):** seis títulos fusionados se parten
  (+`COA-33/34/35`, +`CRV-17/18`, +`CRG-49` — el registro pasa de 189 a **197 IDs**), dos
  ganan en su sede la mitad que ya era real (`CRG-6`, `CRG-24`), `CRG-48` se reescribe a
  las tres capas de su sede, y `CRG-19` se reformula en positivo (voto h: sigue VIGENTE —
  es la norma que sostiene el `skipCap` del comercio). Los dos casos donde el índice
  afirmaba más que su sede se resolvieron SUBIENDO la prosa (voto a): `COA-20` y el nuevo
  `COA-35`. **[APLICADO 2026-07-19]**
- PARCHE 4 — **Triaje del acta v3 (AUD-5) y reparación de sus tres bucket A:** §2.2, el
  ejemplo encadenado de `CORPUS_Architecture.md` §6 (`GetModule("cargo").Items.Register`
  como «check y llamada a la vez») se reemplaza por la forma canónica captura + rama — era
  el único hallazgo con consecuencia de runtime (crash sin el módulo montado; los cuatro
  call sites reales ya hacían lo contrario del doc); §2.3, el §0 del roadmap deja de mandar
  el diseño de bloque al doc general (tercera reincidencia — cierra el barrido que quedó a
  medias el 2026-07-16, ahora citando FLU-18); §2.1, el titular de §11 pasa de «código
  compartido» a «**infraestructura** compartida», citando COR-10 y enunciando la exclusión
  del dominio. De paso, la evidencia de COR-10 en el yaml nombraba a **Coagulant** donde el
  árbol dice **Caliber** (observación §3.1 del acta): corregida. **[APLICADO 2026-07-19]**
- PARCHE 5 — **`GIT-1..7` etiquetados en su sede** (punto 1 del pre-COMPLETO del acta v3):
  GIT-1/2/3/6 en `corpus_convenciones_commits.txt`, GIT-4/5/7 en el `CLAUDE.md`. El gate
  deja de ser ciego sobre la familia GIT — siete normas registradas ya anclan a una línea.
  **[APLICADO 2026-07-19]**
- PARCHE 6 — **Bloque `deuda` del registro actualizado:** D-1, D-4, D-6, D-9, D-10 y D-11
  **cerradas**; D-2 y D-3 **recortadas** (recorte, no cierre): D-2 queda prospectiva por
  voto e (los IDs de check rigen hacia adelante; lo pre-FLU-07 es pre-norma, no se
  reconstruye evidencia), D-3 conserva las sedes fuera de doc que se moverán por
  oportunidad. D-5, D-7 y D-8 sin cambios. **[APLICADO 2026-07-19]**

Quedan en **bucket B** (voto del autor, heredados de las actas — el gate COMPLETO espera
estos votos): **(1)** la divergencia de FLU-31 (el registro opera con cinco tipos de
evidencia y §7.4 enumera cuatro — `codigo` no existe en la sede y es el tipo más usado);
**(2)** la reformulación de COR-6 (dos ejes podridos de la misma cláusula: «siete addons»
cuando el framework usa el prefijo desnudo load-bearing, y «en `lua/autorun/`» cuando 70 de
74 archivos de módulo viven fuera — el acta v3 §2.4 trae la redacción propuesta que cierra
ambos); **(3)** el estatus del roadmap (¿doc normativo que etiqueta IDs, o intención pura
que el gate declara NO-AUDITABLE por diseño?).

Verificación: checker en verde sobre **197 IDs** y 122 archivos, suite 12/12. Sin
superficie de runtime (solo dos comentarios de `.lua` que pasan de definir a citar), y
**ningún check de planilla nace de esta tanda** (FLU-37).

---

## PARCHES DE sesión Anti-drift: los tres votos B — 2026-07-19

Misma tanda, segunda vuelta: el autor votó los tres bucket B que las actas dejaron.
El gate COMPLETO queda **sin bloqueos**.

- PARCHE 1 — **FLU-31 ratificada, sin cambio que aplicar.** El voto del autor («sí,
  `codigo` es parte de la evidencia») **ya estaba aplicado**: §7.4 del flujo enumera
  `codigo` entre los tipos y registra el voto original del 2026-07-16 («cedió la sede, que
  era la que había nacido corta»). El párrafo de la sesión del piloto que lo daba por
  abierto quedó superado por esa reparación — no se reescribe (FLU-14): esta entrada es la
  corrección. **[APLICADO 2026-07-19]**
- PARCHE 2 — **COR-6 reformulado** (voto del autor sobre el hallazgo 2.4 del acta v3 + el
  voto que esta misma bitácora dejó abierto el 2026-07-16). La redacción del acta cierra
  los **dos ejes** podridos de la cláusula: los **seis consumidores** llevan segmento en
  todo su árbol Lua (no solo `lua/autorun/`), y el **framework se reserva el prefijo
  desnudo** `corpus_<primitiva>.lua` — con la advertencia de que `corpus_registry.lua` es
  **load-bearing** (el boot de los módulos depende de su posición en el merge alfabético) y
  no se renombra. Tres sitios: `CLAUDE.md` inciso 6 (la sede), `CORPUS_Architecture.md` §11
  (espejo con puntero a la sede) y el título del yaml (el índice sigue a su sede).
  **[APLICADO 2026-07-19]**
- PARCHE 3 — **El roadmap es INTENCIÓN PURA** (voto del autor). El §0 de
  `corpus_roadmap.txt` lo declara: nivel 6 de la jerarquía (FLU-22), no acuña IDs ni es
  sede de norma alguna, cita cuando corresponde; un «limpio» del gate sobre él en el cruce
  de IDs se reporta **NO-AUDITABLE POR DISEÑO**, no como cobertura — y lo mismo vale para
  los `<modulo>_roadmap.txt` hermanos. Cierra la pregunta que el acta v3 §5.1 dejó
  planteada. **[APLICADO 2026-07-19]**
- PARCHE 4 — **`docs/auditorias/README.md` puesto al día para el COMPLETO:** la tabla de
  cobertura suma las corridas v2 y v3 (solo listaba la primera); la línea «19 docs» —que
  PARCHE 6 de la sesión de etiquetado ya había matado en §7.8— pasa a apuntar a la tabla
  canónica del script (**29 docs**, FLU-27); el aviso pre-COMPLETO refleja el etiquetado
  hecho (109/125 + GIT-1..7) y el estatus de los roadmaps; y queda escrita la instrucción
  del autor: **el gate corre en sesión fresca y sus agentes con Opus 4.8**.
  **[APLICADO 2026-07-19]**

Verificación: checker en verde + suite 12/12. Sin superficie de runtime.

---

## PARCHES DE sesión Anti-drift: gate COMPLETO corrido (AUD-2) — 2026-07-19

Primera corrida del modo COMPLETO, en sesión fresca con los agentes en Opus 4.8 (spec:
`dev/PROMPT_gate_completo.txt`; ejecutor externo, reporte §5 remitido por el autor).

- PARCHE 1 — **El COMPLETO corrió ÍNTEGRO a la primera:** 29/29 docs, 0 cobertura perdida,
  0 resumes (145 agentes, 0 caídos; el único `agents_empty_result` se verificó contra el
  journal — retorno bien formado con cero candidatas, no un agente muerto). 1.809
  afirmaciones, 1.447 normativas, **26 contradicciones confirmadas** (6 ALTA / 13 MEDIA /
  7 BAJA / **0 BLOQUEANTES**), 1 divergencia yaml-vs-sede, 844 normativas sin ID, 10 de 29
  docs en cobertura ciega declarada. Costo: 8,31M tokens / ~44 min. Acta:
  `docs/auditorias/2026-07-19_coherencia_docs.md` (inmutable, AUD-4). Tracker actualizado.
  **[APLICADO 2026-07-19]**
- PARCHE 2 — **Triaje (AUD-5), ratificado del que el acta trae con 3 verificadores por
  hallazgo: 25 bucket A + 1 bucket B + 0 C + 0 CADUCO.** El único **B** es el hallazgo
  2.10: el **GC del cadáver looteado** está adjudicado a Cortex/Caliber en
  `Cargo_Trade_Arquitectura.md` §(249-252) y a Cargo doce líneas después (:281), sin código
  que dirima (Cortex es repo semilla) — **voto del autor pendiente**. Los 25 A quedan para
  su propia tanda de reparación documental (el gate propone, el autor dispone): ninguno se
  aplicó en esta sesión. **[APLICADO 2026-07-19]**

Nota fáctica que el ejecutor señaló y acá se registra: el hallazgo **2.6 (ALTA)** toca el
mandato de esta misma corrida — `corpus_flujo_trabajo.txt:461-465` sigue prohibiendo el
COMPLETO por la deuda D-7, que este CHANGELOG recortó el 2026-07-19. La corrida se hizo
bajo AUD-2 + la autorización explícita del autor (PROMPT de la tanda), que por jerarquía
mandan sobre un tramo rancio del flujo; la línea se repara en la tanda de reparación
(bucket A: el árbol dirime).

Sin superficie de runtime. La verificación es el acta ÍNTEGRA, el tracker y el checker en
verde.

---

## PARCHES DE sesión Anti-drift: reparación del COMPLETO — 2026-07-19

Aplica los 26 hallazgos del acta `docs/auditorias/2026-07-19_coherencia_docs.md` (25
bucket A + el voto B del autor: **el GC del cadáver looteado es de CARGO**) y las
reparaciones colaterales con árbitro que el acta dejó señaladas. Cada repo registra su
parte en su CHANGELOG; acá lo del framework y lo transversal.

- PARCHE 1 — **Hallazgo 2.6 (ALTA):** §7.6 del flujo deja de prohibir el COMPLETO por la
  D-7 ya recortada — AUD-2 corre sin bloqueos y el punto ciego residual (D-3) queda
  declarado como acotado, no como bloqueo. Barrido: la nota de AUD-2 en el yaml y los
  comentarios/strings del `.js` del gate dejan de dar la premisa caduca por vigente.
  **[APLICADO 2026-07-19]**
- PARCHE 2 — **Hallazgo 2.10:** la cola causal FALSA de COR-6 (introducida por el
  PARCHE 2 de la sesión «votos B», copiada del acta v3 sin adjudicar) se corrige: el boot
  es **INMUNE** al orden alfabético por construcción (sonda + diferido, COR-5/COR-9);
  `corpus_registry.lua` no se renombra por **convención documental**, no por dependencia
  técnica. Queda además consignada la cita muerta de aquella entrada: el espejo de COR-6
  vive en `CORPUS_Architecture.md` §8, no «§11» (el doc termina en §9). **[APLICADO 2026-07-19]**
- PARCHE 3 — **Hallazgos 2.19 y 2.24:** `CORPUS_Architecture.md` §7 enuncia la cadena
  completa del pipeline (Hit → escudo → armadura → limbs, CAL-13) — era la copia gemela
  que el cierre de D-4 no alcanzó; y «Las otras **dos** normas duras» del CLAUDE.md
  (seguidas de cuatro) pasa a «Las normas duras **restantes**» — la forma que no puede
  volver a desincronizarse (FLU-27). **[APLICADO 2026-07-19]**
- PARCHE 4 — **Hallazgo 2.15:** el COSTO de §7.8 deja de enunciar «4 docs y ~1.188
  líneas» en presente: la cifra queda fechada como medición del 2026-07-16 (previa a que
  los CLAUDE.md fueran sujetos) y el conteo vigente se delega a la tabla del script
  (FLU-27). **[APLICADO 2026-07-19]**
- PARCHE 5 — **Hallazgo 2.16 + divergencia §3.1:** **GIT-6 reformulado** — las secciones
  0/1/2/4/5 de las convenciones son del ECOSISTEMA (las heredan las seis raíces
  consumidoras, corpus-stalker incluido) y la §3 es POR REPO (interina en el CLAUDE.md
  del repo mientras su doc no exista). Con la sede ampliada, la única divergencia
  yaml-vs-sede del acta se cierra sola. **[APLICADO 2026-07-19]**
- PARCHE 6 — **Registro:** correcciones de índice que siguen a su sede (CRG-40, CRV-7,
  CAL-13, GIT-6) y **dos deudas nuevas** del acta: **D-12** (el harness de Coagulant no
  existe como archivo y hay acreditaciones tipo:harness vivas — voto del autor
  pendiente) y **D-13** (pre-2.º COMPLETO: 10 de 29 docs sin un solo ID —35% del corpus
  en ceguera—, docs faltantes de stalker/Cortex, taxonomía a 18 buckets, fase
  contrato-vs-árbol, el `.js` citando en vez de duplicar). **D-3 se amplía** con la sede
  rota de CRG-45 y las 4 sedes en docs-árbitro (H2). **[APLICADO 2026-07-19]**

Verificación: checker en verde + suite 12/12. Sin superficie de runtime (solo
comentarios y strings de reporte del `.js` del gate).

---

## PARCHES DE sesión D-12 + D-13: rumbo al 2.º COMPLETO — 2026-07-19

Cierra las **dos** deudas que la tanda anterior dejó abiertas (PARCHE 6 de arriba), guiada
por `dev/PROMPT_d12_d13_segundo_completo.txt`. Multi-repo; acá lo del framework y lo
transversal. **El 2.º COMPLETO NO se corre en esta tanda** (va en sesión fresca aparte —
AUD-3).

**D-12 — el harness de Coagulant (voto del autor: MATERIALIZAR)**

- PARCHE 1 — **Nace `dev/harness_coagulant.py`**, tercero del patrón. 173 checks propios en
  ambos realms + el `_SelfTest` del módulo. La decisión se tomó con el número **derivado del
  árbol** (FLU-27), y ahí estuvo el hallazgo: el acta nombraba 4 entradas COA con
  `tipo: harness` y el registro llevaba **16** (47 % de la familia) más la de `COR-12` —
  el costo real de re-acreditar era 17 adjudicaciones, no 4. Detalle en el CHANGELOG de
  Coagulant. **[APLICADO 2026-07-19]**
- PARCHE 2 — **Las 17 acreditaciones pasan a ser citables:** las refs `tipo: harness` de las
  16 COA y de `COR-12` nombran la ruta del archivo y el escenario que corre, en vez de
  describir un check suelto. **El checker cazó de paso que una ref con DOS rutas no resuelve
  a ninguna** (`EVIDENCIA_ROTA`): la de `COR-12` quedó partida en dos entradas, una por
  harness. **[APLICADO 2026-07-19]**

**D-13(a) — acuñación sobre los 10 docs ciegos (H1)**

- PARCHE 3 — **9 IDs nuevos, ni uno de más.** Cuatro para la tabla de alcances de cada
  módulo (`CAL-23`, `COA-36`, `CRV-19`, `CRG-55` — aplican GIT-6, que declara la §3
  por-repo) y cinco para Workbench (`CRG-50`..`CRG-54`), que eran 128 líneas de diseño de un
  subsistema entero con **cero** IDs: no estaba limpio, estaba invisible.
  **Lo que NO se acuñó importa igual:** tres reglas de Workbench ya eran normas de otra sede
  y el doc pasó a **citarlas** — la eyección antes de destruir es `CRG-9`, el patrón de
  módulo dueño es `CRG-1`, el canal ARC9 es `CRG-23`. Acuñarlas habría fabricado tres IDs
  bicéfalos. **[APLICADO 2026-07-19]**
- PARCHE 4 — **Los 4 roadmaps y la semilla de Craving reciben CITAS, no acuñación** (voto del
  autor), más una **NOTA DE LECTURA** que los declara intención pura / registro histórico:
  un "limpio" del gate sobre ellos se reporta **NO-AUDITABLE POR DISEÑO**, no como cobertura.
  **[APLICADO 2026-07-19]**

**D-13(b) — las sedes fuera de un doc de diseño (H2, y D-3 con ellas)**

- PARCHE 5 — **Cinco sedes movidas.** `CRG-45` salía de `cargo_roadmap` §12 y era una sede
  **rota por partida doble**: el archivo no contenía la etiqueta, y un roadmap es intención
  pura (nivel 6) que no puede alojar una norma vigente — el checker no la cazó porque la
  RUTA existía, y su validación de sede es presencial sobre el archivo, no sobre la etiqueta.
  Va a `Cargo_Architecture.md` §13.1. Las otras cuatro: `FLU-15` (del encabezado de
  `corpus_estado.md` — **la norma sobre cómo se escribe un estado tenía por sede un estado,
  y se autodestruía en cada refresh**) al flujo §1 PASO 5; `CRG-42` a `Cargo_Architecture` §4;
  `COA-6` y `COA-17` (del CHANGELOG de Coagulant, donde un INVARIANTE contradice FLU-14) a
  `Coagulant_Architecture` §6. **Estado derivado al cierre: sedes en CHANGELOG = 0, en
  estado = 0, en roadmap = 0.** Quedan once en `.lua`, y varias son legítimas.
  **[APLICADO 2026-07-19]**

**D-13(c) — los tres docs que no existían (H5)**

- PARCHE 6 — Detalle en los CHANGELOG de `corpus-stalker` y en el propio doc de Cortex.
  `STALKER_Arquitectura.md` + `stalker_convenciones_commits.txt` (`STK-9`) y
  `Cortex_ContratosEntrantes.md`. **[APLICADO 2026-07-19]**

**D-13(d) — las cuatro mejoras del gate (H6/H7/H8)**

- PARCHE 7 — **Taxonomía ampliada:** entran `compat-terceros`, `ciclo-de-vida-del-jugador`,
  `config-y-balance` y `rendimiento`. Los dos primeros son **fronteras entre repos**, que es
  donde este gate rinde; el hallazgo que se le escapó a la 1.ª corrida (H4 — Coagulant
  describiendo mal el mecanismo interno de Cargo) era exactamente un hallazgo del bucket
  ausente `compat-terceros`, y salió por lectura de prosa, de casualidad. El bucket nuevo
  lleva ese eje escrito en su consigna. **[APLICADO 2026-07-19]**
- PARCHE 8 — **Fase nueva `ContratoArbol`** (H7): un agente por `CLAUDE.md`, cada contrato
  numerado contra el Lua. Es la única fase que **no** es doc-vs-doc, así que ninguna otra la
  cubría — y los tres hallazgos más accionables de la 1.ª corrida salieron por esa vía de
  casualidad. Sin adjudicación adversarial **a propósito**: un `CLAUDE.md` es nivel 4 y el
  Lua es nivel 1, así que cuando chocan no hay nada que deliberar. Su veredicto más valioso
  es `PARCIAL` — el contrato se cumple en la ruta principal y se saltea en una rama.
  **[APLICADO 2026-07-19]**
- PARCHE 9 — **El `.js` deja de duplicar la jerarquía** (H8) y la cita por `FLU-22`,
  mandando a leer §7.1. Un gate que existe porque la prosa duplicada se desincroniza no
  puede permitirse duplicar la norma que lo gobierna — y ya se le había desincronizado.
  Lo que el prompt sí afirma es el **alcance** de la tarea (qué es árbitro y qué es sujeto),
  que no es la norma sino su aplicación. §7.8 del flujo queda alineado. **[APLICADO 2026-07-19]**
- PARCHE 10 — **La columna `total` re-derivada, y era peor de lo que el acta creía.** El acta
  la daba corta en 5 filas; estaba desincronizada en **las 29**: la derivación anterior había
  contado **sin las líneas vacías**. No es cosmético — los TRAMOS se calculan con ese número,
  así que **la cola de cada doc quedaba fuera del rango leído** y nadie lo notaba. Es un
  limpio-por-omisión escondido en una constante, cometido por el gate que existe para
  cazarlos. La lista pasa a **32 docs** (los 3 nuevos de D-13). **[APLICADO 2026-07-19]**

- PARCHE 11 — **`D-7` re-recortada: decía «16 sedes» y el PARCHE 5 de esta misma tanda había
  movido cinco.** Drift introducido por la propia tanda que cierra deudas, cazado en el
  barrido de ratificación (FLU-28) al revisar el bloque `deuda` entero. Se corrige el número
  a **11** y —más importante que el número— se corrige el CRITERIO DE CIERRE: no es «cero
  sedes en `.lua`», porque varias son legítimas (CAL-12, CRG-2 y CRG-5 viven en el bloque
  CONTRATO del init, que **es** el lugar canónico de un contrato público). El criterio real
  es «ninguna norma vive donde nadie la busca al diseñar», y el caso pendiente claro es
  `CRG-46`. **[APLICADO 2026-07-19]**

**Registro:** `D-12` CERRADA, `D-13` CERRADA, `D-3` y `D-7` recortadas con su estado
derivado del propio registro. 9 IDs nuevos → **207**.

**Deudas que quedan abiertas, y ninguna bloquea los roadmaps:** `D-5` (la firma que CRV-4
congeló espera ratificación del dueño — se cierra en la ronda 7 de Coagulant), `D-8` (prosa
de grano fino de Cargo sin ID — se acuña por oportunidad, FLU-30 ya lo fuerza para toda norma
nueva), `D-2`, `D-3` y `D-7` (recortadas, se cierran solas al pasar por su repo).

Verificación: harness de Coagulant en verde (`ALL GREEN`, exit 0) + checker en verde sobre
207 IDs + suite 12/12 + `node --check` del `.js` del gate. Sin superficie de runtime: **ni una
línea de Lua cambió en toda la tanda**, y **ningún check de planilla nace de ella** (FLU-37) —
un harness es capa offline, no planilla.

> **Editar el `.js` invalida el caché de resume** de las corridas anteriores del gate. Es
> esperable: el 2.º COMPLETO arranca de cero.

---

## PARCHES DE sesión Reparación post-gate SCOPED — 2026-07-20

Aplica los parches que el acta [`auditorias/2026-07-20_coherencia_docs_PILOTO.md`](auditorias/2026-07-20_coherencia_docs_PILOTO.md)
dejó **PROPUESTOS** y que AUD-4 le prohíbe aplicar a sí misma: el gate propone, el autor
dispone. Tanda **partida en dos sesiones** por contexto; se registra como una sola, que es
lo que es.

**Los cinco parches A1-A5 tienen la misma forma, y por eso agrupan:** el doc enuncia un
universal («seis raíces», «sin docs», «única excepción», «la sede de la familia es acá») y
el árbol lo desmiente en una rama. **En los cinco el Lua tiene razón y el doc está corto** —
ninguno es un bug de código, y ni una línea de Lua cambió. El stool de Caliber y el `print`
del selftest están **bien como están**.

- PARCHE 1 — **A5 · `CORPUS_Architecture.md` §5: COR-12, COR-13 y COR-14 anclados por
  etiqueta.** La sede era correcta en CONTENIDO y no llevaba el ID escrito: la cadena
  `COR-12`/`COR-13`/`COR-14` **no aparecía literalmente en el archivo**. Por eso el checker
  no la cazaba y por eso el silencio del `CLAUDE.md` no tenía nada que lo detectara. Las tres
  normas ganan su etiqueta en sitio, sin cambiar el largo del doc. **[APLICADO 2026-07-20]**

- PARCHE 2 — **A5 · `CLAUDE.md` §Contratos, párrafo de cierre.** El doc que se autodeclara
  **sede de la familia `COR-nn`** enumeraba las excepciones (COR-7/COR-8 en §3; COR-10/COR-11
  en §1-4 y §2/§6) y **omitía tres invariantes VIGENTES**. Ahora enumera COR-12/13/14 con su
  sede en §5. Era el Hueco 2 del acta, su hallazgo más caro: no es una contradicción entre dos
  frases, es **una frase y un silencio**. **[APLICADO 2026-07-20]**

- PARCHE 3 — **A1 · `corpus_convenciones_commits.txt:120`: se quita la cifra.**
  `chore(workspace): crea las ~~seis~~ raíces del multi-root workspace`. El ejemplo existe
  para ilustrar el FORMATO (GIT-1/GIT-2), **no para enumerar el árbol**, y este valor ya
  derivó dos veces. Sin cifra deja de ser superficie que el barrido por valor tenga que
  perseguir cada vez que el workspace crezca. **NO se tocó `:9`** (GIT-6, «las seis raíces
  consumidoras») — es **otro referente** y es correcto: 5 módulos + stalker.
  **[APLICADO 2026-07-20]**

- PARCHE 4 — **A2 · el eco de «Cortex no tiene docs», en TRES sedes y no en dos.**
  `corpus_roadmap.txt:81` decía que el repo es semilla «sin código **ni docs**». Falso:
  `corpus-cortex/docs/Cortex_ContratosEntrantes.md` existe (129 líneas, derivadas). El
  roadmap lo reconoce ahora como **el primer doc de diseño de Cortex** — hasta hoy no
  figuraba en ninguna lista del framework. El PROMPT madre anunciaba un eco en `ids.yaml`;
  **el barrido por VALOR encontró dos** (`:48`, comentario de `pendiente: true`, y `:1747`,
  encabezado de la familia CTX). En ambos **lo falso es el paréntesis**; la afirmación que
  lo envuelve —que la sede CTX (el `CLAUDE.md` de Cortex) todavía no existe— es **verdadera
  y no se tocó**. **NO se tocó `CLAUDE.md:88`**, que dice «sin código» a secas y es cierto:
  Cortex no tiene Lua. **[APLICADO 2026-07-20]**

- PARCHE 5 — **A3 · contrato 8 / COR-15: los stools quedan fuera de la norma.**
  `corpus-caliber/lua/weapons/gmod_tool/stools/corpus_caliber_config.lua:4` declara
  `TOOL.Category="Caliber"` — una **segunda superficie en el spawnmenu** que la letra del
  contrato no contemplaba. La ruta principal CUMPLE y está **enforceada**, no solo prometida
  (`corpus_ui.lua:26-29`, `:33`), y el grep de `AddToolCategory` sobre los seis consumidores
  da **cero** llamadas directas. Se amplía la cláusula de excepción; el `titulo` de COR-15 en
  `ids.yaml` acompaña, porque el gate cruza exactamente eso. **[APLICADO 2026-07-20]**

- PARCHE 6 — **A4 · contrato 9 / COR-16: «Única excepción» pasa a DOS.**
  `corpus_selftest.lua:56, 59-60, 63, 65` emite `print` crudo con prefijo `[Corpus]` **a
  secas**. Formalmente **no hay violación de conducta** —el sujeto de COR-16 es «un módulo» y
  el selftest no lo es—: lo que el árbol desmiente es la palabra **«Única»**, un
  universal-negativo. Y el parche **nombra el medio** del fallback de boot: es **`MsgN`**, no
  `print` (los cuatro inits de módulo, p.ej. `corpus_cargo_init.lua:144`) — sin nombrarlo,
  alguien lo iba a «corregir». `titulo` de COR-16 acompañado. **[APLICADO 2026-07-20]**

- PARCHE 7 — **`D-14`: el voto abierto del autor, COR-12 vs COR-1/COR-10.** **NO se parcha**
  y **no se cierra sin el autor**: es un hecho **sin árbitro de código** (§7.1, corolario) —
  ambas lecturas son implementables y el árbol no dirime. La pregunta: *¿el contrato de ítems
  es infraestructura demostrablemente compartida, o dominio infiltrado en el framework
  delgado?* Queda registrado con **las dos posiciones** y una recomendación explícitamente
  tumbable. **`D-1` está CERRADA y NO cubre esto**: cerró que Cargo CITARA COR-12, no dónde
  vive. **[APLICADO 2026-07-20]** *(el registro, no la decisión)*

- PARCHE 8 — **El defecto del gate que bloqueaba el 2.º COMPLETO, y su CLASE.** La columna
  `total` de `CORPUS_COMPLETO` se había desincronizado otra vez: `corpus_flujo_trabajo.txt`
  **720 → 737**. Causa: dentro de la MISMA tanda D-13, el PARCHE 9 reescribió §7.8 **después**
  de que el PARCHE 10 derivara los conteos — **las últimas 17 líneas del doc más normativo del
  ecosistema quedaron fuera del rango de tramos, y §7.8 se auditó a sí mismo con la cola
  cortada.** Re-derivadas las 32 filas con `@(Get-Content).Count`; las otras 31 cerraban
  exactas. **[APLICADO 2026-07-20]**

- PARCHE 9 — **FASE 0 «Conteo»: `total` deja de ser una constante y pasa a ser un CHECKSUM.**
  Arreglar la instancia no arregla nada: mientras el número se escriba a mano se vuelve a
  desincronizar en la próxima tanda que edite un doc. El runtime de los scripts de Workflow
  **no tiene filesystem ni APIs de Node** (no hay `readFileSync`), así que derivar dentro del
  `.js` era imposible — se delega en un agente con Bash que devuelve los 32 largos por schema.
  Desde ahora **los TRAMOS se arman con el valor DERIVADO**; si discrepan **gana el árbol** y
  el desfase **viaja hasta el acta**. No se aborta —abortar dejaría al autor sin gate justo
  después de editar un doc— y si la fase 0 muere, cae a la constante **declarándolo**, nunca
  en silencio. **[APLICADO 2026-07-20]**

- PARCHE 10 — **Huecos 4 y 5 del acta: que el próximo «limpio» no vuelva a mentir.**
  (a) Los 18 TEMAS ganan campo `sedes` y una tabla `TEMAS_ESTADO` con **cinco** estados
  (`limpio` / `N/A por alcance` / `sin normas que cruzar` / `NO CRUZADO` / N hallazgos);
  el acta gana una sección **4.ter obligatoria** y queda **prohibido colapsarlos en un cero**
  — un cero vacío por construcción hoy era indistinguible de un cero ganado. (b) `DOCS_SIN_IDS`
  se deriva del glosario y se reporta **`N/A - sin IDs propios`** en vez de `limpio`, y recibe
  un **PASE DE VALOR** contra el árbol. El Hueco 3 probó el costo: la etiqueta
  «NO-AUDITABLE POR DISEÑO» se leyó como permiso para **no mirar el doc**, y adentro había un
  hecho falso. **[APLICADO 2026-07-20]**

- PARCHE 11 — **Espejo `desktop-sync/` regenerado.** El acta (Hueco 8) pide que la reparación
  **no se dé por cerrada hasta que el espejo se regenere**: `Corpus_convenciones_commits.txt:120`
  replicaba la misma cifra caduca. Es downstream y lo produce `sync.ps1`, pero es un **segundo
  consumidor de estos docs que ningún gate audita**, y donde el drift se materializa como
  respuestas de un asistente. Al regenerarlo entra por primera vez `Cortex_ContratosEntrantes.md`:
  Cortex deja de ser el repo «sin docs» también para el RAG de Desktop. **[APLICADO 2026-07-20]**

**Registro:** `D-14` ABIERTA (voto del autor). Sin IDs nuevos: **207**. Dos `titulo` de
`ids.yaml` actualizados (COR-15, COR-16) para que sigan coincidiendo con su sede — el gate
cruza exactamente eso.

**Lo que esta tanda NO hizo, y por qué:** no se editó el acta del 2026-07-20 (**AUD-4**), ni
siquiera para corregir su erratum conocido —§4.bis PARCIAL 2 cita `corpus_selftest.lua:55` y
el `print` real arranca en la **56**; la 55 es `local fallas = 0`—. Un acta es la foto al
momento de auditar: **si algo cambia, lo dice el acta siguiente**, y esta entrada lo deja
dicho. Tampoco se corrió el 2.º COMPLETO (lo dispara **AUD-2** al cerrar el Block 3 de
Coagulant, en sesión fresca) ni se tocaron los Huecos 1, 6, 7 y 8, que son de esa tanda.

Verificación: checker en verde sobre **207 IDs / 10 familias** + suite **12/12** +
`node --check` del `.js` del gate. **Sin superficie de runtime: ni una línea de Lua cambió**,
y **ningún check de planilla nace de esta tanda** (FLU-37) — su verificación es el checker,
no una ronda en juego.

> **La primera corrida del gate después de esta tanda estrena la fase 0, los cinco estados
> por bucket y el pase de VALOR.** Si algo de eso se rompe, es de acá: mirá en el `.js` antes
> que en el corpus.

---

## PARCHES DE sesión Voto D-14: COR-12 se queda — 2026-07-20

Cierra el voto que la tanda anterior dejó abierto. **El autor votó: COR-12 SE QUEDA en el
framework**, aceptando la recomendación tal cual se elevó.

- PARCHE 1 — **`CORPUS_Architecture.md` §5 gana la justificación, porque la sede es la que
  manda (FLU-22).** COR-12 **no gobierna ítems**: gobierna el **protocolo de registro entre
  módulos** —dónde se registra una def y desde qué realm es invocable su callback—, del mismo
  linaje que **COR-3** (persistencia namespaced) y **COR-4** (net namespaced). Las tres
  nacieron para evitar colisión entre consumidores y a ninguna se la llama dominio. Bajarla a
  Cargo la convertiría en **norma de un módulo sobre otros módulos**, que es exactamente lo
  que COR-11 evita. **[APLICADO 2026-07-20]**

- PARCHE 2 — **La cláusula de reapertura, que es parte del voto y no una glosa.** COR-12
  enuncia solo la **FORMA** del contrato, **jamás la SEMÁNTICA** del ítem: el día que mencione
  stacks, peso o slots, bajó dominio al framework y **el voto se reabre**. Es lo que hace
  **falsable** la decisión — sin esa cláusula, «es protocolo y no dominio» sería una etiqueta
  inauditable, y el voto habría cerrado la pregunta sin resolverla. Con ella, COR-12 **no
  contradice** a COR-1 ni a COR-10: los **delimita**. Lo que no sube es la semántica.
  **[APLICADO 2026-07-20]**

- PARCHE 3 — **`D-14` CERRADA y la nota de COR-12 en `ids.yaml` al día.** La nota decía
  *«Vive en el framework y no en Cargo — ver deuda D-1, que es seria»*: la tensión quedaba
  archivada como deuda en vez de resuelta. Ahora remite al voto. **Y se le quita la
  autodeclaración** *«Ésta es la ÚNICA sede que enuncia las dos mitades con su razón»* — era
  el drift que el Hueco 7 del acta describe (el registro **excediendo** a su sede, cuando
  `ids.yaml` es **índice, jamás segunda definición**), y ya no es cierta: §5 las enuncia. La
  reparación correcta de ese modo de falla es **mover el contenido a la sede, no borrar la
  nota** — es lo que hace el PARCHE 1. **[APLICADO 2026-07-20]**

**Registro:** `D-14` CERRADA. `D-1` y `D-14` cierran juntas la pregunta entera: **D-1 cerró
que Cargo la CITARA; D-14 cierra DÓNDE VIVE.** Sin IDs nuevos: **207**.

Verificación: checker verde sobre 207 IDs + suite 12/12. **Sin superficie de runtime** — el
voto no cambia una línea de Lua: las defs de Coagulant y Craving ya cumplían COR-12 y siguen
donde estaban. Lo que cambió es **por qué** la norma vive donde vive, y **bajo qué condición
se reabre**.

---

## PARCHES DE sesión Cierre del Block 3 — Coagulant verificado en juego — 2026-07-20

La **ronda 7** de Coagulant pasó **13/13** (reporte del autor por planilla, incluida la L1
opcional del modo degradado) y **su Block 3 CERRÓ**. Acá va solo lo que toca a ESTE repo —
los ítems 2 y 5 de la checklist de cierre (`Coagulant_Architecture.md` §16) más el registro
y el espejo; el detalle de la ronda, los fixes que dejó y las dos decisiones de diseño
abiertas viven en el CHANGELOG y el estado de `corpus-coagulant/`.

- PARCHE 1 — docs(docs): `CORPUS_Architecture.md` §9 — la fila del **Block 3** pasa de «En
  bajada» a **Cerrado (2026-07-20)**, con la mini-ronda pendiente y las decisiones de
  diseño remitidas al repo del módulo. **[APLICADO 2026-07-20]**

- PARCHE 2 — docs(docs): `corpus_estado.md` — Coagulant deja de ser el bloque en curso
  (§16 ítem 5: **tiene módulo real, ya no es scaffold**) y la deuda de verificación del
  autor pasa a la mini-ronda 8; `corpus_roadmap.txt` — el tramo [3] pasa a CERRADO con sus
  remanentes (mini-ronda, decisiones de diseño, D-5 con Craving). **[APLICADO 2026-07-20]**

- PARCHE 3 — docs(docs): `ids.yaml` — **COA-12, COA-23 y COA-33 ganan su evidencia de
  planilla** (J4, K2 y J3 de la ronda 7); COA-33 deja de ser INTENCION y suma además su
  ref de harness. Primera tanda que acredita checks de planilla post-norma en la familia
  COA — el «hacia adelante» que D-2 pedía. **[APLICADO 2026-07-20]**

- PARCHE 4 — chore(workspace): espejo Code→Desktop regenerado (`sync.ps1`, 7 repos, 44
  archivos; propósito: «cierre del Block 3»). **[APLICADO 2026-07-20]**

Verificación: checker en verde sobre 207 IDs — una pasada intermedia cazó `EVIDENCIA_ROTA`
en COA-33 (el check J3 citado en el registro no dejaba rastro citable en el repo) y se
reparó citando J3 explícito en el CHANGELOG del módulo, que es exactamente el trabajo del
checker. Sin superficie de runtime en este repo: ni una línea de Lua del framework cambió.

---

## PARCHES DE sesión Banco de sonidos del ecosistema — 2026-07-24

Decisión del autor: los sonidos GENERALES (ports de STALKER GAMMA) viven en Corpus y cada
módulo consume los suyos; los sonidos del addon de contenido quedan para sus propios ítems
(separación sonidos/ítems). Hospedar el banco NO viola COR-10: es infraestructura de assets
compartida por tres módulos, sin una línea de lógica de dominio.

- PARCHE 1 — chore(workspace): **nace el banco de sonidos default** `sound/corpus/` — los 201 .ogg
  de GAMMA que trajo el autor (árbol plano `sound/interface/`), reorganizados por consumidor:
  `cargo/{ui,items,containers,attachments,equipment,gasmask,workbench}`, `coagulant/`,
  `craving/{,cooking}` y `shared/`, con `about.txt` por carpeta que preserva las notas del
  autor (mapa de la selección por categoría, intensidades del gasmask, la nota male-oriented).
  **Gasmask queda como EXTRA de Cargo** (los sonidos del futuro overlay de casco cerrado —
  roadmap #44 de Cargo). Ningún "duplicado" se borró: los tres `.ogg.ogg`, los `_OLD`/`.bak` y
  los homónimos de `item_usage/` eran variantes con hash distinto — se renombraron
  (`cloth_4-6`, sufijo `_2`, `injector_using_old`, `eat_mre_2`; mapa completo en
  `sound/corpus/about.txt`). Consumidores cableados en esta misma tanda: Cargo (entry 35) y
  Craving (su sesión de hoy); Coagulant solo DOCUMENTADO (COA-28: sin decisión del autor no se
  implementa — mapa sugerido en `sound/corpus/coagulant/about.txt`). **[APLICADO 2026-07-24]**
  (verificado en juego por el autor desde los consumidores: Cargo entry 35 y la sesión de Craving)
- PARCHE 2 — docs(docs): **COR-17 acuñada** — los assets de terceros no se versionan en el
  framework: `.gitignore` excluye `sound/**` y re-incluye los `about.txt` (documentación
  propia, MIT-safe). Mismo régimen que STK-2; sede el contrato 10 del CLAUDE.md, entrada en
  `ids.yaml` en el mismo parche (§7.4). Verificado: `git check-ignore` ignora los .ogg y deja
  pasar los about.txt. **[APLICADO 2026-07-24]**

Verificación: sin superficie de runtime en este repo (ni una línea de Lua del framework
cambió — el banco es data). Los consumidores se verificaron en juego desde sus repos
(Cargo entry 35 a-e ✓, Craving ✓; confirmado por el autor el 2026-07-24). Commiteado y
pusheado con autorización del autor.

---

## PARCHES DE sesión Corpus.Data gana List, Delete y scope — 2026-07-25

Primera vez que el framework recibe código desde el 2026-07-09. El disparador vino de
Cargo: la medición de su persistencia dio **354 instancias huérfanas sobre 370 archivos**
(CHANGELOG de Cargo #41), y al arreglarlo quedaron dos huecos que son del framework, no
del módulo — no había forma de ENUMERAR ni de BORRAR una clave por la primitiva, y nada
distinguía el catálogo del servidor del estado de una partida. La superficie de `Corpus.Data`
crece; **el número de primitivas NO**: Data sigue siendo UNA de las seis (COR-10).

- PARCHE 1 — feat(data): **`corpus_data.lua` gana `List`, `Delete` y el parámetro `opts`.**
  `List(module, opts)` devuelve las claves sin extensión, ordenadas, y `{}` —jamás `nil`—
  cuando no hay carpeta o no hay archivos: quien la llama va a iterarla. `Delete(module,
  key, opts)` borra y devuelve `true` si el archivo existía, `false` si no, saneando
  `module` y `key` con el **mismo** `sanear` que ya usaban `Save` y `Load` — una primitiva
  de borrado sin ese saneo es un agujero de path traversal, no una comodidad.
  La pieza central es un **resolver de ruta interno** (`RutaDe`) que hoy devuelve **lo
  mismo para los dos scopes a propósito**: es el gancho, no el efecto. **[APLICADO 2026-07-25]**
- PARCHE 2 — feat(data): **COR-19 acuñada — el scope.** `opts = { scope = "config" |
  "save" }`, opcional; ausente significa `"save"`. "config" es config de SERVIDOR
  (sobrevive a borrar una partida); "save" es ESTADO DE PARTIDA (muere con ella).
  El default es `"save"` porque es la mayoría de los call sites y el que se MUEVE el día
  que las rutas se separen: un módulo que nunca se enteró de este parámetro queda del lado
  correcto **solo**. Un scope desconocido es un `error()` y no un silencio — es la clase de
  typo que hoy no se nota (las dos rutas coinciden) y que mañana manda un archivo a la
  carpeta equivocada. Sede: §3 de la arquitectura, con la tabla de quién es config y quién
  estado **derivada de un grep del árbol**, no de la prosa (FLU-27). **[APLICADO 2026-07-25]**
- PARCHE 3 — feat(data): **`corpus_selftest` extendido, no reescrito.** El bloque de Data
  suma siete checks: que `List` encuentre la clave recién escrita, que `Delete` devuelva
  `true` la primera vez y `false` la segunda, que `Load` post-`Delete` devuelva `nil`, el
  round-trip declarando `config`, la constatación de que los dos scopes resuelven igual, y
  el `error()` del scope desconocido. **Deja el namespace `selftest` limpio al terminar**:
  un selftest que ensucia el disco del autor es un defecto. **[APLICADO 2026-07-25]**
- PARCHE 4 — docs(docs): **COR-18 acuñada y COR-3 enmendada.** COR-18 (sede: contrato 3 del
  CLAUDE.md, del que es la otra mitad) dice que toda persistencia de estado propio pasa por
  la primitiva. Su redacción se decidió ABRIENDO EL ÁRBOL: rige **tablas**, y los artefactos
  que `Corpus.Data` no sabe guardar quedan fuera **por construcción** (el dump de texto
  plano `weapon_dump.txt`, los PNG del caché de íconos), igual que `file.Exists(..., "GAME")`,
  que es detección de assets (COR-5/COR-17) y nunca fue persistencia. Se dice así en la nota
  en vez de acuñar una norma que el código desmiente el día 1. **La deuda queda declarada
  con su motivo**, no omitida — ver abajo. COR-3 conserva sede, fuerza y su invariante
  (nadie escribe fuera de su namespace), pero su ruta deja de ser un literal para siempre:
  la resuelve el scope. **[APLICADO 2026-07-25]**
- PARCHE 5 — docs(docs): **barrido de ratificación** (§7.3, barriendo **por el valor**): el
  mapa de archivos y el contrato 3 del `CLAUDE.md`, §3 de la arquitectura (tabla de
  primitivas + firmas ilustrativas), el alcance `data` de las convenciones de commit, la
  cadena del slice vertical y la checklist de §4 del flujo, y la foto de HOY, donde
  `Corpus.Data.Delete` figuraba como "primitiva candidata que asoma desde los módulos" —
  ya no es candidata, existe (el gate de admin, que compartía ese párrafo, **sigue vigente**
  y por eso el párrafo se reescribe en vez de borrarse). En el registro se anotaron además
  **N y O**, dos secciones de planilla de Coagulant que se habían usado sin pasar por FLU-30,
  y **T**, la letra de la primera planilla del framework, registrada ANTES de usarse.
  **[APLICADO 2026-07-25]**

- PARCHE 6 — feat(data): **`corpus_selftest_cl`, alias CLIENT-only del selftest.** Lo pidió la
  verificación, no el diseño: el realm CLIENT del framework era **inverificable en juego**.
  `corpus_selftest.lua` es shared, así que su concommand queda registrado en los dos realms y
  en un listen server gana el del SERVER —tipearlo en la consola del host devuelve el bloque
  `(SERVER)` y nunca llega al cliente—, y `lua_run_cl` no es salida porque lo gatea
  `sv_allowcslua`, que viene en 0 y no se cambia por correr un test. Un nombre propio,
  registrado solo `if CLIENT`, es lo único que no colisiona ni le toca la config al autor.
  Sin gate de superadmin: corre en la máquina del que lo tipea, escribe en SU `data/` y limpia
  lo que escribió. **[APLICADO 2026-07-26]** (fecha distinta a la de los otros cinco a
  propósito: este parche nació de la ronda 2 y se confirmó al día siguiente)

**Lo que esta tanda NO hace, a propósito:** no mueve un solo archivo (el layout de perfiles
es un bloque posterior y toca solo el resolver), no migra a Caliber, Craving ni Coagulant
(cada dueño lo decide cuando quiera, y el default los deja correctos mientras tanto — el
`config`/`scav_weights` de Caliber es config de servidor sin declarar, y no rompe nada
porque las dos rutas coinciden), y no inventa un gate de admin para el comando de purga:
CRG-45 sigue esperando la primitiva de permisos, y por eso el dry-run es el default.

**Deuda declarada por COR-18** (voto del autor, 2026-07-25): los dos sidecars JSON del
caché de íconos de Cargo (`mesh_bounds.json`, `icons_meta.json`) SÍ son tablas de estado
propio y SÍ caen adentro de la norma, y hoy no pasan por la primitiva. El motivo es del
árbol y no de la comodidad: viven en `data/corpus/cargo/icons/` junto a los PNG que
indexan, y el saneo de `key` bloquea el separador, así que `Corpus.Data` **no puede
direccionar una subcarpeta**. Migrarlos hoy partiría el caché en dos lugares y movería
archivos — justo lo que esta tanda no hace. El detalle vive en la nota de COR-18 en
`ids.yaml`.

Verificación offline: `dev/harness_cargo.py` **ALL GREEN en ambos realms, 389 checks**
(eran 373); 16 nuevos ejercen la primitiva del framework desde el harness que ya lo carga
—no existe `dev/harness_corpus.py`, y el precedente de acreditar una norma COR contra el
harness de un módulo es COR-12 contra `harness_coagulant.py`—. Se corrigió de paso el stub
de `file.Find`, donde `*` cruzaba carpetas y el engine no lo hace: sin ese arreglo, un
`List` del harness veía archivos de subcarpetas que en juego no vería.
Deuda anotada, no saldada: crear `dev/harness_corpus.py` propio y probar dónde quedaron
los 46 checks históricos del framework que la foto de HOY sigue citando.
EN JUEGO: planilla **T** — sección nueva y **primera planilla del framework** (decisión del
autor: corpus estrena la suya; la de Cargo, con P/Q/R/S, es otra y vive en su propia URL).
La letra T quedó registrada en `familias_excluidas` ANTES de usarse (FLU-30), y no se tomó
Q/R/S porque están presupuestadas para Cargo.
Planilla: https://claude.ai/code/artifact/fc204b66-e751-42a2-af8a-0c02429934bd
T1 arranque limpio · T2 selftest server (las 7 líneas nuevas de data) · T3 el selftest deja el
disco limpio · T4 selftest client · T5 **verificación negativa**: nada de lo viejo cambió ·
T6 el catálogo `scope=config` sobrevive el reinicio · T7 la purga en dry run no borra nada ·
T8 `confirm` borra solo los `inst_*` · T9 el inventario sobrevive a la purga.

**RONDA 1 (2026-07-25) — el autor reportó los nueve en PASA, y se adjudicaron SIETE.** T1, T2,
T3, T5, T6, T8 y T9 vuelven con evidencia que los respalda; los parches de arriba pasan a
`[APLICADO]` por eso. **T4 y T7 quedan ABIERTOS**, y no por un defecto del código sino porque
la corrida no ejerció lo que el check pide — lo dijeron sus propias notas, aplicando §7.3 (b):
una cita se adjudica ABRIENDO la evidencia.
  · **T4** — el bloque pegado dice `===== selftest (SERVER) =====` por segunda vez y le falta la
    línea `[--] ui: check visual`, que solo se imprime `if CLIENT`. En un LISTEN SERVER el
    concommand tipeado en la consola del host corre el realm SERVER. **La culpa es del header de
    `corpus_selftest.lua`**, que afirmaba "consola del cliente: `corpus_selftest` (corre el realm
    CLIENT)" — de ahí lo copió la planilla. El header queda corregido con lo observado y el check
    pasa a `lua_run_cl Corpus._SelfTest()`. Es drift de un comentario de Lua bajando a un
    artefacto de verificación: exactamente el vector de §7.2.
  · **T7** — la consola devolvió `no quedan claves inst_* legacy`, que es el atajo de salida:
    la carpeta todavía no tenía los `inst_*` (el autor los trajo de la papelera después, para
    T8). La rama que hay que ver —listar sin borrar— no corrió. La preparación de la planilla
    ahora dice que los archivos van PRIMERO, y qué salida significa que no estaban.
**Ninguno de los dos deja el código en duda:** los dos caminos están verdes en el harness
(`el DRY RUN no borra nada`, y la pasada CLIENT completa en ambos realms). Lo que falta es la
evidencia EN JUEGO, y por eso la planilla los marca «re-correr» en vez de darlos por buenos.

**RONDA 2 (2026-07-25) — T7 cerrado, T4 en ✗ y el ✗ tenía razón.** T7 volvió PASA. T4 devolvió
"no veo nada en consola" con `lua_run_cl`, y ahí se vio que el problema no era la vía sino que
**no había ninguna**: entre el registro shared que gana el server y `sv_allowcslua` en 0, el
realm CLIENT del framework no se podía ejercer en juego de ninguna forma. Por eso el arreglo
fue al CÓDIGO (PARCHE 6) y no a la planilla otra vez. Es el hallazgo más útil de la tanda, y no
lo produjo un check verde: lo produjo insistir con el único que no lo estaba.
Harness: **393 checks** (eran 389); los 4 nuevos fijan la asimetría —`corpus_selftest_cl`
existe en CLIENT y NO en SERVER, que es justo lo que lo hace alcanzable—.

**RONDA 3 (2026-07-26) — T4 en verde y la sección T cerrada 9/9.** El bloque que devolvió el
autor trae el encabezado `===== selftest (CLIENT) =====` y la línea `[--] ui: check visual`,
que en el realm SERVER no se imprime: esta vez la evidencia respalda al check. **Los seis
parches quedan `[APLICADO]` y la tanda cierra.**

**Lo que deja como método, y es lo más reusable de la tanda:** de los tres reportes, dos
volvieron con checks marcados PASA que no habían corrido, y las dos veces los delató el CAMPO
DE NOTAS —no el estado—. Si la planilla aceptara solo ✓/✗, como pedía el formato anterior al
2026-07-14, T4 habría cerrado como verificado en la primera ronda y el realm CLIENT del
framework seguiría siendo inverificable sin que nadie lo supiera. §1 PASO 4 (c) del flujo dice
que un formulario de dos estados "tira a la basura justo lo más valioso"; acá se cobró la
apuesta. El corolario operativo es §7.3 (b): un ✓ se adjudica ABRIENDO su evidencia, y el
hallazgo más caro de esta tanda no salió de ningún check verde — salió de insistir con el
único que no lo estaba.

---

## PARCHES DE sesión La ready barrier no disparaba en el realm CLIENTE — 2026-08-08

Sesión de **diagnóstico**, abierta por un reporte del autor que parecían dos problemas
distintos —*«no me llegaron los ítems»* y *«en el inventario dice que no reconoce módulos
cargados»*— y era **uno solo**, en la primitiva 5. Veredicto completo, con la evidencia y
la cadena entera: [`dev/VEREDICTO_ready_barrier_cliente.md`](../../dev/VEREDICTO_ready_barrier_cliente.md).

**El hecho.** `corpus_ready.lua` colgaba la barrera de un solo hook, `InitPostEntity`, y
**ese hook no llega al realm CLIENTE**. Medido tres veces, independientes entre sí:
`corpus_selftest_cl` daba `readyFired=false corridas=0` contra `true`/`1` en server; en los
**dos** arranques del `console.log` ninguna de las líneas `(…, client)` de los cross-registros
salió jamás; y las dos líneas client-only de las barras del StatusPanel no están en el log en
ninguna parte. Discriminante limpio dentro del mismo realm: **`Initialize` SÍ dispara** en
cliente —de ahí salen los cuatro `cargado (client)`— e `InitPostEntity` no. No era orden de
carga ni archivo faltante: `Corpus.OnReady` existe en el cliente, el hook quedó puesto, el
evento no llegó. **POR QUÉ no llega sigue sin medir, y el remedio no depende de saberlo.**

**Lo que costaba: 4.413 defs y 3 barras, sin un solo error de Lua.** Todo lo que se registra
dentro de `Corpus.OnReady` quedaba colgado en `_readyQueue` en el realm que DIBUJA — 4 defs
médicas de Coagulant, 15 de comida de Craving, **4.394 de attachments ARC9**, las 3 barras del
StatusPanel, la sustitución de modelos de `corpus-stalker`, el `RefreshTheme`. **COR-12** existe
justamente porque Cargo no sincroniza defs de módulo por red: la barrera rota anula el realm
cliente y deja el contrato incumplido **aunque el archivo esté bien escrito**. Sin def, el grid
no omite la entrada — **dibuja la celda vacía** (`corpus_cargo_grid.lua:44`, el `return` va
después del fondo y el borde). Lo único que el jugador veía eran armas y munición: las defs
`autogen`, el único set que Cargo sí manda en el snapshot.

- PARCHE 1 — `corpus_ready.lua`: **la barrera deja de colgar de un solo hook** (voto del autor
  entre dos formas, 2026-08-08). Se extrae `Fire(source)`, **idempotente por `_readyFired`**, y
  se le agrega un **respaldo CLIENT-only**: el primer `Think` con `LocalPlayer()` válido, que se
  desengancha solo. Tardío a propósito — `Initialize` ya corrió, así que la garantía que la
  barrera promete (todos los módulos presentes ya registrados) se sostiene por esta ruta igual
  que por la otra. Si en una instalación `InitPostEntity` SÍ llega, dispara primero y el
  respaldo es un no-op. Restituye **COR-5** (detección, nunca asunción) aplicada al propio
  framework; la asunción rota estaba escrita en `corpus_cargo_init.lua:155`. **[APLICADO
  2026-08-08]**
- PARCHE 2 — `corpus_ready.lua`: la barrera **habla siempre, no solo cuando algo sale mal**.
  Nuevo `Corpus._readySource` y una línea de log con la ruta que disparó y **cuántos wirings se
  soltaron**, por realm. Con esa línea, «la barrera no disparó en este realm» se ve LEYENDO el
  log, sin correr un selftest — que es como esto pasó dos arranques enteros con el log en verde.
  **[APLICADO 2026-08-08]**
- PARCHE 3 — `corpus_selftest.lua`: segundo check de ready, **`#Corpus._readyQueue == 0`**. El
  check viejo decía que la barrera no había disparado y nada más; lo que había detrás eran 4.413
  registros perdidos. La cola mide el **daño**, no el hecho. El check viejo suma la `fuente` a su
  detalle. **[APLICADO 2026-08-08]**

**Lo que deja como método, y es lo más caro de la tanda.** El análisis previo tenía el defecto
**escrito en la evidencia que estaba usando para descartarlo**: cuatro líneas decían `(4 defs,
server)`, `(15 defs, server)`, `(2/2, server)`, y se citaron como *«los cross-registros
funcionaron»*. El string lo arma `SERVER and "server" or "client"` — **que la mitad `client` no
aparezca nunca era el hallazgo**, y el par de control estaba al lado (`cargado (server)` **y**
`(client)`). *Cuando una línea se imprime una vez por realm, contarla una sola vez no es una
confirmación.* Y el plan de checks proponía `cargo_dev_items` y un `lua_run` para decidirlo: los
dos son shared, en listen server **gana el server**, y habrían salido verdes midiendo el único
realm sano. De los cinco checks propuestos, el único que tocaba el realm roto era el selftest de
cliente, y fue el único rojo. **En un programa con dos realms, «¿dónde corre este check?» es
parte del check** — y si para el realm sospechoso no existe instrumento, eso no es un detalle:
es la razón por la que el defecto sobrevive.

**Pendiente: la pasada en juego del autor.** El harness **no puede** reproducir esto —su stub
dispara `hook.Run("InitPostEntity")` en los dos realms por construcción, así que la ruta rota no
existe ahí—. Lo que el harness sí acredita es que la barrera nueva funciona y no rompió nada:
`harness_cargo.py` **828 verdes** con la línea nueva imprimiendo `2 wiring(s) … (server)` y
`3 … (client)`, y `harness_coagulant.py` / `harness_craving.py` en verde. **El verde offline no
cierra este bloque**; lo cierra ver las líneas `(…, client)` en el log y los ítems en el grid.

### Pasada en juego (2026-08-08) — CIERRA, y el instrumento nuevo corrigió el diagnóstico

Reporte del autor: *«el inventario se ve bien como antes, tengo todo lo que debería tener»*, con
los tres bloques de consola pegados. Los cuatro criterios del veredicto, uno por uno:

- **`corpus_selftest_cl` en verde**, incluido el check nuevo: `readyFired=true corridas=1
  fuente=fallback` y `_readyQueue=0`. **`fuente=fallback` es el resultado que discrimina, y hay
  que leerlo bien: `InitPostEntity` SIGUE sin llegar al realm cliente.** El defecto se reprodujo
  esta corrida y lo que disparó fue el respaldo del PARCHE 1. No se arregló el hook — se lo
  rodeó, y el PARCHE 2 hace que eso se vea en cada arranque en vez de haber que deducirlo. Si un
  día la línea dijera `InitPostEntity`, sería noticia.
- **Las líneas `(…, client)` que no existían, todas presentes:** `ítems médicos registrados
  contra Cargo (4 defs, client)`, `consumibles registrados contra Cargo (15 defs, client)`,
  `modelos de ítem sustituidos: 2/2 (client)`, las dos de barras del StatusPanel y el puente ARC9.
- **`cargo_dev_items_cl`: 51 defs no-bulk + 4.467 bulk en el realm CLIENT**, con las 4 de
  Coagulant y las 15 de Craving en sus categorías. El catálogo que el grid renderiza existe.
- **El inventario y el panel.** Las 5 barras (Health, HL2 Armor, Blood, Hunger, Hydration) en
  lugar del `"No bars registered (absent modules)"`, y el grid con los ítems médicos, la comida y
  los attachments.

**Lo que el instrumento agregó al diagnóstico, y es la parte que vale.** La línea del PARCHE 2
dijo **`9 wiring(s)`**. El veredicto había enumerado **ocho** sitios leyendo el árbol; el noveno
es `persona de Sidorovich registrada: 19 líneas (client)` de `corpus-stalker`, que también estaba
colgado y **no estaba en la tabla**. *Una enumeración hecha a mano sobre el código se parece
mucho a un censo y no lo es: el contador del propio mecanismo encontró uno más.* El conteo no era
adorno del log — era el control de la enumeración.

Con esto los **3 parches quedan verificados en juego** y el bloque cierra. Sigue **abierto y sin
medir** (declarado, no olvidado): *por qué* `InitPostEntity` no llega al realm cliente. El
respaldo lo cubre y la línea de log lo hace visible; no lo explica.

---

## PARCHES DE sesión Arco B: el testigo de InitPostEntity — 2026-08-08

Continuación del bloque anterior, sobre **lo único que había quedado abierto**: *por qué*
`InitPostEntity` no llega al realm CLIENTE. Encargo: `dev/PROMPT_quickslots_x0_e_initpostentity.txt`
§4-§5. **La causa NO se identificó**, y eso es el resultado, no un fracaso: el prompt lo
autorizaba explícitamente porque el arco es **conocimiento, no funcionalidad** —la barrera ya
no depende de ese hook y el log dice qué ruta disparó, así que nadie está bloqueado—.

**Lo que sí se descartó** (barrido de `dev/other/`, la copia local de los mods de terceros):
**ningún** addon hace `hook.Remove("InitPostEntity", …)`; ninguno pisa `hook.Add`/`Remove`/
`Call`/`Run` ni el método `GAMEMODE.InitPostEntity`; y los **cuatro** `hook.GetTable()[…]` que
existen leen otros eventos (`CalcView`, `PostPlayerDraw`, `Think`) sin mutar la tabla. O sea:
**nadie nos desengancha**, y la hipótesis H2 («un tercero interfiere») se queda sin un mecanismo
a la vista. **Descartado no es probado:** `dev/other/` no tiene los 380 addons suscritos, así
que la ausencia ahí no prueba nada sobre lo montado.

**Lo que el barrido sí encontró, y es una predicción falsable.** Hay terceros que dependen del
MISMO evento en el MISMO realm: el `bm_init` CLIENT de Better Movement (`sh_bm_main.lua:226`,
`initialize_bm(LocalPlayer())`) y el `QuickLoadoutInit` de Quick Loadouts
(`cl_loadoutmenu.lua:1822`, cuyo `NetworkLoadout()` de arranque **solo** corre ahí). Si el
evento de verdad no llega al cliente en esta instalación, esos dos **también están muertos**, y
por la misma razón. No son nuestro código: son testigos ajenos, gratis.

**El defecto de MEDICIÓN que el barrido destapó, y es la parte que vale.** `fuente=fallback`
acredita **quién ganó la carrera**, y por lo tanto **no distingue dos causas distintas**:
«`InitPostEntity` nunca llega a este realm» y «llega, pero después del primer `Think`». Hoy las
dos imprimen exactamente la misma línea. El respaldo del bloque anterior rodeó el defecto y, sin
querer, **tapó la pregunta**. Un instrumento que no puede separar dos causas no está midiendo la
que importa — misma familia que los controles del catálogo de `dev/`.

- PARCHE 1 — `corpus_ready.lua`: **el hook de `InitPostEntity` pasa a ser también el TESTIGO del
  evento.** Queda puesto siempre y no se desengancha aunque el respaldo haya disparado antes;
  anota `Corpus._initPostEntitySeen` y, si llega con la barrera ya disparada por otra ruta,
  **lo dice en el log** (`InitPostEntity llegó TARDE: …`, con el realm). `Fire` sigue siendo un
  no-op en ese caso: **no cambia una sola conducta**, solo deja de callarse. Es el discriminante
  que el §5.2 del prompt pedía escribir, resuelto **sin un archivo nuevo**: un `hook.Add` de
  prueba en otro archivo de `lua/autorun/` no discrimina nada, porque se registra en el mismo
  momento que el nuestro y ya está medido que el nuestro se registró.
- PARCHE 2 — `corpus_selftest.lua`: el check `ready: dispara una vez` suma **`initPostEntity=
  llegó | NO llegó`** a su detalle. **A propósito NO es un check propio**: uno que siempre pasara
  sería un verde que no mide, y uno que fallara estaría reprobando a la barrera **por funcionar
  por su respaldo**, que es exactamente como se diseñó. El dato viaja en el detalle de un
  criterio que ya se corre, que es donde el autor ya mira.
- PARCHE 3 — `corpus_ready.lua`, header: la línea «POR QUÉ no llega sigue sin medir» pasa a
  **«sigue SIN IDENTIFICAR»** y se le cuelga lo descartado y los dos testigos ajenos, con
  archivo y línea. El hueco que el bloque anterior había reservado queda escrito (§5.3 del
  prompt) — con lo que se sabe, que es menos de lo que se quería.

**Verificación.** `harness_cargo.py` **828 verdes** (el conteo **no** sube y está bien: no se
acuñó ningún check, se enriqueció el detalle de uno existente), `harness_coagulant.py` y
`harness_craving.py` en verde. **El harness no puede acreditar nada de este arco**: su stub
dispara `hook.Run("InitPostEntity")` en los dos realms por construcción, así que ahí el evento
**siempre** llega y la rama nueva nunca corre. El verde acredita que no se rompió nada, y nada
más — igual que en el bloque anterior.

**Lo que cierra esto, y lo corre el autor:** el próximo `corpus_selftest_cl`.

### Medido el mismo día — `initPostEntity=NO llegó`, y el instrumento midió MENOS de lo previsto

`corpus_selftest_cl` del autor, entero en verde:
`readyFired=true corridas=1 fuente=fallback **initPostEntity=NO llegó**`, y la línea
`llegó TARDE` no apareció.

**Lo que eso prueba:** el evento no aparece **después** del respaldo. «Llega tarde» queda
descartado, y era una tercera causa que ni siquiera estaba en la lista de hipótesis.

**Lo que NO prueba, y el PARCHE 2 se había acreditado de más al escribirse:** que H1 quede sola
en pie. **H1 dice que el evento pasó ANTES de que se registrara nuestro hook** — y en ese
escenario `_initPostEntitySeen` queda en falso exactamente igual que si el evento no disparara
nunca. **Las dos causas producen la misma lectura**, así que el discriminante nuevo separó una
tercera y dejó las dos originales empatadas. *Un instrumento nuevo puede achicar la pregunta sin
contestarla, y decir que la contestó es el mismo error que este bloque viene pagando.*

- PARCHE 4 — `corpus_ready.lua` + `corpus_selftest.lua`: **`Corpus._worldAtLoad`**, medido UNA
  vez en file-scope, y reportado como `mundoAlCargar=sí|no` en el mismo detalle. Es lo único que
  separa las dos que quedan, y la inferencia es de ORDEN, no una teoría del engine:
  `InitPostEntity` corre **después** de que las entidades existen. **`no`** ⇒ cuando pusimos el
  hook el evento todavía no había ocurrido ⇒ el hook estaba a tiempo y el evento **nunca llegó**
  (H1 MUERTA). **`sí`** ⇒ el mundo ya existía al cargar el archivo, el evento pudo haber pasado
  y **H1 queda viva** — y entonces el problema no es el evento sino CUÁNDO corre nuestro autorun
  en esta instalación. Se lee en file-scope a propósito: leerlo más tarde contestaría otra
  pregunta. Guardado con `isfunction(game and game.GetWorld)` — en el harness `game` es un
  autoNoop y devuelve nil, así que ahí cae en `no` sin romper nada (828 verdes, sin cambio de
  conteo: sigue sin acuñarse un check).

### CERRADO — el evento NO SE DISPARA en el realm cliente (medido, mapa nuevo, 2026-08-08)

Segunda lectura del autor, en un mapa recién cargado, selftest entero en verde:

    ready: dispara una vez — readyFired=true corridas=1 fuente=fallback
                             initPostEntity=NO llegó  mundoAlCargar=no

**`mundoAlCargar=no` mata H1.** Cuando `corpus_ready.lua` cargó, el mundo todavía no existía;
`InitPostEntity` corre después de que las entidades existen, así que en ese momento el evento no
había ocurrido y **el hook quedó puesto a tiempo**. Sumado a `initPostEntity=NO llegó` leído
mucho después de conectar: **desde entonces el evento no llegó nunca**. Las dos hipótesis que el
arco B arrastraba desde el veredicto quedan resueltas — «llega tarde y el respaldo le ganó»
descartada por la lectura anterior, y **H1 («el evento pasó antes de que registráramos el hook»)
muerta por ésta**. De yapa, la premisa que este archivo declara en su línea 3 —autorun corre
antes que `InitPostEntity`— pasó de asunción a **medición** en el realm cliente.

**Lo que esto le hace al parche del bloque anterior: lo asciende.** El respaldo CLIENT-only
dejó de ser «rodear un defecto sospechado» y pasó a ser **la ruta normal de un realm donde el
evento demostrablemente no existe**. `fuente=fallback` en cliente es el resultado ESPERADO, no
una degradación. Es COR-5 sostenida por evidencia en lugar de por prudencia.

**Lo que queda abierto, y es mucho más chico:** si la ausencia es conducta de GMod en listen
server o un tercero de los 380 suscritos. El barrido de `dev/other/` no encontró a nadie que nos
desenganche **por nombre**, así que un tercero tendría que estar matando el evento **para todos**
— y en ese caso da igual quién sea: el hecho medido es el mismo y el remedio también. Separar
esas dos costaría una instalación limpia, por cero ganancia funcional. **No se persigue.**
Testigos ajenos disponibles gratis si alguna vez importa: `sh_bm_main.lua:226` (Better Movement)
y `cl_loadoutmenu.lua:1822` (Quick Loadouts) dependen del mismo evento en el mismo realm.

Los tres instrumentos (`initPostEntity=`, `mundoAlCargar=`, la línea `llegó TARDE`) **se quedan**:
son lo que haría visible que un parche de GMod devuelva el evento algún día.

---

## PARCHES DE sesión Arco B ronda 2: el evento SÍ se dispara — el arco anterior se cerró mal — 2026-08-09

Encargo: `dev/PROMPT_arcoB_ronda2_initpostentity.txt`. El §3.1 pedía reparar una deriva de doc y
el §3.2 mirar dos testigos ajenos. **Los testigos contestaron, y contestaron que la conclusión
del bloque anterior era falsa.**

### El hecho, y reemplaza al que este CHANGELOG dio por CERRADO el 2026-08-08

**`InitPostEntity` SÍ se dispara en el realm CLIENTE.** Lo que no corre es **nuestro callback**.
Los dos enunciados producen exactamente la misma lectura del selftest y **no son la misma
afirmación**; el bloque anterior escribió el segundo y concluyó el primero.

**La medición** — `garrysmod/console.log`, 61.397 líneas, **nueve** arranques de mapa. En el
arranque que rodea a la 2.ª lectura del selftest (líneas 18024-18231), realm CLIENTE:

| # | Línea del log | Qué acredita |
|---|---|---|
| 1 | los cuatro `cargado (client)` | el boot diferido a `Initialize` ya corrió ⇒ todo `autorun` cargó ⇒ **nuestro `hook.Add` ya estaba puesto** |
| 2 | `[Quick Loadouts] Generating weapon table...` | **su callback de `InitPostEntity`, realm CLIENTE**, corrió |
| 3 | `ready barrier: 9 wiring(s) disparados por fallback (client)` | la barrera disparó por el respaldo |
| 4 | `ready: dispara una vez — … initPostEntity=NO llegó mundoAlCargar=no` | nuestro callback nunca corrió |

El paso 2 aparece en los **nueve** arranques, siempre **11-12 líneas** antes del paso 3.

**Por qué el paso 2 no puede venir de otra ruta** (que es lo que lo vuelve prueba y no indicio):
`cl_loadoutmenu.lua` se `include`a **sólo** en la rama CLIENT de `chensquickloadout.lua:8`, así
que su `hook.Add("InitPostEntity", "QuickLoadoutInit")` de `:1822` es del realm cliente.
`GenerateWeaponTable()` tiene tres llamadores: ese hook, el armado del menú (`:583`) y el
concommand `quickloadout_reloadweapons` (`:1850`). El menú exige **una tecla**, y una tecla exige
un `LocalPlayer()` válido — que es la condición del paso 3, **posterior**. El concommand no
aparece **ni una vez** en las 61.397 líneas. Queda el hook.

### El mecanismo — está en la fuente del engine, en disco, y no es una teoría

`garrysmod/lua/includes/modules/hook.lua`, función `Call`:

```lua
for k, v in pairs( HookTable ) do
    a, b, c, d, e, f = v( ... )
    if ( a != nil ) then return a, b, c, d, e, f end   -- ABORTA LA CADENA
end
```

Un tercero que devuelva **cualquier** valor no-nil en `InitPostEntity` deja sin evento a todos
los oyentes que caigan después de él en el orden de `pairs()` sobre una tabla hash: **sin conocer
nuestro nombre, sin desengancharnos y sin un solo error de Lua.** Es lo único que explica lo que
las hipótesis viejas no explicaban — por qué un tercero corre y nosotros no, en el mismo evento,
el mismo realm y el mismo arranque.

**Y tumba el argumento de economía con el que el arco se cerró.** El prompt anterior razonó que
«un tercero tendría que estar matando el evento para TODOS, y entonces da igual quién sea». El
corte **no es para todos**: es para los de más abajo en la fila. Por eso importaba quién.

### La lección, y es de instrumento — la más cara de las tres que lleva este arco

`Corpus._initPostEntitySeen` la escribe **el propio callback de la barrera**. Una bandera que sólo
puede ponerse en `true` desde adentro del callback mide **si el callback corrió**, jamás si el
evento ocurrió. El detalle la imprimía como **`initPostEntity=NO llegó`**: el **nombre** del
instrumento contrabandeó la conclusión, y una vez impreso, tres documentos y un header lo
repitieron como hecho medido. `mundoAlCargar` midió bien lo suyo (el hook estaba puesto a tiempo)
y no autorizaba el salto: «puesto a tiempo» + «no corrió» deja abierta la cadena cortada.
*Un instrumento se nombra por lo que TOCA, no por lo que uno querría concluir.*

- PARCHE 1 — `corpus_selftest.lua`: el rótulo pasa de `initPostEntity=llegó | NO llegó` a
  **`hookIPE=corrió | NO corrió`**, con el porqué escrito al lado. **No se acuña ni se retira un
  check** (§4 del encargo): el instrumento se queda, sólo deja de mentir con el nombre.
- PARCHE 2 — `corpus_ready.lua`, header y comentario de la bandera: el hallazgo del 2026-08-08 se
  marca **REFUTADO** y se reemplaza por el medido, con la tabla del log, el descarte de la ruta
  del menú, la cita a `hook.lua` y el testigo que sirve. Cero cambios de conducta: **no se toca
  una línea de la barrera** — el respaldo se queda y ahora se apoya en una propiedad
  **estructural** de `hook.Call`, no en una rareza de esta instalación.
- PARCHE 3 — `CORPUS_Architecture.md`, la deriva del §3.1 del encargo, en sus tres sitios:
  `:90` (tabla de primitivas), `:115` (firma comentada) y `:210` (`Initialize` … «antes de
  `InitPostEntity`», que enunciaba la garantía contra el evento equivocado — ahora se enuncia
  contra la barrera, que es lo que el boot diferido necesita y lo único que el framework
  controla). Más la nota nueva de §3 con el hecho y sus consecuencias.
- PARCHE 4 — dos sitios más con la misma deriva, fuera de los tres que el encargo enumeró:
  `CLAUDE.md` (mapa de archivos, fila de `corpus_ready.lua`) y `corpus_convenciones_commits.txt`
  (glosa del alcance `ready`). §7 del flujo: el código manda sobre el doc, en todos los docs.

### Lo que NO se pudo identificar, y lo que lo separa

**Quién corta la cadena: SIN IDENTIFICAR.** Barrido de `dev/other/`: de los **41**
`hook.Add("InitPostEntity", …)` que hay, **ninguno devuelve un valor** al nivel del handler.
**Descartado no es probado:** `dev/other/` no tiene los 380 addons suscritos.

Lo separa **una sola medición que hoy no existe**: si nuestro hook está en
`hook.GetTable()["InitPostEntity"]` en runtime del realm cliente, nadie nos desenganchó y el
corte es por retorno; si no está, un tercero nos borró por nombre. **No se escribió** — el arco
sigue siendo conocimiento y no funcionalidad, y el §4 del encargo pedía no acuñar checks por él.

**Y un testigo que hay que descartar antes de que alguien lo use:** **Better Movement NO sirve**,
aunque su `bm_init` CLIENT (`sh_bm_main.lua:226`) cuelgue del mismo evento. Sólo escribe NW2 vars
que el SERVER reescribe en cada `PlayerSpawn` (`:219-223`) y replica, así que en listen server su
ausencia **no produce ningún síntoma observable**. Un testigo cuyo fracaso es invisible no
atestigua — habría dado verde sin medir.

**Verificación.** `harness_cargo.py` **828 verdes** (el conteo no sube y está bien: no se acuñó
ningún check, se renombró el detalle de uno existente), `harness_coagulant.py` y
`harness_craving.py` en verde. El harness **sigue sin poder acreditar nada de este arco**: su stub
hace `hook.Run("InitPostEntity")` en los dos realms por construcción, así que ahí ninguna cadena
se corta. Lo que acredita este bloque es el `console.log` del autor y la fuente del engine.

---

## PARCHES DE sesión La categoría Corpus estaba vacía: el spawnmenu se arma antes del boot — 2026-08-17

Reportado por el autor al final de la sesión del fix de Sidorovich: menú Q → Utilities →
**la categoría "Corpus" aparece, pero no cuelga ninguna entrada** — ni Caliber, ni Cargo, ni
Coagulant, ni Craving. Sólo quedaban las convars para tocar nada. Cero errores de Lua.

**Dos hipótesis refutadas antes de la buena, y las dos por el `console.log`, no por argumento.**
(1) *La cadena de `Initialize` cortada por un tercero que devuelve un valor* —el defecto del arco
B— habría explicado los cuatro módulos ausentes de golpe y sin error. **Refutada:** el log tiene
las cuatro líneas `cargado (client)` en todas las cargas, así que los cuatro `Boot()` corrieron y
los cuatro `RegisterTab` se llamaron. (2) *Un `PopulateToolMenu` de un tercero reventando y
abortando la cadena*, que es la forma exacta del bug de Sidorovich de esta misma sesión.
**Refutada:** el único error cliente candidato (`Glide // config.lua:859`) sale de un `DoClick` —
el autor abriendo el menú de Glide a mano— y además cae antes de la última carga.

**La causa, medida en la fuente del gamemode y no asumida.** Sandbox cuelga la creación del
spawnmenu de **`OnGamemodeLoaded`** (`gamemodes/sandbox/gamemode/spawnmenu/spawnmenu.lua:236`), y
dentro de esa misma función corre `AddToolMenuCategories` (`:217`) y después `PopulateToolMenu`
(`:221`). Ese evento llega **antes** de que los módulos booteen en `Initialize`. De ahí la firma
del síntoma, que es lo que lo hacía raro: la **categoría** la agrega un hook nuestro que no
depende de nadie, así que aparece; las **entradas** salen de `Corpus.UI._tabs`, que en ese
instante todavía está vacía. Y el registro tardío tampoco alcanza: `ToolMenu:Init()` llama a
`LoadTools()`, que lee `spawnmenu.GetTools()` **una sola vez** al crear el panel
(`spawnmenu/toolmenu.lua:13`) — un `AddToolMenuOption` posterior entra a la tabla y no se dibuja
nunca.

**El comentario del propio archivo mentía, y por eso el defecto era invisible.** El header de
`corpus_ui.lua` afirmaba que el spawnmenu se construye *"después de InitPostEntity"*. No hay
ninguna medición detrás de esa frase, y mientras estuvo ahí, cualquiera que auditara la primitiva
4 leía el motivo por el cual el bug no podía existir. Es el mismo modo de falla que el arco B:
una creencia sobre el engine, escrita como si fuera un hecho verificado.

- PARCHE 1 — fix(ui): `lua/autorun/client/corpus_ui.lua` — el contrato de la primitiva pasa a ser
  **"registrá cuando quieras"**. Se agrega `Corpus.UI._poblado` (nuestro `PopulateToolMenu` ya
  corrió, o sea que el `ToolMenu` ya leyó la tabla) y, si un `RegisterTab` llega después, se
  agenda **un** `spawnmenu_reload` diferido a `timer.Simple(0)` — diferido a propósito, para que
  los cuatro módulos registrando en el mismo frame paguen un solo rebuild. No hay recursión: el
  rebuild vuelve a correr `PopulateToolMenu`, que sólo re-lee la tabla, y sin un registro NUEVO
  después de eso nadie agenda otro. El header se reescribe con las tres sedes medidas y la línea
  falsa se borra. **[PENDIENTE]**

**Lo que NO se hizo, y por qué.** No se tocó la deferencia a `Initialize` de los cuatro módulos.
Sería la otra mitad —registrar antes de que el menú se arme— pero son cuatro repos, y el arreglo
en la primitiva cubre además el caso que ninguna reordenación cubre: un módulo que registre su tab
en runtime, mucho después del boot. La primitiva tiene que aguantar eso igual.

**Deuda de instrumento, declarada.** El header de `corpus_selftest.lua` dice *"El tab de UI
(primitiva 4) se verifica visual"*. Éste es el único hueco de las cinco primitivas y es justo
donde vivió el bug: ningún check habría podido delatarlo, porque no hay ninguno. Peor, `lua_run_cl`
está gateado por `sv_allowcslua`, así que `Corpus.UI._tabs` **no es inspeccionable en juego** — el
diagnóstico se cerró leyendo el `console.log` y la fuente del engine, sin poder consultar el
estado del cliente ni una vez. Un `corpus_ui_dump` de realm CLIENT cerraría las dos cosas.

Verificación (PASO 4, del autor): cargar mapa y abrir Q → Utilities → Corpus **sin tocar nada**.
Criterio: las cuatro entradas presentes de una. El diagnóstico ya está confirmado a mano —el autor
corrió `spawnmenu_reload` y las entradas aparecieron—, pero eso acredita la CAUSA, no el parche:
lo que falta medir es que el rebuild automático dispare solo. Y si aparecen, mirar que **no
parpadee dos veces** ni queden dos categorías: sería la señal de que el debounce no agrupó.

---

## PARCHES DE sesión Fundación de corpus-cortex — barrido de ratificación — 2026-08-24

El autor abre el bloque de **escuadrones** de Cortex y funda ese repo (su tanda propia está en
`../../corpus-cortex/docs/CHANGELOG.md`). Esta entrada registra lo que la fundación **arrastró
del lado del framework**: el barrido de ratificación de §7.3, hecho **por el VALOR y no por la
lista de destinos** que traía el plan. Los valores barridos sobre las siete raíces fueron *«repo
semilla»*, *«sin `CLAUDE.md`»*, *«familia sin entradas»* y *«pendiente: true»*.

Sólo prosa y registro; ninguna línea de Lua del framework se tocó.

- PARCHE 1 — **`docs/ids.yaml` · la familia `CTX` pierde su reserva y acuña cinco entradas.**
  La clave `pendiente: true` sale (su sede ya existe) y el comentario que la explicaba se
  reescribe: describía la reserva **como si Cortex la tuviera hoy**, y ahora **ninguna familia la
  lleva** — la clave queda documentada para la próxima que se reserve. Nacen CTX-1 (Cortex es una
  CAPA sobre bases de NPC que ya existen, no una base), CTX-2 (las dos mitades con gates
  independientes), CTX-3 (el escuadrón vive en Cortex; el menú es su front-end), CTX-4 (Cortex no
  parchea la propiedad de inventario de Cargo) y CTX-5 (los alcances de commit). Tres nacen
  `INTENCION` **a propósito**: no hay una línea de Lua en ese repo, y acuñarlas con una evidencia
  que no existe sería lo deshonesto. **[APLICADO 2026-08-24]**
- PARCHE 2 — **`docs/ids.yaml` · el bloque `salud`, y un drift que la corrida destapó.** Decía
  `244/76 (31%)`. El checker, corrido **antes** de tocar nada en esta sesión, ya reportaba
  `257/71 (28%)`: **trece IDs se acuñaron sin refrescar este bloque**, que es exactamente lo que su
  propio comentario prohíbe — y van tres veces. Queda en la cifra real de hoy, `262/74 (28%)`, con
  el hallazgo anotado en sitio. ⚠ **El 28% no es mérito de esta tanda**: ya estaba ahí, y estas
  cinco altas apenas lo sostienen. **[APLICADO 2026-08-24]**
- PARCHE 3 — **`docs/corpus_roadmap.txt` · el punto [5] decía tres cosas que dejaron de ser
  ciertas** (*«sigue sin empezar»*, *«el repo es semilla (README + LICENSE, sin código)»*, *«su
  sede CTX todavía no existe»*). Y una cuarta que **nunca fue exacta y ésta es la que importaba**:
  enunciaba el gate de Caliber sobre **Cortex entero**. Los eventos daño/limb gatean el **afecto**;
  la táctica y el escuadrón no dependen de esa superficie. Leído sin partir, ese gate **bloqueaba
  trabajo que no estaba bloqueado** — es la razón por la que el bloque pudo abrir con el Block 3 de
  Caliber todavía en su tramo 0. La partición es CTX-2 y su sede es el CLAUDE.md de Cortex; acá se
  cita. **[APLICADO 2026-08-24]**
- PARCHE 4 — **`docs/corpus_estado.md`** — *«Cortex sigue sin código»* seguía siendo cierto, pero
  la foto omitía la fundación y repetía el gate sin partir. Refrescada en sitio. **[APLICADO
  2026-08-24]**
- PARCHE 5 — **`CLAUDE.md` §Git** — decía que cinco repos llevaban commits y que *«Cortex sigue con
  el repo semilla: README + LICENSE, sin código»*. Los siete llevan commits; Cortex es el único sin
  código. **[APLICADO 2026-08-24]**
- PARCHE 6 — **`docs/CORPUS_Architecture.md` §9, fila del Block 2** — *«Cortex: pendiente — sin
  código todavía (repo semilla)»*. Pasa a **EN DISEÑO**, con el alcance votado y la partición del
  gate. **[APLICADO 2026-08-24]**
- PARCHE 7 — **`docs/Corpus_Interaccion_Arquitectura.md` §5.4 y §8.bis.** §5.4 afirmaba que
  `corpus-cortex` *«no tiene `CLAUDE.md`»* y que por eso la primera norma de la escuadra exigía
  fundarlo. Las dos mitades se resolvieron, y **la adjudicación que esa sección enunciaba sin sede
  —«la escuadra vive en Cortex, el registro es su front-end»— ahora tiene una: CTX-3**, que el doc
  pasa a citar. ⚠ Ese documento **no acuña un solo ID** (cita 15, todos ajenos — CTX-3 incluida desde esta tanda), o sea que sigue siendo
  **NO-AUDITABLE por el gate de coherencia** en el sentido de §7.6 — deuda preexistente, no de esta
  tanda, y se declara acá porque el barrido la vio. Del punto 1 de «lo que hay que decidir antes de
  escribir `command`» se tacha *«fundar Cortex»*; **los otros tres siguen abiertos**, y el que más
  arrastra —cómo se nombra al ejecutor en el mensaje de net— **no se destrabó con esto**.
  **[APLICADO 2026-08-24]**
- PARCHE 8 — **`docs/ids.yaml` · la deuda D-13 NO se reescribe.** Su párrafo (c) dice que *«la
  familia sigue reservada sin entradas»* — era la foto del 2026-07-19 y **era cierta entonces**.
  Se le agrega una línea de actualización fechada en vez de corregir el registro histórico, misma
  disciplina con la que se trataron las semillas de Coagulant. **[APLICADO 2026-08-24]**

**Verificación.** `check-ids` corrió **antes** (`257/71`, limpio) y **después** (`262/74`, limpio,
155 archivos escaneados contra 151 — los cuatro docs nuevos de Cortex). Las citas cruzadas se
adjudicaron **abriendo el archivo citado** y no copiándolas entre docs (§7.3.b): la línea de
`OwnerKey` que CTX-4 mide se leyó en `corpus-cargo/lua/corpus_cargo/server/corpus_cargo_inventory.lua`,
y las carpetas de bases de NPC se listaron en `dev/other/`. **Ninguna afirmación sobre lo que VJ
Base o los `npc_*` de HL2 exponen entró a ningún doc**: esa lectura es el próximo paso del bloque
y se hace contra el árbol, no contra la memoria. Sin superficie de runtime en esta tanda. No
commiteado ni pusheado (GIT-7).

---

## PARCHES DE sesión Cortex acuña CTX-6 y CTX-7 tras el censo de bases — 2026-08-24

Segunda tanda del día del lado de Cortex (la suya está en `../../corpus-cortex/docs/CHANGELOG.md`).
Del lado del framework sólo arrastra el registro.

- PARCHE 1 — **`docs/ids.yaml` acuña CTX-6 y CTX-7.** CTX-6: el escuadrón de Cortex corre **en
  paralelo** al squad del engine —votado por el autor sobre el censo—, porque **son el mismo campo**
  y el del engine es un **bando** (46 de 60 defs de NPC de HL2 nacen en siete nombres globales de
  facción). CTX-7: la cola de órdenes **sondea**, porque el engine **no emite** ningún evento de
  «orden terminada» — 40 usos de `IsCurrentSchedule` contra cero callbacks. CTX-6 nace `INTENCION`;
  CTX-7 nace con evidencia `codigo` (el stool de guard de ZBase, que sondea para re-emitir la orden).
  **[APLICADO 2026-08-24]**
- PARCHE 2 — **`docs/ids.yaml` · bloque `salud` refrescado** con la corrida real. **[APLICADO
  2026-08-24]**

**Verificación:** `check-ids` corrido antes y después. Sin superficie de runtime; ningún doc del
framework cambió de contenido en esta tanda. No commiteado ni pusheado (GIT-7).

---

## PARCHES DE sesión Menú interactivo, tanda 1: el registro como DATO — 2026-08-24

Primera tanda de las cuatro del menú interactivo. Su objetivo es que **el árbol del menú EXISTA
como dato**: un registro de acciones que se puede poblar, resolver e inspeccionar — **sin dibujar
nada y sin ejecutar nada**. El diseño estaba cerrado y votado desde el 2026-08-24
([`Corpus_Interaccion_Arquitectura.md`](Corpus_Interaccion_Arquitectura.md), 11 secciones); lo que
esta tanda hace es **bajarlo**, y por eso no acuña una sola norma: no apareció ninguna regla dura
que el doc no tuviera ya. Lo que sí apareció son **tres huecos de diseño**, y los tres están abajo,
sin resolver, para el autor.

**Lo que NO entró, y está dicho porque la columna que no trabaja es la que se olvida:** ni dibujo
(wheel, chips, LOD, motion — es la tanda 3), ni acciones concretas (son de cada módulo por COR-1 y
COR-10 — tanda 4), ni el mensaje de net ni las tres puertas del server (tanda 2), ni la consulta de
proximidad. La rama `command` **no se pobló**: existe como el tercer valor de `tree` y su árbol
resuelve vacío, que es lo que prueba la forma sin comprometer nada.

- PARCHE 1 — feat(interact): `lua/autorun/corpus_interact.lua` — **la séptima primitiva**, shared,
  autosuficiente (COR-9). Superficie:
  - **`Corpus.Interact.Register(module, spec) -> spec | nil, motivo`.** Valida los diez campos de
    §3, normaliza (`module` estampado, `order` con default 100 como `RegisterCategory`) y devuelve
    el spec. Rechaza devolviendo `nil` —no con `error()`, y ahí se aparta de sus cinco hermanas a
    propósito: la firma del doc es `-> spec | nil`, y un módulo que registra treinta acciones no
    debe caerse entero por una mal formada— **y siempre lo dice por `Corpus.Log`**: una ausencia
    silenciosa se lee como «el menú no funciona». El segundo retorno es el **motivo exacto**, y
    existe para que un check pueda comparar *cuál* guarda contestó y no sólo *que* hubo rechazo.
  - **`Corpus.Interact.Resolve(tree)`** — el árbol se resuelve **al abrirlo, no al registrar**
    (§3.a): agrupa por `parent`, ordena hermanos por `order` con el `id` de desempate, lista y
    **loguea** los huérfanos, elige régimen por cuenta de hijos (§6.bis: 1-6 arco · 7-12 columna ·
    13+ subcategorías) y cuenta **hojas alcanzables** para el número ámbar. Devuelve **siempre** una
    tabla, también para una rama sin un solo nodo.
  - **`Corpus.Interact.Enabled(id)`** — la composición maestra × acción en **una sola función**
    (§7 regla 2). Las perillas (`corpus_interact_enabled` y `corpus_interact_<id>`) las crea **el
    registro** y no una lista, se entrega el **objeto** ConVar y no el nombre, y re-registrar reusa
    el objeto ya construido. Las seis reglas se heredan del roadmap #61 de Cargo, que resolvió este
    problema exacto para las categorías de ítem. **[APLICADO 2026-08-24]**

- PARCHE 2 — test(harness): [`../../dev/harness_corpus.py`](../../dev/harness_corpus.py) — **el
  primer instrumento offline cuyo sujeto es el framework**, sembrado desde `harness_craving.py`
  (720 líneas, el más chico) y no desde las 10.836 de Cargo. **378 checks** en tres pasadas
  (SERVER, CLIENT y una tercera con el **orden de carga invertido**, que es lo que ejerce COR-9 por
  primera vez) más un gate de fuentes. Su otra mitad es
  [`../../dev/sabotaje_corpus_interact.py`](../../dev/sabotaje_corpus_interact.py): **49 sabotajes,
  49 en rojo**. **[APLICADO 2026-08-24]**

  **La capa de stubs NO se factorizó, y es la cuarta copia a propósito** (§10 del doc): mover o
  renombrar rompe las anclas de los sabotajes **en silencio** —imprimen `ANCLA x0` y no revientan—
  y eso pasó cuatro veces en una sola tanda. Deuda con gatillo concreto: *el día que el mismo bug
  de stub aparezca en dos harnesses, se factoriza.*

  **Y estrena una cosa que las suites de sabotaje de este taller no tenían: cada sabotaje declara
  QUÉ FAMILIAS de checks tiene que teñir**, y el arnés falla en las dos direcciones — `EL CONTROL
  NO LLEGA` si una familia declarada no se pone roja, y `EL CONTROL SE PASA` si se pone roja una
  que ese defecto no toca. La segunda es la que se olvida, porque el rojo de más se lee como celo,
  y es la que audita al que escribió el sabotaje. **Se pagó sola en la primera corrida**: de los
  49, seis salieron mal y **cuatro de los seis eran defectos del instrumento, no del código**.

### Los seis hallazgos de la primera corrida del sabotaje, porque son el método

1. **Un sabotaje que no rompía lo que decía romper.** El del dedup de huérfanos reasignaba la
   **local** `huerfanos` después de que `resuelto.orphans` ya apuntaba a la tabla, así que no
   cambiaba nada y salía verde. *Un sabotaje inerte acredita al check por no tocarlo, y se lee
   exactamente igual que un check flojo.*
2. **Un check que no podía fallar: `List` devuelve `{}` y no `nil`.** El stub de `file.Find`
   devolvía `{}` para toda carpeta, así que el guard `if archivos == nil` de `Corpus.Data.List`
   era **inalcanzable**. Ahora el stub devuelve `nil` sobre una carpeta que no existe, como el
   engine, y el check muerde.
3. **Un check de idempotencia que no discriminaba.** «La segunda señal no vuelve a correr los
   callbacks» sale verde **con y sin** el early return de `Fire`, porque pasada la barrera la cola
   ya está vacía. Lo que separa las dos hipótesis es que la barrera vuelva a **hablar**: el check
   pasó a mirar la segunda línea `ready barrier:` en el log.
4. **Un alcance declarado que estaba mal, y el arnés tuvo razón.** Sacar `spec.module` sólo teñía
   `R`, no `T` como estaba declarado — porque **ningún check miraba a quién nombra la línea del
   huérfano**, que sin el campo imprime `[Corpus:nil]` y deja al operador sin a quién reclamar. El
   arreglo fue del check, no del alcance.
5. **Un stub que mataba la pasada en vez de medir.** `SetConVarValue` sobre una convar inexistente
   indexaba `nil` y tumbaba el realm entero, así que el rojo no se podía repartir por familia. Es
   tolerante y **ruidoso**: una perilla que no alcanza a su sujeto se lee como «el mecanismo no
   existe», que es la conclusión inversa.
6. **Un defecto cuyo rojo no se puede repartir, y que eso sea el dato.** Sin el `pcall` de la ready
   barrier, el callback roto **propaga y mata la pasada entera** — lo que en juego deja a los
   módulos de más abajo en la cola sin su wiring y sin un error atribuible a ellos. Queda declarado
   con alcance `*` en vez de fingir un reparto.

### Lo que este instrumento NO PUEDE VER, y va escrito antes de leer un verde

- **`FCVAR_REPLICATED` es invisible por comportamiento.** El stub de convars guarda nombre y valor
  y no mira los flags: sacarlo de las dos convars deja **las tres pasadas de realm en verde
  enteras**. Lo único que lo caza offline es el **gate de fuentes**, que es **presencial** —cuenta
  la expresión en el archivo, con denominador, para que borrar una de las dos no quede tapada por
  la otra— y que **no prueba que replique**. Eso sólo se ve en juego.
- **Tres defectos declarados como NO DETECTABLES** (el reuso del objeto ConVar al re-registrar, y
  los dos rangos `0, 1`) se corren igual en la suite **exigiendo VERDE**. Si alguno se pusiera
  rojo, el límite del instrumento habría cambiado y la nota que lo declara habría envejecido — que
  es como una acreditación se vuelve falsa sin que nadie toque el texto.
- **«Que los hooks devuelvan `nil` y no `true`» se queda SIN SUJETO**: esta tanda no agrega un solo
  hook. No se escribió un check vacío — un verde sin sujeto es la forma barata de acreditar lo que
  no se midió.

### Tres huecos de diseño, al autor (§7.5, conducta DETENTE)

1. ⚠ **Colisión del `id` `enabled` con la perilla maestra.** §7 fija los dos nombres
   (`corpus_interact_enabled` y `corpus_interact_<id>`) y **no los cruza**: son el mismo string
   cuando el id es `enabled`. Sin guard, esa acción se lleva el objeto de la maestra y apagarla
   apaga el menú entero — sin error, sin romper el registro, y visible sólo el día que un admin
   gira lo que cree que es una perilla de acción. **Se trató como el caso del id no tipeable** (sin
   perilla y dicho en voz alta), porque es la misma familia de defecto y §7 regla 4 ya le escribió
   la cura. Falta el voto sobre si eso alcanza o el `id` `enabled` debe rechazarse.
2. ⚠ **El tamaño de la tanda del reparto alfabético.** §6.bis.b manda repartir «alfabéticamente en
   tandas» y **no dice de cuántas**. Se derivó **12**: cada subcategoría del régimen 13+ «es una
   columna», y una columna aguanta 12. Cualquier otro número fabricaría un tercer umbral que el
   diseño no tiene — y el doc avisa que el 10 del cvar de filas **no** es un umbral. Es la única
   cifra del archivo que el doc no escribe con todas las letras.
3. ⚠ **Los ciclos de `parent`.** `parent` es un id y no una referencia, así que el registro **no
   puede** impedir que A cuelgue de B y B de A: los dos se registran legalmente. Sin corte, contar
   hojas es una recursión infinita que cuelga el juego. Se cortan con un set de visitados y el nodo
   queda como hoja; el doc no menciona el caso.

### Dos observaciones de menor peso

- **§11 del doc dice que el primer parche «acuña las normas `COR-nn`» y toca
  `CORPUS_Architecture.md` §3 («Seis primitivas»).** Ninguna de las dos entró: esta tanda no acuñó
  ninguna norma —no apareció ninguna regla dura que el doc no tuviera— y `CORPUS_Architecture.md`
  **no estaba en el alcance** de la tanda. Queda para el autor decidir cuándo.
- **Se corrigió el «122» del catálogo de controles en §10 del doc — y quedó en 129, no en 127.**
  El alcance de la tanda pedía llevarlo a 127, que era el número al escribirse el prompt; esta misma
  tanda le sumó **dos entradas** al catálogo (el sabotaje que no rompía lo que decía romper, y las
  tres formas de check-que-no-puede-fallar que salieron de la misma corrida), así que cerrar con 127
  habría dejado el doc falso a sabiendas. Se escribió 129 **y se le agregó que la cifra es una foto
  que envejece sola**: manda el archivo, no el número — es la tercera vez que ese número se corrige.
- **`corpus/CLAUDE.md` y `CORPUS_Architecture.md` §3 siguen diciendo SEIS primitivas.** Los dos
  quedaron fuera del alcance de la tanda y **no se tocaron**; el mapa archivo → rol del `CLAUDE.md`
  no tiene la fila de `corpus_interact.lua`. `check-ids` sigue limpio (es coherencia mecánica y esto
  no lo ve), pero el **gate LLM** de §7.8 lo levantaría como contradicción contra el árbol.
- **Los tres harnesses viejos no cargan la séptima primitiva.** Arman el frame con una lista
  explícita de cinco archivos, así que su andamio quedó desactualizado respecto de lo que el juego
  monta. No se tocaron (fuera de alcance) y `harness_corpus.py` sí la carga en las tres pasadas.

**Verificación:** `python dev/harness_corpus.py` → exit 0, **378 checks**, 0 fallos.
`python dev/sabotaje_corpus_interact.py` → **49/49 en rojo**, cada uno sólo en las familias que
declaró, y los 3 no-detectables verdes. Los tres harnesses hermanos siguen en exit 0 y el árbol
quedó restaurado byte a byte (`git status` limpio salvo el archivo nuevo). `check-ids` limpio.
**Sin pasada en juego**: esta tanda **no tiene superficie de runtime** —no dibuja, no manda net y
no ejecuta nada—, así que **no nace ningún check de planilla** (FLU-37). La planilla nace con la
tanda 3, con letra `AP`, y esa letra se da de alta en `ids.yaml` **antes** de usarse (FLU-30). No
commiteado ni pusheado (GIT-7).

⚠ **Los dos parches pasan a `[APLICADO]` con un criterio que NO es el de siempre, y por eso va
escrito:** la disciplina de este CHANGELOG dice que para código de addon GMod «verificado» es
**confirmado en juego**, y esta tanda **no tiene superficie en juego que confirmar**. El criterio
que las aplica es el que la tanda fijó de antemano y son **las dos cosas**: el harness en VERDE y su
sabotaje en ROJO. Si alguna de las dos no se cumpliera, vuelven a `[PENDIENTE]`.

---

## PARCHES DE sesión Menú interactivo: los tres votos que destrabó escribir el código — 2026-08-25

La tanda 1 dejó **tres huecos de diseño** y el autor los votó los tres el 2026-08-25, en los
tres casos por la recomendación. Esta entrada baja los votos a código, a doc y a instrumento.

**Lo que los tres tienen en común, y por eso van juntos:** *el diseño había resuelto el caso y
no la clase.* §7 fijaba dos nombres de convar y no los cruzaba; §6.bis mandaba repartir «en
tandas» sin decir de cuántas; §3.a definía al huérfano por su causa más obvia y dejaba afuera
la que nadie dibuja. **Ninguno de los tres se ve leyendo el documento**: el primero apareció al
escribir el `..` que concatena el prefijo, el segundo al imprimir los tamaños que salían, y el
tercero al preguntarle al árbol qué nodos alcanzaba de verdad.

- PARCHE 1 — feat(interact): **dos espacios de nombres separados para las perillas.**
  `corpus_interact_*` queda para la **config del subsistema** (la maestra hoy; el cvar de filas
  de §6.bis y el `corpus_interact_dump` de la tanda 2 mañana) y la perilla por acción pasa a
  **`corpus_interact_action_<id>`**, donde el `id` lo elige un módulo y el conjunto es abierto y
  ajeno. **No era un caso, era una clase con tres integrantes ya nombrables.**

  **Y el guard de colisión SE BORRÓ, que es la mitad que importa.** Con los dos espacios
  separados no puede dispararse nunca, y *un guard que no puede dispararse no es una red: es
  código muerto que además vuelve inejercitable al check que lo cubre* — el hallazgo nº 128 del
  catálogo, cometido y corregido en el mismo parche. Lo reemplaza un check sobre la **propiedad
  estructural** (que el prefijo de acción cuelgue del de config y sea estrictamente más largo, y
  que los tres nombres de config sean inalcanzables desde cualquier `id`), que **sí** puede
  fallar: acortar el prefijo lo pone rojo. **[APLICADO 2026-08-25]**

- PARCHE 2 — feat(interact): **el reparto alfabético es PAREJO con techo 12**, no un corte fijo.
  El 12 sigue siendo derivado (cada subcategoría del régimen 13+ «es una columna», y una columna
  aguanta 12). Lo que cambió es **cómo** se reparte, y la medición es la que decidió:

  | hijos | corte fijo | reparto parejo |
  |---|---|---|
  | 13 | `[12, 1]` | `[7, 6]` |
  | 25 | `[12, 12, 1]` | `[9, 8, 8]` |
  | 34 | `[12, 12, 10]` | `[12, 11, 11]` |
  | 37 | `[12, 12, 12, 1]` | `[10, 9, 9, 9]` |

  **La cantidad de tandas es idéntica en los dos** (`ceil(n/12)` siempre), así que el parejo **no
  cuesta un nivel más de navegación: cuesta cero**. Lo que compra es no fabricar una subcategoría
  de **un solo ítem** justo al cruzar el umbral — la ilegibilidad que el régimen 13+ existe para
  evitar. Se descartó atar la tanda al cvar de filas con motivo: §6.bis dice que *el 10 no es un
  umbral*, y así **mover una preferencia de visualización reorganizaría el árbol**.
  **[APLICADO 2026-08-25]**

- PARCHE 3 — feat(interact): **huérfano = todo lo que no se alcanza desde una raíz.** Una regla
  donde había dos y media, y cubre los cuatro casos: `parent` ausente, `parent` de otra rama,
  **ciclo**, y el auto-`parent` que `Register` ya rechazaba.

  ⚠ **Medido, el ciclo era peor de lo que la tanda 1 reportó.** Con A colgando de B, B de A y un
  nodo sano `colgado` debajo: los tres **existían** en la tabla de hijos, **ninguno** estaba entre
  las raíces, **ninguna raíz los alcanzaba**, y `orphans` decía **0**. Los tres desaparecían del
  menú **sin un solo aviso** — y uno de ellos era de un módulo que no tuvo nada que ver. Es
  literalmente el defecto que §3.a existe para impedir, entrando por la puerta de al lado.

  **La línea de log nombra su CAUSA**, porque son dos y piden arreglos distintos: «tu `parent` no
  existe» es un error del módulo que registró ese nodo; «tu `parent` tampoco se alcanza»
  normalmente **no** lo es. Un log que las junte manda a auditar el módulo sano.

  **Efecto de borde:** el árbol resuelto queda **acíclico por construcción**, así que el corte de
  ciclos de `ContarHojas` dejó de ser el mecanismo y quedó como red — y eso está escrito ahí,
  porque si fuera lo único, un ciclo no colgaría el juego pero seguiría borrando nodos en
  silencio. **[APLICADO 2026-08-25]**

- PARCHE 4 — docs(interact): las tres enmiendas bajan a
  [`Corpus_Interaccion_Arquitectura.md`](Corpus_Interaccion_Arquitectura.md) — §7 (los dos
  espacios), §6.bis (el techo 12 y el reparto parejo, con la tabla de medición), §3.a (la
  alcanzabilidad y las dos causas), más las tres filas nuevas en la tabla de votos de §11.
  **[APLICADO 2026-08-25]**

- PARCHE 5 — test(harness): `dev/harness_corpus.py` pasa de **378 a 440 checks**, y
  `dev/sabotaje_corpus_interact.py` de **49 a 50 sabotajes**, los 50 en rojo. **[APLICADO
  2026-08-25]**

### Lo que la actualización del instrumento destapó, y es el hallazgo de la tanda

**Dos de los tres votos no se podían distinguir con los checks que ya existían**, y eso salió
mirando qué sabotajes NO se ponían rojos:

1. **El reparto parejo y el corte fijo eran INDISTINGUIBLES.** Los checks de `G-fb` miraban el
   número de grupos, el total de ítems y que ninguna tanda pasara de 12 — y con 34 hijos las dos
   formas dan **3 grupos, 34 ítems y máximo 12**. Lo único que las separa son los **tamaños
   exactos**, y sobre todo el **mínimo**: el corte fijo fabrica una subcategoría de un ítem en 13,
   25 y 37. Se agregó `G-fb2`, que barre los cinco casos y exige el reparto completo.
2. **El check del ciclo no medía nada.** Era `pcall ok` + `count == 2`, y salía verde **con la
   conducta vieja y con la nueva** — un ciclo que no cuelga el juego pero borra nodos sin avisar
   pasaba igual. Reescrito con el escenario completo (raíz sana + ciclo + nodo inocente), mide los
   tres huérfanos, sus ids, que el log salga **una vez por cada uno** y que nombre **su** causa y
   no la otra.

**Y dos sabotajes viejos dejaron de poder fallar, lo cual es un resultado y no un problema.** El
del `parent` de otra rama y el del corte de ciclos de `ContarHojas` ahora salen verdes porque **la
alcanzabilidad los absorbió**: la línea que saboteaban dejó de ser la que decide. Es el nº 61 del
catálogo con el signo bueno —un arreglo del mismo bloque deja sin filo a una fila vieja— y se
**declara** en vez de taparse: pasaron a `NO_DETECTABLES` con la etiqueta `[movido]`, separada de
`[ciego]` (los que el stub no puede ver). Se conservan porque **el día que alguien saque la
alcanzabilidad, esas dos vuelven a ser lo único que queda**, se pondrán rojas, y habrá que leer la
nota.

**Un tercer defecto, y es del check.** El sabotaje de la perilla-desde-lista-fija **mataba la
pasada** porque `K5` indexaba `cvEnabled` sin protegerlo: un defecto que deja la acción sin perilla
tumbaba el realm y el rojo dejaba de poder repartirse por familia. *Un check tiene que sobrevivir
al defecto que mide para poder decir cuál es.*

**Verificación:** `python dev/harness_corpus.py` → exit 0, **440 checks**, 0 fallos, en las tres
pasadas. `python dev/sabotaje_corpus_interact.py` → **50/50 en rojo**, cada uno sólo en las
familias que declaró, y **5/5 no-detectables** verdes. Los tres harnesses hermanos siguen en exit
0 y el árbol quedó restaurado byte a byte. `check-ids` limpio. Sigue **sin superficie en juego**,
así que sigue sin nacer ningún check de planilla (FLU-37). No commiteado ni pusheado (GIT-7).

---

## PARCHES DE sesión El selftest audita Interact — la mitad de motor, sin gastar planilla — 2026-08-25

Voto del autor tras preguntar si correspondía abrir planilla ahora que hay código. **No
corresponde todavía, y el motivo son cuatro hechos y no una impresión:**

1. **Ningún módulo registra acciones** — COR-1 dice que son de cada módulo y la tanda 4 es la que
   las cablea. El árbol en juego está vacío *por diseño*, así que una planilla sobre él mediría el
   harness y no el juego. **El precedente es de esta semana y está en `ids.yaml`:** Cargo dejó la
   pasada en juego de su #60 diferida *«hasta que exista el área hospital, por ser su único
   consumidor»*.
2. **La única fila que valdría de verdad no es corrible en listen server.** Lo que el harness no
   puede ver es que `FCVAR_REPLICATED` **replique**, y en un listen server el cliente y el server
   son el mismo proceso: una convar replicada y una normal se leen igual. Pide dedicado o un
   segundo cliente.
3. **El estado no es inspeccionable en juego** (`lua_run_cl` gateado por `sv_allowcslua`), la misma
   deuda que `Corpus.UI._tabs`. Sin el `corpus_interact_dump` de la tanda 2 no se pueden contar
   nodos ni ver un huérfano.
4. **`AP` está libre y no se recicla** (FLU-07). Gastarla en las dos filas triviales que hoy son
   corribles es caro para lo que compra.

**Lo que sí se hizo, que es el paso 2 de §10 del doc y no gasta letra.**

- PARCHE 1 — feat(interact): `lua/autorun/corpus_selftest.lua` gana su **bloque 6, Interact** —
  once checks en los dos realms. Cubre la fila de guardas rechazando **con motivo**, el árbol
  contado contra un esperado (4 nodos · 1 raíz · 2 hijos · 1 huérfano), el orden de hermanos, el
  régimen de arco, la rama `command` naciendo vacía **con un número**, y las perillas.

  **Lo que este bloque acredita y el harness no puede:** que las convars **existan en la consola
  de verdad** y que **las cree el registro**. Las cuatro `corpus_interact_action_selftest_*` que
  aparecen al correrlo no están escritas en ninguna lista — son la huella de §7 regla 1 en el
  motor, no en un stub.

  ⚠⚠ **CORRE SOBRE UN PADRÓN PRESTADO Y RESTAURA EL REAL.** El bloque necesita un árbol limpio;
  sin devolverlo, tipear `corpus_selftest` con módulos ya cargados **les borraría sus acciones** —
  un test que destruye lo que audita, sin un solo error y con todas sus filas en OK. Se guarda por
  referencia y se restaura pase lo que pase, incluso si el bloque revienta (va en `pcall`).
  **[APLICADO 2026-08-25]**

- PARCHE 2 — feat(interact): **`Corpus._SelfTest()` devuelve su veredicto** (`true` = sin fallas).
  Hasta hoy no devolvía nada, así que un instrumento sólo podía preguntarle al `pcall`
  *«¿corrió?»* y jamás *«¿salió bien?»*. **Es el nº 60 del catálogo de controles, y ya costó una
  vez:** en `harness_cargo.py` el veredicto caía en el segundo valor del `pcall` y **179 checks
  podían estar en rojo mientras el arnés imprimía `ALL GREEN`**. Los tres módulos hermanos ya
  devuelven el suyo; el framework era el desviado de los cuatro. **[APLICADO 2026-08-25]**

- PARCHE 3 — docs: `CLAUDE.md` — el mapa de archivos gana la fila de `corpus_interact.lua` y la
  línea de conteo pasa a **7 primitivas**; la sección de Verificación nombra los dos instrumentos
  offline. ⚠ **`CORPUS_Architecture.md` §3 sigue diciendo «Seis primitivas» a propósito**: ahí no
  es un índice sino una tesis de diseño con su propio párrafo, y el argumento de por qué la séptima
  pasa el filtro de COR-10 vive en §2 del doc de interacción sin bajar todavía. Queda **declarado
  en el propio `CLAUDE.md`** y es decisión del autor. **[APLICADO 2026-08-25]**

- PARCHE 4 — docs: `corpus_convenciones_commits.txt` — se acuña el alcance de commit
  **`interact`**. La sección 3 lleva uno por primitiva y la séptima no tenía el suyo; no se puede
  commitear con un alcance que no existe. **[APLICADO 2026-08-25]**

- PARCHE 5 — test(harness): bloque **P7** en `dev/harness_corpus.py` — el harness pasa de 440 a
  **456 checks** y el sabotaje de 50 a **53**. **[APLICADO 2026-08-25]**

### Lo que la corrida del sabotaje volvió a destapar, y es el mismo método

**Ocho sabotajes pasaron a «EL CONTROL SE PASA», y el arnés tenía razón.** Al meter Interact dentro
del selftest, el selftest **pasó a auditar Interact**, así que un defecto de Interact ahora tiñe
también la familia `P` — y mi alcance declarado envejeció **en el mismo acto de escribir el
bloque**. El arreglo fue del alcance, no del instrumento; y los ocho que se pasaron son
**exactamente** los que el bloque 6 cubre, o sea que la corrección es además la **confirmación
cruzada** de que ese bloque mide lo que dice medir.

**Los tres sabotajes nuevos que no pueden faltar:**

- **El veredicto que desaparece** — reinyecta el nº 60. Sin retorno, el selftest puede estar en
  rojo entero y nadie enterarse.
- **El padrón que no se restaura** — el defecto que **no se ve nunca en una pasada verde**: todas
  las filas del selftest salen OK mientras borra las acciones de los módulos.
- **El bloque de Interact que desaparece del selftest** — la huella que lo delata es la convar de
  prueba que deja de existir.

**Y un defecto de higiene, mío:** `CLAUDE.md` quedó con **una línea en LF dentro de un archivo
CRLF** porque un reemplazo insertó `\n` crudo. Git lo normaliza al commitear y el diff salía
limpio, así que **no se veía por ahí**: lo cazó auditar los once archivos tocados con un contador.
Es el nº 98 del catálogo, en su versión barata.

**Verificación:** `python dev/harness_corpus.py` → exit 0, **456 checks**, 0 fallos.
`python dev/sabotaje_corpus_interact.py` → **53/53 en rojo** con alcance correcto, **5/5**
no-detectables verdes. El selftest corrido en los dos realms devuelve `true` y sus 11 filas de
Interact salen OK. `check-ids` limpio; los tres harnesses hermanos en exit 0.

---

## PARCHES DE sesión El voto del EJECUTOR — la tanda 2 queda destrabada — 2026-08-25

**Era la decisión que más arrastraba de todo el bloque**, y la única de las cuatro de §8.bis que
frenaba a las **otras dos ramas** y no sólo a `command`: el mensaje de net se define en la tanda 2,
y ahí hay que saber si lleva un campo más — agregarlo después es lo caro, que es el mismo argumento
por el que `component` se reservó el día uno.

**Votado por el autor: `B + C`.** El ejecutor **no viaja en el mensaje del menú** —es **estado del
server**, y llega por el net propio de Cortex cuando el jugador cambia su selección— y el commit se
lleva igualmente un cuarto campo **`subject`, opaco**, que el framework transporta y no interpreta.

- PARCHE 1 — docs(interact): §8.bis estrena la sección del voto. **B es correcto por naturaleza y
  no por costo**: §8.bis ya decía con estrella que la columna WHO *«no es un menú: es ESTADO, y no
  se cierra al elegir»*, el estado **hace falta igual** (la columna WHO y la cola de Delay se
  dibujan fuera del menú), y meterlo además en el mensaje es duplicar un hecho — lo que §7.0 del
  flujo dice que **deriva siempre**.

  **Su costo queda escrito y no disimulado:** son dos mensajes, así que hay carrera si el jugador
  selecciona y ordena en el mismo frame. Se paga aceptando que **manda el server**, que es
  exactamente lo que las tres puertas de §4 ya establecen.

  **Y C igual, siendo B suficiente hoy:** `subject` es el gemelo de `component` y hereda su
  precedente escrito. Compra la salida el día que aparezca una orden cuyo sujeto **no** sea la
  selección vigente, y no toca COR-1 — transportar un opaco no es conocer su semántica.

  **Descartadas con motivo:** **A** (un `actor` con semántica de escuadra, en sus tres formas) le
  daba al framework un campo cuyo significado es **IA de escuadra**, justo lo que el voto de §2 se
  comprometió a no hacer y con criterio de reapertura escrito. **D** (el ejecutor dentro del `id`)
  da 7 órdenes × 5 destinatarios = **35 ids**, y §7 crea una convar por acción: 35 perillas de
  admin. **[APLICADO 2026-08-25]**

- PARCHE 2 — docs(interact): el voto se propaga a donde el protocolo está escrito, que es la mitad
  que se olvida. **§4**: el commit pasa a `(id, entidad, component, subject)` y la nota de los
  campos reservados los explica **juntos y por el mismo motivo**, con el aviso de que el ejecutor
  **no viaja ahí**. **§5.4 punto 1**: queda tachado —decía que el mensaje *«no tiene dónde poner el
  primero»*— con su resolución al lado. **§11**: fila nueva en la tabla de votos, y la tabla de la
  enmienda de la tercera rama pasa de «4 decisiones sin votar» a **2**. **[APLICADO 2026-08-25]**

- PARCHE 3 — docs(interact): ⚠ **se escribe lo que hay que decir pase lo que pase, porque leído de
  afuera parece un bug.** En el «segundo caso» de §8.bis —apuntar a un miembro y darle una orden
  individual— **el NPC ya viaja en el campo `ent` que existe**, así que `ent` significa **DESTINO**
  en una orden de escuadra y **SUJETO** en una individual. No es ambiguo para el server (el `id` de
  la acción sabe cuál de los dos es), pero sin decirlo se lee como una colisión de campos y el que
  lo lea va a proponer separarlos. **[APLICADO 2026-08-25]**

### Lo que este voto destraba, y lo que NO

**Destraba la tanda 2 entera** — el commit, las tres puertas del server y el `corpus_interact_dump`
de realm CLIENT. Nada de eso dependía de `command`: dependía de saber la **forma del mensaje**.

**No destraba `command`**, y el motivo no cambió: el escuadrón todavía no está diseñado, y ése es
el bloque que Cortex abrió el 2026-08-24. De las cuatro decisiones de §8.bis quedan **dos** —qué es
una «puerta» para el sistema, y si las formaciones son de la orden o del escuadrón— y las dos son
**enteramente de `command`**: no frenan ni el dibujado de la tanda 3 ni las acciones de la tanda 4.

**Sin código en esta entrada.** El registro pelado no manda mensajes, así que el voto no toca una
sola línea de `corpus_interact.lua` — se cobra cuando la tanda 2 escriba el net. `check-ids`
limpio; harness y sabotaje sin cambios (456 checks, 53/53).
