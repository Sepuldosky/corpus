# Acta — Gate de coherencia documental · PILOTO v3

- **Fecha de la corrida:** 2026-07-16 (tercera pasada del piloto, `v3`)
- **Modo:** PILOTO — solo el framework (`corpus/`). Ver §7.
- **Corpus auditado (5 docs):** `corpus/CLAUDE.md`, `corpus/docs/CORPUS_Architecture.md`, `corpus/docs/corpus_flujo_trabajo.txt`, `corpus/docs/corpus_roadmap.txt`, `corpus/docs/corpus_convenciones_commits.txt`
- **Estado del acta:** **COMPLETA** — la cobertura fue completa; ningún agente murió, ningún tramo quedó sin auditar. (Contrasta con la corrida del 2026-07-16 base, que salió DEGRADADA por el bloqueo de dos agentes de cruce.)
- **Método:** seis fases (Glosario → Lectura → Cruce → Adjudicación → Completitud → Síntesis); cada candidata pasó por tres verificadores adversariales (refutador, árbitro-código, árbitro-historia) y sobrevive solo por mayoría ≥2/3 (`corpus/docs/corpus_flujo_trabajo.txt:516-522`).
- **Read-only:** este acta es el **único** archivo escrito. Ningún doc, CHANGELOG, `ids.yaml` ni Lua fue tocado. Todos los parches acá son **PROPUESTOS, NO APLICADOS**. El gate propone, el autor dispone (`corpus_flujo_trabajo.txt:523-526`).
- **Inmutable:** foto del estado **al momento de auditar**, no de hoy. No se edita; si algo cambió, lo dice el acta siguiente (`corpus_flujo_trabajo.txt:557-559`).

**Resultado numérico:** 4 contradicciones confirmadas · 0 divergencias yaml-vs-sede · 86 normativas sin ID (FLU-25) · 56 afirmaciones sin alcance declarado · 0 cobertura perdida.

---

## 1. Resumen ejecutivo — lo que cambia el plan

Ordenado por daño a la ejecución, no por gravedad nominal.

### 1.1 Si construís siguiendo `CORPUS_Architecture.md:259`, escribís un crash

**Este es el único hallazgo con consecuencia de runtime.** `CORPUS_Architecture.md:259` enuncia como **regla derivada** que `Corpus.GetModule("cargo").Items.Register(...)` es «simultáneamente el check y la llamada». No lo es. `corpus/lua/autorun/corpus_registry.lua:36-37` es un lookup pelado (`return Corpus._modules[name]`): sin Cargo montado devuelve `nil`, y encadenar sobre él produce *attempt to index a nil value* — un error de Lua en lugar de la degradación honesta que exige COR-11 y que la propia §6 prescribe doce líneas antes (`:239`). Un ejecutor que copie el snippet del doc general rompe el contrato de soft-dep del ecosistema. **Los cuatro call sites reales del árbol hacen lo contrario del doc.** Bucket A, parche en §2.2.

### 1.2 Si seguís el §0 del roadmap, escribís el diseño del Block en el archivo equivocado

`corpus_roadmap.txt:14-16` manda que «el detalle de diseño de cada bloque vive en CORPUS_Architecture.md (una sección nueva por bloque)». FLU-18 (`corpus_flujo_trabajo.txt:185-196`) y `CORPUS_Architecture.md:5` / `:328` exigen exactamente lo contrario: doc particular en el repo dueño, resumen + link en el general, contenido nunca duplicado. Es un **eco sobreviviente**: el §3 del propio roadmap (`:85-92`) documenta la reparación de esta misma regla el 2026-07-16, y dejó el §0 sin barrer — fallo de FLU-28 regla (a) (barrer por el valor, no por la lista). **Reincidente**: ya fue hallazgo #6 del piloto base (`2026-07-16_coherencia_docs_PILOTO.md:251-258`) y §1.3/§2.2 del v2 (`2026-07-16b_coherencia_docs_PILOTO_v2.md:76-82`). Bucket A, parche en §2.3.

### 1.3 Dos docs del corpus auditado tienen CERO IDs: sobre ellos este gate es CIEGO

`corpus/docs/corpus_convenciones_commits.txt` y `corpus/docs/corpus_roadmap.txt` no llevan **ni una** etiqueta de ID en su prosa. Peor en el primero: `ids.yaml:40` declara la familia **GIT con sede ahí** y registra GIT-1..7 — **siete normas cuyo texto canónico no se puede anclar a ninguna línea**. Un «limpio» sobre estos dos docs no significa sano: significa **no auditado**. La única contradicción que se les encontró (§1.2) salió de leer prosa a ojo, no del cruce de IDs. Detalle completo en §5.

### 1.4 COR-6 tiene DOS defectos de alcance en la misma cláusula, y solo uno estaba votado

`corpus/CLAUDE.md:64` enuncia COR-6 sobre «los siete addons», pero el framework **no** lleva segmento `<addon>` (`corpus_registry.lua`, no `corpus_corpus_registry.lua`) y el árbol **depende** de que no lo lleve: `corpus-cargo/lua/autorun/corpus_cargo_init.lua:5-6` difiere su boot razonando sobre el orden alfabético contra `"corpus_registry.lua"`. El CHANGELOG (`:451-458`) ya tiene abierto un voto por la **otra** pata podrida de la misma cláusula («en `lua/autorun/...`» cuando 70 de 74 archivos Lua de los módulos viven fuera). **No son dos parches: es una sola reformulación que debe cerrar ambos ejes a la vez.** §2.4.

---

## 2. Contradicciones por gravedad

Ninguna llegó a BLOQUEANTE. Triage según `corpus_flujo_trabajo.txt` §7.1 corolario:
**A** REPARABLE (lo dirime el Lua/estado/CHANGELOG → se parcha) · **B** VOTO DEL AUTOR (los docs chocan y el código no dirime) · **C** BUG DE CÓDIGO · **CADUCO**.

| # | Gravedad | Tema | Bucket | Votos | Gana |
|---|---|---|---|---|---|
| 2.2 | MEDIA | soft-deps | **A** | 2/3 | B (`:239`) |
| 2.3 | MEDIA | proceso | **A** | 3/3 | B (`Architecture:328`) |
| 2.4 | BAJA | namespacing | **A** | 2/3 | B (mapa de archivos) |
| 2.1 | BAJA | framework-delgado | **A** | 2/3 | B (COR-10) |

---

### 2.2 — MEDIA · `soft-deps` · **BUCKET A (REPARABLE)** · 2/3

**Afirmación A** — `corpus/docs/CORPUS_Architecture.md:259`:
> «**Regla derivada:** el registro de Corpus (§3) es a la vez el mecanismo de detección de presencia y la ruta de acceso al módulo — `Corpus.GetModule("cargo").Items.Register(...)` es simultáneamente el check y la llamada.»

**Afirmación B** — `corpus/docs/CORPUS_Architecture.md:239`:
> El lazy check es el mecanismo **preferido**: se consulta con `Corpus.GetModule` en el momento del uso y se ramifica (`if caliber then ... else <degradar> end`).

