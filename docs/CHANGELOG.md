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