**Alcance verificado en los cuatro ejes** — ambas viven en §6 «Uso — soft-dep (otro módulo)», a doce líneas de distancia: mismo REALM (shared), mismo MÓDULO (cualquier consumidor), misma rama SOFT-DEP (peer), mismo BLOCK (1). No hay split soft-dep, ni mock-first, ni distinto nivel de detalle. `:259` dice que encadenar **ya es** el check; `:239` dice que el check es una rama explícita. No pueden ser ambas verdaderas.

**Quién gana según la jerarquía:** **B**, y lo decide la **autoridad 1** (el Lua), no la historia.

**Evidencia:**

1. `corpus/lua/autorun/corpus_registry.lua:36-37` — lookup pelado, sin proxy ni sentinel:
   ```lua
   function Corpus.GetModule(name)
       return Corpus._modules[name]
   ```
   Por tanto `Corpus.GetModule("cargo").Items.Register(...)` es *attempt to index a nil value* cuando Cargo no está montado.
2. Todos los call sites de producción implementan B — `corpus-coagulant/lua/corpus_coagulant/shared/corpus_coagulant_items.lua:33-37` (`local cargo = Corpus.GetModule("cargo")` + `if cargo == nil then Corpus.Log("coagulant", "Cargo no presente: ítems médicos apagados (degradación honesta)") return end`); idéntico en `corpus-craving/lua/corpus_craving/shared/corpus_craving_items.lua:24-28`; también `corpus-craving/lua/corpus_craving/server/corpus_craving_coagulant.lua:20` y `corpus-coagulant/lua/corpus_coagulant/server/corpus_coagulant_treatment.lua:96`.
3. El **único** encadenamiento del árbol lleva guarda previa — `corpus-coagulant/lua/corpus_coagulant/shared/corpus_coagulant_dev.lua:215`: `local cargoInv = Corpus.HasModule("cargo") and Corpus.GetModule("cargo").Inventory or nil`.
4. El propio ejemplo de §5 (`CORPUS_Architecture.md:151`) hace `if cargo == nil then Corpus.Log(...) return end`.
5. **Cero encadenamientos sin guarda en todo el ecosistema.**
6. **Matiz que acota el parche:** la REGLA de `:259` es correcta y el framework la repite — `corpus/lua/autorun/corpus_registry.lua:2-4`: *«linchpin de las soft-deps — es a la vez el mecanismo de detección de presencia y la ruta de acceso al módulo (§6)»*. El código canoniza el **enunciado** pero nunca el **ejemplo**. Lo defectuoso es el snippet, no el encabezado.

**Historia:** ninguna entrada `[APLICADO]` eligió entre `:239` y `:259`. PARCHE 3 (`CHANGELOG.md:245-250`, [APLICADO 2026-07-16]) acuñó COR-10/COR-11 «por barrido de las normas que **ya existían en prosa**», sin tocar §6. `corpus_estado.md` no menciona `GetModule`. El eje `soft-deps` dio **cero hallazgos** en el piloto base y el acta lo declaró sospechoso (`2026-07-16_coherencia_docs_PILOTO.md:694-697`: *«Sospecho supresión, no ausencia»*). Nunca hubo pasada que lo resolviera.

**Voto disidente (refutador, 1/3):** sostuvo que `:259` es un resumen de la propiedad del registro (no prescripción de call site) y que el encadenamiento de `CORPUS_Architecture.md:165` es el caso seguro de un módulo accediendo a sí mismo. Se rechaza: `:259` nombra explícitamente `"cargo"` (un peer, no sí mismo) y lo califica de «simultáneamente el check y la llamada» — eso es prescriptivo y es falso contra `corpus_registry.lua:36-37`.

#### Parche PROPUESTO (NO aplicado) — `corpus/docs/CORPUS_Architecture.md:259`

Conserva la regla (ratificada por `corpus_registry.lua:2-4`) y sustituye solo el ejemplo.

**TEXTO ACTUAL:**
> **Regla derivada:** el registro de Corpus (§3) es a la vez el mecanismo de detección de presencia y la ruta de acceso al módulo — `Corpus.GetModule("cargo").Items.Register(...)` es simultáneamente el check y la llamada.

**TEXTO PROPUESTO:**
> **Regla derivada (COR-11):** el registro de Corpus (§3) cumple los dos roles a la vez — es el mecanismo de detección de presencia y la ruta de acceso al módulo: una sola llamada a `Corpus.GetModule` entrega el veredicto y la interfaz. Pero el acceso **nunca** se encadena sobre el resultado: `GetModule` devuelve `nil` cuando el módulo no está registrado (`lua/autorun/corpus_registry.lua`), así que indexar sin nil-check produce un error de Lua en vez de la degradación honesta que exige COR-11. La forma canónica es captura local + rama:
>
> ```lua
> local cargo = Corpus.GetModule("cargo")
> if cargo then
>     cargo.Items.Register(...)
> else
>     -- degradar: sin Cargo, los ítems no se registran
> end
> ```
>
> Cuando solo se necesita una sub-tabla y `nil` es un valor de trabajo aceptable, la forma corta equivalente ya en producción (`corpus-coagulant/lua/corpus_coagulant/shared/corpus_coagulant_dev.lua:215`) es:
>
> ```lua
> local cargoInv = Corpus.HasModule("cargo") and Corpus.GetModule("cargo").Inventory or nil
> ```
>
> — acá el encadenamiento es legal porque `HasModule` lo precede.

**Nota para el autor:** el parche deja `:259` consistente con `:239`, con el ejemplo de §5 (`:151`) y con los cuatro call sites reales. Considerar además un puntero cruzado de `:259` → `:239` para que la regla derivada se lea como el **fundamento** del lazy check, no como un mecanismo alternativo. Doc-only, sin superficie de runtime.

---

### 2.3 — MEDIA · `proceso` · **BUCKET A (REPARABLE)** · 3/3 (unánime)

**Afirmación A** — `corpus/docs/corpus_roadmap.txt:14-16`:
> «Regla anti-deriva: el detalle de diseño de cada bloque vive en CORPUS_Architecture.md (una sección nueva por bloque, ver §9); acá NO se duplica ese detalle — solo el orden y el criterio de entrada de cada tramo.»

**Afirmación B** — `corpus/docs/CORPUS_Architecture.md:328`:
> «Los bloques de módulo, en la práctica, **no** se agregaron como secciones de este archivo: cada módulo desprendió su **doc particular** autocontenido en su propio repo (el patrón que formaliza `corpus_flujo_trabajo.txt` §2). Acá queda el resumen y el link.»

**Alcance:** no hay eje de realm, módulo, soft-dep ni slice que los separe. El sujeto son los Blocks 1-4, todos cerrados salvo Cortex. Un ejecutor que siga el roadmap §0 escribe la sección de diseño del Block en `CORPUS_Architecture.md`; FLU-18 exige lo contrario.

**Quién gana:** **B**, por autoridad 1 (árbol real) y por concordancia con la sede de FLU-18 (nivel de proceso). El roadmap es **nivel 6** (intención, sin autoridad sobre lo que existe).

**Evidencia:**

1. `corpus/docs/CORPUS_Architecture.md` tiene exactamente 9 secciones (`:25, :45, :80, :126, :144, :182, :269, :279, :324` — Visión, Grafo, Superficie, Fronteras, Contrato de ítems, Orden de carga, Migración ADS→Caliber, Workspace, Estado). **CERO secciones de bloque de módulo**, pese a que los Blocks 2/3/4 cerraron. En §9 solo hay la tabla resumen + link (`:330-334`).
2. Los docs particulares existen en los repos dueños: `corpus-caliber/docs/Caliber_Architecture.md` (+ `Caliber_EnergyShields_Arquitectura.md`), `corpus-coagulant/docs/Coagulant_Architecture.md`, `corpus-craving/docs/Craving_Architecture.md`, `corpus-cargo/docs/Cargo_Architecture.md` (+ `Cargo_ItemImages_`, `Cargo_Trade_`, `Workbench_Arquitectura.md`). `corpus-cortex/docs/` vacío (repo semilla, Block pendiente — no contradice).
3. Sede canónica: `corpus/docs/corpus_flujo_trabajo.txt:176-177` («la sección va al `<modulo>_Architecture.md` general del REPO AFECTADO») y `:185-196` («la sección del doc general queda como resumen corto + link al particular; el contenido nunca se duplica entre ambos»).
4. `CORPUS_Architecture.md:5` lo declara consumado: «El diseño interno de cada módulo **no** vive acá… Este documento conserva el resumen y el link (§9)».
5. **Auto-desmentido del perdedor:** `corpus_roadmap.txt:85-92` documenta la reparación 2026-07-16 — *«Este tramo ordenaba "nueva sección autocontenida en CORPUS_Architecture.md" cuando §2 prohíbe exactamente eso … así que el roadmap era el que estaba mal: es nivel 6, intención, sin autoridad sobre lo que existe»*. El literal «Este tramo ordenaba…» acota la reparación al §3 y **deja vivo el §0**.
6. **Lectura benigna descartada:** el roadmap nombra el archivo del framework por ruta exacta y consistente (`:98` «docs/CORPUS_Architecture.md → §9», `:67` «La tabla §9 de CORPUS_Architecture.md») y ya remite a `Coagulant_Architecture.md` / `Craving_Architecture.md` como sede del detalle en `:51` y `:57` — se autorrefuta.

**Reincidencia:** hallazgo #6 del piloto base (`corpus/docs/auditorias/2026-07-16_coherencia_docs_PILOTO.md:251-258`, TRIAGE A, 3/3) y §1.3 / §2.2 del v2 (`2026-07-16b_coherencia_docs_PILOTO_v2.md:76-82`, `:213-302`). **Tercera vez que se levanta. Pendiente del autor.**

#### Parche PROPUESTO (NO aplicado) — `corpus/docs/corpus_roadmap.txt` §0, líneas 13-16

**ANTES:**
```
Este doc ORDENA lo que sigue; corpus_estado.md dice en qué punto estamos. Ambos se
leen juntos al planear el próximo bloque. Regla anti-deriva: el detalle de diseño de
cada bloque vive en CORPUS_Architecture.md (una sección nueva por bloque, ver §9);
acá NO se duplica ese detalle — solo el orden y el criterio de entrada de cada tramo.
```

**DESPUÉS:**
```
Este doc ORDENA lo que sigue; corpus_estado.md dice en qué punto estamos. Ambos se
leen juntos al planear el próximo bloque. Regla anti-deriva (FLU-18): el detalle de
diseño de cada bloque NO se duplica acá — vive en el doc de arquitectura del REPO
DUEÑO (<Modulo>_Architecture.md, o el doc particular que el Block desprenda; ver
corpus_flujo_trabajo.txt §2, que es su sede). CORPUS_Architecture.md §9 solo lleva el
resumen + link de cada Block de módulo. Acá: solo el orden y el criterio de entrada
de cada tramo.
```

**Notas para el autor:** (1) el Block 1 (framework) **sí** es sección de `CORPUS_Architecture.md` porque su repo dueño ES `corpus` — la redacción propuesta lo cubre sin excepción explícita. (2) Este parche es el **gemelo** del que ya reparó el §3 el 2026-07-16: aplicarlo cierra el barrido que quedó a medias, es la MISMA reparación, no una nueva. (3) NO se tocan `corpus_flujo_trabajo.txt:185-196` (ya dice lo correcto) ni `CORPUS_Architecture.md` (es el ganador).

---

### 2.4 — BAJA · `namespacing` · **BUCKET A (REPARABLE)** · 2/3

> **Este hallazgo debe ir al MISMO voto que ya está abierto en `CHANGELOG.md:451-458`. Es la misma cláusula, otro eje.**

**Afirmación A** — `corpus/CLAUDE.md:64` (COR-6):
> «Prefijo de archivo por addon: `corpus_<addon>_*.lua` en `lua/autorun/...`, para evitar colisión de nombres cuando los **siete** addons (framework + cinco módulos + `corpus-stalker`) están montados simultáneamente.»

**Afirmación B** — `corpus/CLAUDE.md:47` (mapa de archivos del mismo CLAUDE.md):
> `lua/autorun/corpus_net.lua`, `corpus_registry.lua`, `corpus_data.lua`, `corpus_ready.lua`, `corpus_log.lua`, `corpus_selftest.lua`, `client/corpus_ui.lua` — **sin segmento `<addon>`**.

**Alcance:** mismo realm (`lua/autorun/`, shared), mismo módulo (el framework está incluido explícitamente en «los siete addons»), sin soft-dep, transversal a todo Block. Aplicado literalmente, COR-6 obliga a `corpus_corpus_registry.lua`.

**Quién gana:** **B**, por autoridad 1.

**Evidencia:**

1. **Framework, prefijo DESNUDO:** `corpus/lua/autorun/corpus_registry.lua:1` («`-- corpus_registry.lua — Registro de módulos (SHARED)`»), más `corpus_data.lua`, `corpus_net.lua`, `corpus_ready.lua`, `corpus_log.lua`, `corpus_selftest.lua`, `client/corpus_ui.lua`. Ninguno `corpus_corpus_*`.
2. **Consumidores, CON segmento:** `corpus-cargo/lua/autorun/corpus_cargo_init.lua:1`, `corpus-caliber/lua/autorun/corpus_caliber_init.lua`, `corpus-coagulant/lua/autorun/corpus_coagulant_init.lua`, `corpus-craving/lua/autorun/corpus_craving_init.lua`, `corpus-stalker/lua/autorun/corpus_stalker_playermodels.lua`.
3. **EVIDENCIA DECISIVA — el nombre desnudo es LOAD-BEARING, no descuido.** `corpus-cargo/lua/autorun/corpus_cargo_init.lua:5-6` dice literalmente: *«gmod merges lua/autorun/ alphabetically across addons and "corpus_cargo_init.lua" sorts BEFORE "corpus_registry.lua"»*, y por eso difiere el boot a `Initialize`. **El boot de un repo hermano está escrito ALREDEDOR del nombre `corpus_registry.lua`.** Aplicar COR-6 literalmente al framework alteraría ese orden alfabético. El código no solo contradice a A: **depende de que A sea falsa.**
4. **El ecosistema ya lo dice bien desde el otro lado:** `corpus-stalker/CLAUDE.md:48-49` — *«Prefijo de archivo: `corpus_stalker_*.lua` … para no colisionar con los **seis** addons hermanos»*. Seis, no siete: el consumidor cuenta a los otros seis, y el framework nunca fue sujeto del segmento.
5. **Historia:** `CHANGELOG.md:197-201` — PARCHE 4 [APLICADO 2026-07-14], «CLAUDE.md: prefijo por addon (siete, no seis)…». Fue un edit deliberado, pero su alcance fue el **headcount** (incorporar `corpus-stalker` al universo de colisión); no litigó si el framework lleva segmento. **No deroga a B.**
6. **Propagación:** `CORPUS_Architecture.md:320` e `ids.yaml:109` repiten la formulación. El yaml es índice (fuera de la jerarquía): no litiga, se alinea a su sede.

**Voto disidente (refutador, 1/3):** sostuvo que «para evitar colisión … cuando los siete addons están montados» es una **cláusula de finalidad** (enumera la población que genera el riesgo), no la población obligada a llevar segmento — y citó el paralelo de COR-4 (`CLAUDE.md:62`: «evita colisión global de `net.Receive` entre los cinco módulos», siendo `Corpus.Net` primitiva del framework). Es una lectura razonable de la intención; **no sobrevive al punto 3**: el árbol depende del nombre desnudo, y la redacción actual no lo dice. La ambigüedad misma es el defecto.

**CONTEXTO QUE EL AUTOR DEBE VER:** `CHANGELOG.md:451-458` ya tiene COR-6 en **bucket B (voto)** por una podredumbre **distinta** de la **misma** cláusula: *«dice `corpus_<addon>_*.lua` en `lua/autorun/...` cuando 70 de 74 archivos Lua de los módulos viven fuera de autorun»*. Este hallazgo es el **segundo** defecto de la misma línea. Nota adicional: la corrida 2026-07-16 salió DEGRADADA y `namespacing` fue uno de los agentes bloqueados (`CHANGELOG.md:418-422`) — *«namespacing es un tema del framework: no está limpio, está sin auditar»*. Este eje nunca se adjudicó antes.

#### Parche PROPUESTO (NO aplicado) — tres sitios, una sola reformulación

**(a) `corpus/CLAUDE.md:64` — reemplazar el inciso 6:**
> 6. **COR-6 — Prefijo de archivo por addon:** los **seis addons consumidores** (los cinco módulos + `corpus-stalker`) prefijan sus archivos Lua `corpus_<addon>_*.lua` — tanto el entry point en `lua/autorun/` como el árbol propio bajo `lua/corpus_<addon>/`, `lua/entities/`, `lua/weapons/`. El **framework se reserva el prefijo `corpus_` desnudo** y nombra sus primitivas `corpus_<primitiva>.lua` en su propia `lua/autorun/`. El objetivo es evitar colisión de nombres cuando los siete addons están montados simultáneamente; el framework no colisiona consigo mismo. **El nombre `corpus_registry.lua` es load-bearing**: el boot de los módulos depende de su posición en el merge alfabético de `lua/autorun/` (ver `corpus_cargo_init.lua:5-6`) — no renombrar.

Esta redacción cierra **los dos ejes**: el de este hallazgo («siete» → «seis consumidores») y el ya votado en el CHANGELOG («en `lua/autorun/...`» → el árbol completo del addon). Es la formulación que `corpus-coagulant/CLAUDE.md:64` ya usa para su COR-6 local.

**(b) `corpus/docs/CORPUS_Architecture.md:320` — espejar:**
> - Prefijo de archivo por **addon**: los seis consumidores (cinco módulos + `corpus_stalker_*`) usan `corpus_<addon>_*.lua` en todo su árbol Lua; el framework se reserva `corpus_<primitiva>.lua` (`corpus_registry`, `corpus_data`, `corpus_net`, `corpus_ready`, `corpus_log`, `corpus_selftest`, `client/corpus_ui`). Evita colisión de nombres en `lua/autorun/` con los siete montados a la vez en el mismo cliente/servidor. Sede: **COR-6** en `CLAUDE.md`.

**(c) `corpus/docs/ids.yaml:109` — el índice sigue a su sede, no la redefine:**
```yaml
titulo: "Prefijo de archivo por addon: los seis consumidores (cinco módulos + corpus-stalker) usan corpus_<addon>_*.lua; el framework se reserva corpus_<primitiva>.lua. Contra colisión entre los siete addons montados a la vez."
```
Y en `evidencia` (`ids.yaml:114`), la ref actual «el árbol `lua/autorun/` de las siete raíces» apunta justo a lo que refuta la redacción vieja. Sugerido:
```yaml
- { tipo: codigo, ref: "corpus/lua/autorun/corpus_<primitiva>.lua sin segmento vs. corpus-cargo/lua/autorun/corpus_cargo_init.lua con segmento" }
```

---

### 2.1 — BAJA · `framework-delgado` · **BUCKET A (REPARABLE)** · 2/3

**Afirmación A** — `corpus/docs/CORPUS_Architecture.md:318` (titular normativo de §11):
> «**Código compartido vive SOLO en `corpus/`.**» — enunciado sin calificar qué clase de código, con la justificación de evitar divergencia silenciosa entre módulos.

**Afirmación B** — `corpus/docs/CORPUS_Architecture.md:39` (COR-10), con eco en `corpus/CLAUDE.md:9` y `CORPUS_Architecture.md:122`:
> Ni siquiera algo compartido por dos módulos sube a Corpus — el pool de HP de extremidades, compartido por Caliber y Coagulant, se queda en su dueño (Caliber) y el otro lo consume vía el registro.

**Alcance:** mismo en los cuatro ejes (realm shared, mismo conjunto módulos+framework, sin soft-dep de por medio, regla transversal a todos los Blocks). Leídas al pie de la letra son incompatibles sobre un objeto concreto: el pool de HP de extremidades **es** código compartido por dos módulos; §11 manda que viva SOLO en `corpus/`; §1/§3 prohíben exactamente eso y lo fijan en Caliber.

**Quién gana:** **B (COR-10)**, por autoridad 1 y por acuñación.

**Evidencia:**

1. El framework **no** aloja dominio compartido: `corpus/lua/` contiene solo las seis primitivas (`corpus_registry.lua`, `corpus_data.lua`, `corpus_net.lua`, `corpus_ready.lua`, `corpus_log.lua`, `client/corpus_ui.lua`, + `corpus_selftest.lua`). Grep de `limb|Limb|extremidad` sobre `corpus/lua/**` → **CERO hits**.
2. El pool vive íntegro en su dueño: `corpus-caliber/lua/corpus_caliber/server/corpus_caliber_limbs.lua:378` (`function CALIBER.ProcessLimbHit(npc, hitgroup, dmginfo)`), `:360` (`ResizeLimbPools`), `:437` (`HealLimbs`), `:302` (`CALIBER.ApplyLimbDebuffs = ApplyLimbDebuffs`).
3. El segundo consumidor lo toma vía registro, no vía copia: `corpus-coagulant/lua/corpus_coagulant/shared/corpus_coagulant_dev.lua:312` (`Corpus.HasModule("caliber") and "presente" or "ausente"`).
4. **Acuñación:** `CHANGELOG.md:250` — PARCHE 3 [APLICADO 2026-07-16] acuñó COR-10 en `CORPUS_Architecture.md`; `ids.yaml:136-138` lo registra con `fuerza: INVARIANTE`, `estado: VIGENTE`, sede `§3-4`. El titular de §11 **no tiene ID ni sede** (`2026-07-16_coherencia_docs_PILOTO.md:544-546` lo cataloga entre las cinco reglas del workspace: «**Ninguna tiene ID**»). Norma acuñada vigente contra prosa sin ID → gana B.
5. Ninguna entrada `[APLICADO]` derogó a ninguno de los dos: PARCHE 1 ([APLICADO 2026-07-14], `CHANGELOG.md:170-182`) reconcilió §2,§4,§5,§6,§7,§8,§9 y **no tocó §11**.

**Voto disidente (refutador, 1/3):** sostuvo que el calificador «infraestructura» está en la MISMA línea y el MISMO bullet («Ningún módulo copia-pega **infraestructura** de otro»), que no existe titular desnudo aplicable aislado, y que §11 (workspace multi-root) tiene alcance distinto de §1/§3 (qué asciende al framework). **Es correcto en cuanto al diseño** — por eso este hallazgo es BAJA y se clasifica como **defecto de redacción del titular**, no como choque de diseño. La prosa revela que la regla real es sobre INFRAESTRUCTURA; el titular normativo no lo dice, y es el titular el que un lector aplica.

#### Parche PROPUESTO (NO aplicado) — `corpus/docs/CORPUS_Architecture.md:318`

**TEXTO ACTUAL:**
```
- **Código compartido vive SOLO en `corpus/`.** Ningún módulo copia-pega infraestructura de otro — dado el patrón de drift ya observado en este proyecto (ver §16 del doc de ADS 2.0, el fix de `DNumSlider` documentado como final cuando era intermedio), esta es la regla que más protege contra divergencia silenciosa entre módulos.
```

**TEXTO PROPUESTO:**
```
- **La infraestructura compartida vive SOLO en `corpus/`** (COR-10, sede en §3-4). Ningún módulo copia-pega infraestructura de otro — dado el patrón de drift ya observado en este proyecto (ver §16 del doc de ADS 2.0, el fix de `DNumSlider` documentado como final cuando era intermedio), esta es la regla que más protege contra divergencia silenciosa entre módulos. **El dominio compartido entre dos módulos NO sube**: se queda en su dueño y el resto lo consume vía registro (COR-10, §1 y §3) — el pool de HP de extremidades vive en Caliber (`corpus_caliber_limbs.lua`) y Coagulant lo detecta con `Corpus.HasModule("caliber")`, no hay copia en el framework.
```

**Tres cambios y su porqué:** (1) «Código compartido» → «La infraestructura compartida»: acota el titular a lo que el propio cuerpo del bullet ya dice — **único cambio obligatorio**, es lo que mata el choque literal; (2) exclusión explícita del dominio compartido, que es la mitad de COR-10 que un lector de §11 hoy no ve; (3) la etiqueta `(COR-10, sede en §3-4)` deja claro que §11 **cita** y no **define** — cumple §7.2 del flujo y evita que el titular vuelva a derivar.

**Alternativa mínima:** cambiar solo «Código compartido» por «La infraestructura compartida». Cuesta menos y elimina la incompatibilidad literal; pierde el señalamiento de sede y la exclusión explícita.

**No se tocan** `CORPUS_Architecture.md:39` ni `:122` (sede de COR-10, ya correctas), ni `corpus/CLAUDE.md:9`, ni `ids.yaml:136-138`. Doc-only, sin superficie de runtime; si se aplica, corresponde entrada en `CHANGELOG.md`.

---

## 3. Patología del registro

### 3.1 Divergencias `ids.yaml`-vs-sede: **0**

Ninguna entrada del yaml contradice la prosa de su sede en el corpus auditado. Recordatorio de jerarquía: `docs/ids.yaml` **no entra** en la jerarquía de autoridad — es ÍNDICE, jamás segunda definición; si contradijera a su sede, el yaml es el desactualizado.

**Observación levantada por un verificador, fuera del alcance del arbitraje pero registrada acá:** `ids.yaml:141` lista como evidencia de COR-10 *«el pool de HP de extremidades vive en **Coagulant**, no en Corpus»*, mientras la sede (`CORPUS_Architecture.md:39`, `:122`) y `CLAUDE.md:9` dicen **Caliber** — y el árbol confirma Caliber (`corpus-caliber/lua/corpus_caliber/server/corpus_caliber_limbs.lua`). Como el yaml es índice y no litiga, esto **no se contabiliza** como divergencia formal, pero **el campo `evidencia` de COR-10 nombra el módulo equivocado**. Conviene barrerlo en la próxima tanda.

### 3.2 Normativas SIN ID: **86** — violación de FLU-25

Una norma sin ID va a derivar. Las 86 se distribuyen así en el corpus auditado:

| Doc | Normativas sin ID detectadas |
|---|---|
| `corpus/CLAUDE.md` | 6 (`:3`, `:15`, `:31`, `:33`, `:35`, `:37`) |
| `corpus/docs/corpus_flujo_trabajo.txt` | 18 (incluye **AUD-1/2/3** en `:550-555`, que tienen etiqueta pero no entrada canónica cruzada; y `:482-522` — todo el tramo del checker y las seis fases del gate) |
| `corpus/docs/CORPUS_Architecture.md` | 62 (el grueso — §3 primitivas, §4 fronteras, §5 contrato de ítems, §6 orden de carga, §7 migración, §8 workspace) |

**Concentraciones que más urgen** (norma dura, alta probabilidad de deriva, sin ancla):

- **Las seis fases del gate y su regla READ-ONLY** — `corpus_flujo_trabajo.txt:516-522` y `:523-526` («el gate propone, el autor dispone»). Es la regla que gobierna a este mismo documento y no tiene ID.
- **El tramo completo del checker** — `:482-489` (hook `pre-commit`, `core.hooksPath`, `--no-verify` como decisión), `:502-505` («falla ruidoso, nunca en silencio — un "limpio" que no corrió no es un limpio»), `:507-509` (fixtures).
- **Todo el patrón de boot** — `CORPUS_Architecture.md:184`, `:188`, `:192`, `:197`, `:204`, `:215`, `:223`, `:233`, `:265`. Nueve normas de `boot-carga`, template real de los cuatro módulos con código, ancladas solo a COR-5/COR-6 por cita indirecta.
- **Las fronteras de dominio de los cinco módulos** — `CORPUS_Architecture.md:132-140`. Definen qué posee, expone y consume cada módulo; solo citan COR-11/COR-12, ninguna tiene ID propio.
- **El contrato de ítems** — `:161`, `:162`, `:172`, `:173`, `:176`. Incluye la regla dura «`class` es OBLIGATORIO: `cargo.Items.Register` hace `error()` si falta».
- **Las cinco reglas del workspace de §11** — incluido el titular del hallazgo 2.1. Ninguna tiene ID; **eso es exactamente lo que permitió que 2.1 existiera.**

### 3.3 Nota sobre la forma canónica de los IDs (menor, pero anotado)

`ids.yaml` mezcla formas **entre familias**: `COR-1..COR-14` sin padding, `FLU-01..FLU-38` con padding, `GIT-1..7` y `AUD-1..5` con criterios propios. El flujo (`:476`) reconoce que «COR-1 y COR-01 son el MISMO ID» y lo trata como DUPLICADO. Mientras la forma se elija por familia y no por regla, `FLU-4` escrito a mano nace huérfano y `COR-01` nace bicéfalo. **Recomendación:** fijar la forma canónica en el bloque `familias` y hacer que el checker normalice antes de comparar.

---

## 4. Ambigüedades de alcance: **56 afirmaciones sin alcance declarado**

No son hallazgos: son **ambigüedad latente**. Cada una es un falso positivo futuro o una deriva futura, según de qué lado caiga el lector.

**Patrón dominante — el eje REALM está sistemáticamente en blanco.** De las 56, la abrumadora mayoría son afirmaciones de `CORPUS_Architecture.md` §2 y §4 (grafo de dependencias y fronteras de dominio) donde el alcance se registró como «REALM: no especificado». Ejemplos representativos:

- `CORPUS_Architecture.md:34-37` — los dominios de Caliber/Coagulant/Craving/Cargo, todos sin realm.
- `:50-76` — **todo el bloque de degradación honesta** (qué hace cada módulo sin cada peer). Trece afirmaciones normativas sobre soft-deps, ninguna con realm declarado. `:76` es el caso más agudo: «sin Cargo, Craving degrada a una vía de mundo con entity propia» — la entity es server-side por naturaleza, **pero el doc no lo declara**.
- `:132-140` — las fronteras de los cinco módulos.
- `:176` — la entity `corpus_craving_food` y su gate WALK+USE.
- `:138` — «la `Limbs` API debe ser agnóstica a la entidad»: sin realm y sin ID.

**Por qué importa más de lo que parece.** REALM es el **primero de los cuatro ejes** que este mismo gate usa para **descartar** falsos positivos («una regla de server y una de client NO chocan»). Si el eje que descarta nunca se declara en la fuente, se está descartando con una regla no verificada. Ver §5.3, sospechoso #1.

**Recomendación:** no barrer las 56 de golpe. Priorizar el bloque `:50-76` (degradación honesta) — es donde la ambigüedad de realm tiene consecuencia directa de implementación.

---

## 5. Huecos de ESTA auditoría — honestidad sobre lo NO cubierto

**COBERTURA PERDIDA: ninguna.** No hubo agentes muertos ni tramos sin auditar en esta corrida. **Esta acta NO está degradada.** (La corrida base del 2026-07-16 sí lo estuvo: `CHANGELOG.md:418-422` — dos agentes de cruce, `namespacing` y `dano-limbs`, fueron bloqueados por un error transitorio del clasificador.)

Dicho eso, la cobertura completa **del corpus definido** no es cobertura completa **del ecosistema**. Lo que sigue es lo que este gate estructuralmente no pudo ver.

### 5.1 DOS de los cinco docs auditados no tienen IDs propios: sobre ellos este gate es CIEGO

| doc | IDs propios etiquetados | citas de IDs |
|---|---|---|
| `corpus/CLAUDE.md` | COR-1..COR-11 (11) | 14 |
| `corpus/docs/corpus_flujo_trabajo.txt` | FLU-04..38, AUD-1..3 (23 distintos) | 21 |
| `corpus/docs/CORPUS_Architecture.md` | **4** (COR-7/8/10/11) — pero `ids.yaml` le asigna **9 sedes** | 5 |
| **`corpus/docs/corpus_convenciones_commits.txt`** | **CERO** — aunque `ids.yaml:40` declara la familia **GIT con sede ahí** y registra GIT-1..7 | **0** |
| **`corpus/docs/corpus_roadmap.txt`** | **CERO** — ninguna familia lo nombra, ninguna entrada lo tiene por sede, no cita ni un ID | **0** |

**Con todas las letras: `corpus_convenciones_commits.txt` y `corpus_roadmap.txt` son puntos ciegos perfectos para un gate que cruza IDs. Un «limpio» sobre ellos no es evidencia de nada — es «NO AUDITADO».**

Y no es hipotético: la única contradicción encontrada en el roadmap (§2.3) salió de leer prosa a ojo, **no del cruce de IDs** — o sea, salió por suerte, y en un doc de cero IDs la suerte es toda la cobertura que hay. Peor con GIT: **siete normas registradas cuyo texto canónico no se puede anclar a ninguna línea, porque la sede nunca las rotula.**

**`CORPUS_Architecture.md` es el tercer caso, a medias:** 5 de sus 9 sedes son prosa anónima. Eso, y no otra cosa, explica buena parte de las 86 normativas sin ID de §3.2.

**Cómo se tapa:** etiquetar GIT-1..7 en `corpus_convenciones_commits.txt` y las 5 sedes anónimas de `CORPUS_Architecture.md` **antes** de la próxima corrida; y **decidir explícitamente** si el roadmap es doc normativo (→ etiqueta o cita IDs) o puramente de intención (→ entonces el acta debe declararlo **NO-AUDITABLE por diseño**, no reportarlo como cubierto).

### 5.2 Docs que quedaron fuera del corpus y deberían estar

**a) Tres docs del propio framework, fuera incluso del piloto:**
- `corpus/docs/corpus_estado.md` — **es el doc #1 de la jerarquía de lectura** del CLAUDE.md («léelo ANTES que la arquitectura»). Cita 1 ID y `ids.yaml` lo declara sede de una entrada. Es la foto del AHORA: exactamente el doc donde una norma derogada sobrevive.
- `corpus/docs/CHANGELOG.md` — **22 citas de IDs**, el segundo doc del framework con más citas después del flujo. Es donde una norma pasa de `[PENDIENTE]` a `[APLICADO]`; un ID citado ahí y muerto en la sede es drift puro **y nadie lo miró**.
- `corpus/README.md` — 0 IDs, cara pública.

**b) `corpus-cortex` no tiene `CLAUDE.md`.** `ids.yaml:47` declara `CTX: { sede: "corpus-cortex/CLAUDE.md" }` — **la sede de una familia entera apunta a un archivo que no existe**. Se salva del rojo solo porque CTX tiene 0 entradas. Es una familia fantasma esperando a que alguien acuñe CTX-1 contra un archivo inexistente.

**c) El número «19 docs de diseño de las siete raíces» del modo COMPLETO (`corpus_flujo_trabajo.txt` §7.8) no está derivado del árbol** — viola FLU-27 en el doc que la acuña. El árbol real tiene **~29** docs de diseño sin contar CHANGELOGs ni estados: corpus 5 · caliber 5 · coagulant 5 · craving 5 · **cargo 7** (`Cargo_Architecture.md`, `Cargo_ItemImages_`, `Cargo_Trade_`, `Workbench_Arquitectura.md`, CLAUDE, convenciones, roadmap) · stalker 2 (CLAUDE + `ASSETS.md`) · cortex 1. **Si el COMPLETO corre contra una lista de 19 escrita a mano, arranca con ~10 docs invisibles y un ✅ que no significa nada.**

**d) Docs de diseño con CERO gobierno de IDs** (ni sede ni cita — el punto ciego de §5.1 replicado en los módulos): `corpus-cargo/docs/Workbench_Arquitectura.md` (11 KB), `corpus-craving/docs/Craving_Block4_Semilla.md` (15 KB), **`corpus-cargo/docs/cargo_roadmap.txt` (37 KB — el doc más grande del ecosistema sin un solo ID)**, y los cuatro `*_roadmap.txt` de módulo.

### 5.3 Los ceros que NO son limpieza

Diez de los catorce buckets salieron en cero. **En modo piloto, cinco de esos ceros son aritmética, no salud.**

**SIN FUENTE (cero por falta de par, no por sanidad) — `dano-limbs`, `dominio-medico`, `inventario`, `contrato-items`, `ui-vgui`:** solo tienen fuente en los docs de módulo, que quedaron fuera. Medido: en los 5 docs del framework, `inventario`/`grid`/`hambre`/`sangrado`/`hitgroup` aparecen ≤6 veces cada uno **y siempre dentro de la lista «lo que Corpus NO contiene»**; `VGUI` y `DermaMenu`: **0 hits**. Un tema con una sola fuente no puede producir un par incompatible. **Su cero se reporta acá como SIN FUENTE, no como limpio.** Ídem `assets-licencias`: fuente framework = 1 línea de CLAUDE.md; la otra mitad es `corpus-stalker/docs/ASSETS.md`, no auditado.

**Sospechosos reales — tienen fuente en el framework, salieron en cero, y hay olor a choque:**

- **`realms` (sospechoso #1).** El framework declara casi todo `shared` y pone la UI en `client`. Pero `corpus-coagulant/CLAUDE.md` #8 exige el hook `Move` en **shared por predicción**, y `corpus-cargo/CLAUDE.md` #8 declara el attach ARC9 **client-side, «replica solo»**. El cruce framework-vs-módulo sobre realm **nunca corrió** — y el realm es el primero de los cuatro ejes de alcance del propio gate. **Si el eje que se usa para descartar falsos positivos nunca se auditó, se está descartando con una regla no verificada.** (Conecta directo con §4.)
- **`persistencia` (sospechoso #2).** COR-3 promete `Save/Load` JSON como primitiva y no dice **nada** del contrato de claves. `corpus-cargo/CLAUDE.md` #6: «el round-trip JSON **no** preserva tipos de clave: re-normaliza claves numéricas al cargar (`Util.NumberKeys`)» — **una trampa de la primitiva del framework documentada solo en el CLAUDE.md del consumidor que la pagó**. Y `corpus-coagulant/CLAUDE.md` #8 dice «sin persistencia a disco». Cero contradicciones acá significa que nadie comparó la promesa con el recibo.
- **`evidencia` (sospechoso #3).** El más expuesto a auto-complacencia: su norma vive en flujo §7.4 **+ `ids.yaml`** (excluido del corpus por diseño, `flujo:492`) **+ la planilla en juego** (fuera del corpus). Dos de las tres patas del par están fuera del cruce. Corolario: **ninguna contradicción entre `ids.yaml` y flujo §7 se buscó jamás** — decisión correcta para el checker, hueco real para el gate.

### 5.4 Temas transversales que la taxonomía de 14 buckets no captura

Por orden de daño:

1. **FRONTERA DE CONFIANZA / autoridad del servidor.** No existe bucket. `namespacing` cubre cómo se *llama* el mensaje net, jamás **quién valida**. En los 5 docs del framework: `exploit`, `cheat`, `trust` → **0 hits**. En los módulos es doctrina dura y repetida: `corpus-coagulant/CLAUDE.md` #7 («El cliente nunca es autoridad»), `corpus-cargo/CLAUDE.md` #7 («el server posee el inventario; el cliente solo envía intents») y #13 («El precio lo dice el servidor»), `corpus-stalker/CLAUDE.md` #5 (`net.ReadTable()` sin validar admin, como antipatrón). **Una norma que cuatro repos repiten y para la que el framework no tiene sede: eso es un ID bicéfalo esperando nacer.**
2. **CONTRATO PÚBLICO / superficie estable.** Distinto de `contrato-items`. CAL #7, COA #4, CRV #4 y el bloque CONTRACT de `corpus_cargo_init.lua` declaran «el resto es off-contract **por convención**». Nadie cruzó eso contra COR-2 ni contra el invariante by-ref (COR-7).
3. **GOBIERNO DEL PROPIO REGISTRO** (§7.x + `ids.yaml` + checker + gate). Repartido entre `proceso` y `evidencia`, sin dueño.
4. **NAMESPACING NO-DE-ARCHIVO:** clases de entidad (`corpus-stalker/CLAUDE.md` #6: los packs usan `blood`, `fire`, `control` — **colisión garantizada**), convars y NW2 vars. El bucket `namespacing` miró archivos/net/data; **convars y NW2 no tienen norma en ningún lado**.
5. **TIMERS / PERFORMANCE / PREDICCIÓN:** CRV #8 («un solo timer, nada per-frame»), COA #8 (hook `Move` **shared** porque se predice, y «dos módulos escalando `MaxSpeed` se multiplican»). `realms` no lo captura: esto es **composición**, no realm.
6. **ECONOMÍA/PRECIO y CRAFTING** (`Cargo_Trade_Arquitectura.md`, `Workbench_Arquitectura.md`): sin bucket **y** sin IDs → doble punto ciego.
7. **BALANCE COMO DATO** (CRV #7) y **DEUDA HEREDADA que «viaja sin tocar»** (`corpus-caliber/CLAUDE.md` §10).

### 5.5 Framework contra los CLAUDE.md de módulo — lo que doc-vs-doc jamás pudo ver

**Los 6 CLAUDE.md de módulo son SEDE de 5 familias (CAL 22 + CRG 48 + COA 31 + CRV 16 + STK 8 = 125 IDs, ~2/3 del registro entero) y ninguno entró al corpus.** Lo que el piloto estructuralmente no podía ver:

1. **COR-11 vs. `corpus-craving/CLAUDE.md` #3 — el más grave.** El framework prescribe detección por **presencia** (`GetModule`/`HasModule`). Craving declara textualmente lo contrario: *«Degradación por **CAPACIDAD**, no por presencia. El puente Coagulant exige `isfunction(coag.ApplyExternalCondition)` — un Coagulant montado sin la función cae al mismo fallback que su ausencia»*. O es refinamiento o es choque, según cómo esté redactado COR-11 — **y es el mismo tema (`soft-deps`) donde este piloto ya confirmó un choque (§2.2)**. Un tema que ya demostró estar podrido, auditado a mitad de fuentes.
2. **COR-6 «los siete addons» vs. `corpus-stalker/CLAUDE.md` #2: «los SEIS addons hermanos».** El hallazgo §2.4 dedujo del árbol que la formulación correcta es «seis consumidores»… y resulta que **un CLAUDE.md ya lo dice bien**. Evidencia gratis para el parche, que solo se pudo citar porque un verificador salió del corpus.
3. **COR-1 vs. `corpus-cargo/CLAUDE.md` #2/#3/#11.** Cargo se comporta como un mini-framework de ítems (`Items.DeclareSubSlot` lo consumen tres módulos; «un solo primitivo de sub-slot»; «un solo inventario-en-entidad»). Es exactamente el eje de §2.1: la pregunta «¿esto es infraestructura compartida o dominio compartido?» **se decide sobre Cargo**, y Cargo no estaba en la sala.
4. **`corpus-cargo/CLAUDE.md` #13: «El peso NO es un gate (derogado en la 1.ª pasada en juego, CHANGELOG #21)».** Una norma **derogada por evidencia en juego** que vive en un CLAUDE.md y en un CHANGELOG — **ninguno de los dos en el corpus del gate**. Si `Cargo_Architecture.md` todavía dice lo contrario, es invisible por construcción.
5. **`corpus-coagulant/CLAUDE.md` #5 vs. #2 de Cargo y #5 de Craving** (`contrato-items`): Cargo consume 1 unidad «si `onUse` devuelve `true`»; Coagulant devuelve **`false`** a propósito y llama `TakeItem` al completar. Probablemente compatible — pero es precisamente el par que el bucket `contrato-items` existía para mirar, y ese bucket salió en cero por no tener a ninguno de los tres docs.

### 5.6 Orden de ejecución sugerido para tapar los huecos

1. **Etiquetar GIT-1..7** en `corpus_convenciones_commits.txt` y las **5 sedes anónimas** de `CORPUS_Architecture.md`; **decidir el estatus del roadmap**. *Sin esto, ninguna corrida futura sobre esos docs vale.*
2. **Derivar a grep la lista del modo COMPLETO** (~29, no 19) y congelarla en §7.8; **sumar `corpus_estado.md` + `docs/CHANGELOG.md` al PILOTO** (son framework y son vivos).
3. **Abrir el bucket `frontera-de-confianza`** y darle sede en el framework; abrir **`contrato-publico`** y **`namespacing-de-entidades/convars`**.
4. **Correr un cruce dirigido framework-vs-CLAUDE.md de módulo** sobre `soft-deps` (COR-11 vs. Craving #3), `persistencia` (COR-3 vs. Cargo #6) y `realms` — **los tres antes del COMPLETO**.
5. **Resolver la familia fantasma CTX** (`corpus-cortex/CLAUDE.md` no existe).
6. **Reportar los ceros SIN FUENTE como tales**, nunca como limpios.
7. **Fijar la forma canónica de ID** en `familias` y hacer que el checker normalice (§3.3).

---

## 6. Qué NO se auditó, y por qué

Delimitación explícita del alcance de este gate. Nada de lo que sigue está cubierto por esta acta, y su ausencia **no** es un limpio:

- **Doc-vs-código está FUERA DE ALCANCE.** Este gate cruza **doc contra doc**. El Lua se leyó únicamente como **árbitro de autoridad 1** para decidir cuál de dos docs en conflicto gana — nunca como sujeto auditado. **Esta acta NO afirma que nada esté implementado, ni que nada falte por implementar.** «Esto no está implementado todavía» no es hallazgo: el ecosistema diseña por delante del código **a propósito**.
- **MOCK-FIRST (FLU-17) no se reporta como contradicción.** Un doc que congela la firma de un peer inexistente está haciendo su trabajo. El caso real (Craving congelando `COAGULANT.ApplyExternalCondition` antes de que Coagulant la ratificara) es **deuda declarada (D-5)**, no drift.
- **Degradación honesta (COR-11) no se reporta como contradicción.** «Sin Cargo, la vía es X» y «con Cargo, la vía es Y» es el patrón de producción del ecosistema.
- **Huérfanos, bicéfalos y sedes rotas NO son de este gate.** Los prueba el **checker determinista** (`.claude/check-ids/`), que corre en cada `pre-commit` y falla ruidoso (`corpus_flujo_trabajo.txt:482-505`). Excepción: se **anotan** acá cuando aparecen de paso (la familia fantasma CTX, §5.2b; la forma canónica mezclada, §3.3) — pero el gate no los prueba.
- **Los seis CLAUDE.md de módulo, los ~24 docs de módulo, `corpus_estado.md`, `docs/CHANGELOG.md`, `corpus/README.md` e `ids.yaml`**: fuera del corpus. Ver §5.2 y §5.5.
- **Diferencias de nivel de detalle, de alcance por realm/módulo/soft-dep/block, y dos docs diciendo lo mismo con otras palabras**: rechazados como falsos positivos por diseño.

---

## 7. MODO PILOTO — declaración

**Esta corrida auditó SOLO el framework (`corpus/`): 5 docs, ~1.188 líneas.** No es el modo COMPLETO.

**Por qué:** el modo COMPLETO audita las siete raíces y el costo se mide antes de correrlo, no se estima (`corpus_flujo_trabajo.txt:574-575`; el piloto de Kontrol fueron ~216 agentes / ~11M tokens / ~84 min para 3 docs). El PILOTO existe para calibrar el gate contra un corpus acotado y conocido antes de pagar el COMPLETO.

**Esto es la deuda D-7:** el gate de coherencia solo ha corrido sobre el framework. Los ~24 docs de diseño de los módulos, los seis CLAUDE.md de módulo (**sede de ~2/3 del registro de IDs**) y `corpus-stalker` **nunca fueron auditados por este gate**. Los ceros de `dano-limbs`, `dominio-medico`, `inventario`, `contrato-items`, `ui-vgui` y `assets-licencias` en esta acta son consecuencia directa de D-7 y se reportan como **SIN FUENTE** (§5.3), no como limpios.

**Cadencia aplicable** (`corpus_flujo_trabajo.txt:550-555`): AUD-1 dispara el SCOPED al cerrar cualquier sesión que escribió normas en `docs/`; **AUD-2 exige el COMPLETO al cerrar un Block de módulo, antes de abrir el siguiente** — el próximo Block de Cortex es el disparador natural para saldar D-7. AUD-3: ningún gate corre con poco contexto remanente; una ✅ en condiciones degradadas es una hipótesis, no un cierre.

**Antes del COMPLETO, hacer §5.6 puntos 1-4.** Correr el COMPLETO contra una lista de 19 docs escrita a mano, con `corpus_convenciones_commits.txt` y los cinco `*_roadmap.txt` sin un solo ID, produce un ✅ que no significa nada.

---

*Acta cerrada. Inmutable. Los cuatro parches de §2 están PROPUESTOS, NO APLICADOS. El gate propone, el autor dispone.*
